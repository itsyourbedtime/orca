-- ORCA for norns
--
-- its your bedtime
--
--         X
--
-- hundred rabbits
--
function unrequire(name)
  package.loaded[name] = nil
  _G[name] = nil
end

unrequire("timber/lib/timber_engine")
engine.name = "Timber"
local Timber = require "timber/lib/timber_engine"
local music = require "musicutil"
local NUM_SAMPLES = 35
local keyb = hid.connect()
local keycodes = include("orca/lib/keycodes")
local transpose_table = include("orca/lib/transpose")
local operators = include("orca/lib/ops")
local tab = require 'tabutil'
local fileselect = require "fileselect"
local textentry = require "textentry"
local music = require 'musicutil'
local BeatClock = require 'beatclock'
local euclid = require 'er'
local mode = #music.SCALES
local scale = music.generate_scale_of_length(60,music.SCALES[mode].name,16)
local midi_out_device 
local clk = BeatClock.new()
local notes_off_metro = metro.init()
local active_notes = {}
local keyinput = ""
local XSIZE = 101 
local YSIZE = 33  
local x_index = 1
local y_index = 1
local bar = false
local help = false
local field_grid = 1
local field_offset_y = 0
local field_offset_x = 0
local selected_area_y = 1
local selected_area_x = 1
local copy_buffer = {}
copy_buffer.cell = {}
local bounds_x = 25
local bounds_y = 8
local max_sc_ops = 6
local frame = 1
local orca = {}
local field = {}
field.cell = {}
field.cell.params = {}
field.active = {}
field.cell.vars = {}

local map = false

local function all_notes_off(ch)
    for _, a in pairs(active_notes) do
      midi_out_device:note_off(a, nil, ch)
    end
  active_notes = {}
end

orca.load_project = function(pth)
  if string.find(pth, 'orca') ~= nil then
    saved = tab.load(pth)
    if saved ~= nil then
      print("data found")
      field = saved
      local name = string.sub(string.gsub(pth, '%w+/',''),2,-6) 
      softcut.buffer_read_mono(norns.state.data .. name .. '_buffer.aif', 0, 0, #orca.chars, 1, 1)
      params:read(norns.state.data .. name ..".pset")
      print ('loaded ' .. norns.state.data .. name .. '_buffer.aif')
    else
      print("no data")
    end
  end
end

orca.save_project = function(txt)
  if txt then
    tab.save(field, norns.state.data .. txt ..".orca")
    softcut.buffer_write_mono(norns.state.data..txt .."_buffer.aif",0,#orca.chars, 1)
    params:write(norns.state.data .. txt .. ".pset")
    print ('saved ' .. norns.state.data .. txt .. '_buffer.aif')
  else
    print("save cancel")
  end
end


function orca.copy_area()
  for y=y_index - 1, y_index + ( selected_area_y - 1) do
    local y_c = util.clamp(y - y_index,1,YSIZE)
    copy_buffer.cell[y_c ] = {}
    for x = x_index - 1, x_index + ( selected_area_x - 1 ) do
      local x_c = util.clamp(x - x_index,1,XSIZE)
      copy_buffer.cell[y_c][x_c ] = field.cell[y][x]
    end
  end
end

function orca.cut_area()
  for y=y_index, y_index + ( selected_area_y - 1) do
    copy_buffer.cell[y -  y_index ] = {}
    for x = x_index, x_index + ( selected_area_x - 1 ) do
      copy_buffer.cell[y -  y_index ][x -  x_index ] = field.cell[y][x]
      orca:erase(x,y)
    end
  end
end

function orca.paste_area()
  for y=1, #copy_buffer.cell do
    for x = 1, #copy_buffer.cell[y] do
      orca:erase(util.clamp(x_index + x,1,XSIZE), util.clamp(y_index + y,1,YSIZE))
      field.cell[y_index + y][(x_index + x)] = copy_buffer.cell[y][x]
      orca:add_to_queue(x_index + x, y_index + y)
    end
  end
end

orca.list =  {
  ["*"] = '*',
  [':'] = ':',
  ["'"] = "'",
  ['/'] = '/',
  ['\\']= '\\',
  ["A"] = 'A',
  ["B"] = 'B',
  ["C"] = 'C',
  ["D"] = 'D',
  ["E"] = 'E',
  ["F"] = 'F',
  ['G'] = 'G',
  ['H'] = 'H',
  ["I"] = 'I',
  ["J"] = 'J',
  ['K'] = 'K',
  ["L"] = 'L',
  ["M"] = 'M',
  ["N"] = 'N',
  ['O'] = 'O',
  ["P"] = 'P',
  ['Q'] = 'Q',
  ["R"] = 'R',
  ["S"] = 'S',
  ['T'] = 'T',
  ['U'] = 'U',
  ["V"] = 'V',
  ["W"] = 'W',
  ["X"] = 'X',
  ['Y'] = 'Y',
  ["Z"] = 'Z'
}
orca.bangs ={
  ["E"] = 'E',
  ["W"] = 'W',
  ["S"] = 'S',
  ["N"] = 'N',
}
orca.names =  {
  ["*"] = 'bang',
  [':'] = 'midi',
  ["'"] = 'engine',
  ['/'] = 'softcut',
  ['\\']= 'r note',
  ["A"] = 'add',
  ["B"] = 'bounce',
  ["C"] = 'clock',
  ["D"] = 'delay',
  ["E"] = 'east',
  ["F"] = 'if',
  ['G'] = 'generator',
  ['H'] = 'halt',
  ["I"] = 'increment',
  ["J"] = 'jumper',
  ['K'] = 'konkat',
  ["L"] = 'loop',
  ["M"] = 'modulo',
  ["N"] = 'north',
  ['O'] = 'offset',
  ["P"] = 'push',
  ['Q'] = 'query',
  ["R"] = 'random',
  ["S"] = 'south',
  ['T'] = 'track',
  ['U'] = 'euclid',
  ["V"] = 'variable',
  ["W"] = 'west',
  ["X"] = 'write',
  ['Y'] = 'jymper',
  ["Z"] = 'zoom'

}
orca.info = {
  ['*'] = 'Bangs neighboring operators.',
  [':'] = 'Midi 1-channel 2-octave 3-note 4-velocity 5-length',
  ["'"] = 'Engine 1-sample 2-pitch 3-pitch 4-level 5-pos',
  ['/'] = 'Softcut 1-plhead 2-rec 3-play 4-level 5-pos',
  ['\\']= 'Outputs random note within octave',
  ['='] = 'Sends a OSC message',
  ['A'] = 'Outputs the sum of inputs.',
  ['B'] = 'Bounces between two values based on the runtime frame.',
  ['C'] = 'Outputs a constant value based on the runtime frame.',
  ['D'] = 'Bangs on a fraction of the runtime frame.',
  ['E'] = 'Moves eastward, or bangs.',
  ['F'] = 'Bangs if both inputs are equal.',
  ['G'] = 'Writes distant operators with offset.',
  ['H'] = 'Stops southward operator from operating.',
  ['I'] = 'Increments southward operator.',
  ['J'] = 'Outputs the northward operator.',
  ['K'] = '',
  ['L'] = 'Loops a number of eastward operators.',
  ['M'] = '.',
  ['N'] = 'Moves northward, or bangs.',
  ['O'] = 'Reads a distant operator with offset.',
  ['P'] = 'Writes an eastward operator with offset.',
  ['Q'] = 'Reads distant operators with offset.',
  ['R'] = 'Outputs a random value.',
  ['S'] = 'Moves southward, or bangs.',
  ['T'] = 'Reads an eastward operator with offset',
  ['U'] = 'Bangs based on the Euclidean pattern',
  ['V'] = 'Reads and writes globally available variable',
  ['W'] = 'Moves westward, or bangs.',
  ['X'] = 'Writes a distant operator with offset',
  ['Y'] = 'Outputs the westward operator',
  ['Z'] = '',
}
orca.ports = {
  [':'] = {{1, 0, 'input_op'}, {2, 0, 'input_op'}, {3, 0 , 'input_op'}, {4, 0 , 'input_op'}, {5, 0 , 'input_op'}},
  ["'"] = {{1, 0, 'input_op'}, {2, 0, 'input_op'}, {3, 0 , 'input_op'}, {4, 0 , 'input_op'}, {5,0, 'input_op'}},
  ['/'] = {{1, 0, 'input_op'}, {2, 0, 'input_op'}, {3, 0 , 'input_op'}, {4, 0 , 'input_op'}, {5, 0 , 'input_op'}, {6, 0 , 'input_op'}},
  ['\\']= {{1, 0, 'input'}, {-1, 0, 'input'}, {0, 1 , 'output_op'}},
  ['A'] = {{1, 0, 'input_op'}, {-1, 0, 'input_op'}, {0, 1 , 'output_op'}},
  ['B'] = {{1, 0, 'input'}, {-1, 0, 'input'}, {0, 1 , 'output'}},
  ['C'] = {{1, 0, 'input_op'}, {-1, 0, 'input'}, {0, 1 , 'output'}},
  ['D'] = {{1, 0, 'input_op'}, {-1, 0, 'input'}, {0, 1 , 'output'}},
  ['F'] = {{1, 0, 'input'}, {-1, 0, 'input'}, {0, 1 , 'output_op'}},
  ['G'] = {{-3, 0, 'input'}, {-2, 0, 'input'}, {-1, 0, 'input'}},
  ['H'] = {{0, 1, 'input_op'}},
  ['J'] = {{0, -1, 'input'}, {0, 1, 'output_op'}},
  ['K'] = {{-1, 0, 'input'}},
  ['L'] = {{-1, 0, 'input'}, {-2, 0, 'input'}},
  ['I'] = {{1, 0, 'input'}, {-1, 0, 'input'}, {0, 1 , 'output'}},
  ['O'] = {{-1, 0, 'input'}, {-2, 0, 'input'}, {0, 1, 'output'}, {1, 0 , 'input_op'}},
  ['Q'] = {{-3, 0, 'input'}, {-2, 0, 'input'},{-1, 0, 'input'}, {0, 1, 'output'}},
  ['M'] = {{-1, 0, 'input'}, {1, 0, 'input'}, {0, 1 , 'output'}},
  ['P'] = {{1, 0, 'input_op'}, {-1, 0, 'input'}, {-2, 0, 'input'}, {0, 1, 'output_op'}},
  ['G'] = {{-3, 0, 'input'}, {-2, 0, 'input'}, {-1, 0, 'input'}},
  ['T'] = {{-1,0, 'input_op'},  {-2, 0, 'input_op'},  {1, 0, 'input_op'}, {0, 1 , 'output_op'}},
  ['R'] = {{-1, 0, 'input'}, {1, 0, 'input'}, {0, 1 , 'output_op'}},
  ['X'] = {{1, 0, 'input_op'}, {-1, 0, 'input'}, {-2, 0 , 'input'}},
  ['U'] = {{1, 0, 'input_op'}, {-1, 0, 'input'}, {0, 1 , 'output'}},
  ['V'] = {{-1,0, 'input_op'},  {1, 0, 'input_op'}},
  ['Y'] = {{-1, 0, 'input'}, {1, 0, 'output_op'}},
  ['W'] = {},
  ['S'] = {},
  ['E'] = {},
  ['N'] = {},
  ['Z'] = {{1, 0, 'input'}, {-1, 0, 'input'}, {0, 1 , 'output'}},
  ['*'] = {},
}
orca.notes = {"C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B"}
orca.chars = {'1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
orca.chars[0] = '0'


function orca.normalize(n)
  return n == 'e' and 'F' or n == 'b' and 'C' or n
end

function orca.transpose(n, o)
  if n == nil or n == 'null' then n = 'C' else n = tostring(n) end 
  if o == nil or o == 'null' then o = 0 end
  local note = orca.normalize(string.sub(transpose_table[n], 1, 1))
  local octave = util.clamp(orca.normalize(string.sub(transpose_table[n], 2)) + o,0,8)
  local value = tab.key(orca.notes, note)
  local id = util.clamp((octave * 12) + value, 0, 127)
  local real = id < 89 and tab.key(transpose_table, id - 45) or nil -- ??
  return {id, value, note, octave, real}
end

function orca:input(x,y, default)
  local value = string.lower(tostring(field.cell[y][x]))
  if value == '0' then 
    return 0
  elseif value ~= nil or value ~= 'null' then 
    return tab.key(orca.chars, value)
  else
    return false
  end
end 

function orca.is_op(x,y)
  x = util.clamp(x,0,XSIZE)
  y = util.clamp(y,0,YSIZE)
  if (field.cell[y][x] ~= 'null' and field.cell[y][x] ~= nil) then
    if (orca.list[string.upper(field.cell[y][x])] and field.cell.params[y][x].op) then
      if orca.list[string.upper(field.cell[y][x])] and field.cell.params[y][x].act == true then
        return true
      end
    end
  else
    return false
  end
end

function orca.is_bang(x,y)
  if (field.cell[y][x] ~= 'null' and field.cell[y][x] ~= nil) then
    if (orca.bangs[string.upper(field.cell[y][x])] and field.cell.params[y][x].op) then
      return true
    end
  else
    return false
  end
end

function orca.banged(x,y)
  if field.cell[y][x - 1] == '*' then 
    return true
  elseif field.cell[y][x + 1] == '*' then
    return true
  elseif field.cell[y - 1][x] == '*' then
    return true
  elseif field.cell[y + 1][x] == '*' then 
    return true
  else
    return false
  end
end

function orca:active()
  if field.cell.params[self.y][self.x].op == true then
    if field.cell[self.y][self.x] == string.upper(field.cell[self.y][self.x]) then
      return true
    elseif field.cell[self.y][self.x] == string.lower(field.cell[self.y][self.x]) then
      return false
    end
  end
end

function orca:replace(i)
  field.cell[self.y][self.x] = i
end

function orca:shift(s, e)
  local data = field.cell[self.y][self.x + s]
  local params_data = field.cell.params[self.y][self.x + s]
  table.remove(field.cell[self.y], self.x + s)
  table.remove(field.cell.params[self.y], self.x + s)
  table.insert(field.cell[self.y], self.x + e, data)
  table.insert(field.cell.params[self.y], self.x + e, params_data)
end

function orca:cleanup()
  if orca.is_op(self.x, self.y) then self:clean_ports(orca.ports[string.upper(field.cell[self.y][self.x])]) end
  field.cell.params[self.y][self.x] = {op = true, lit = false, lit_out = false, act = true, cursor = false, dot_cursor = false, dot_port = false, dot = false, placeholder = nil}
  if field.cell.params[self.y+1][self.x].cursor == true then field.cell.params[self.y+1][self.x].cursor = false end
  if field.cell.params[self.y][self.x + 1].op == false then field.cell.params[self.y][self.x + 1].op = true end
  if field.cell.params[self.y + 1][self.x].lit_out == true then field.cell.params[self.y + 1][self.x].lit_out = false end
  -- specific ops cleanup
  if (field.cell[self.y][self.x] == 'P' or field.cell[self.y][self.x] == 'p') then
    local seqlen = tonumber(orca:input(self.x - 1, self.y)) or 1
    for i=0, seqlen do
      field.cell.params[self.y + 1][self.x + i].op = true
      field.cell.params[self.y + 1][self.x + i].lit = false
      field.cell.params[self.y + 1][self.x + i].cursor = false
      field.cell.params[self.y + 1][self.x + i].dot = false
    end
  elseif (field.cell[self.y][self.x] == 'T' or field.cell[self.y][self.x] == 't') then
    local seqlen = tonumber(orca:input(self.x - 1, self.y)) or 1
    field.cell.params[self.y+1][self.x].lit_out  = false
    for i=1, seqlen do
      field.cell.params[self.y][self.x + i].op = true
      field.cell.params[self.y][self.x + i].cursor = false
      field.cell.params[self.y][self.x + i].dot = false
    end
  elseif (field.cell[self.y][self.x] == 'K' or field.cell[self.y][self.x] == 'k') then
    local seqlen = tonumber(orca:input(self.x - 1, self.y)) or 1
    for i=1,seqlen do
      field.cell.params[self.y][self.x + i].dot = false
      field.cell.params[self.y][(self.x + i)].op = true
      field.cell.params[self.y][(self.x + i)].act = true
      field.cell.params[self.y + 1][(self.x + i)].act = true
    end
  elseif (field.cell[self.y][self.x] == 'L' or field.cell[self.y][self.x] == 'l') or (field.cell[self.y][self.x] == 'G' or field.cell[self.y][self.x] == 'g') then
    local seqlen = tonumber(orca:input(self.x - 1, self.y)) or 1
    for i=1,seqlen do
      field.cell.params[self.y][self.x + i].dot = false
      field.cell.params[self.y][(self.x + i)].op = true
    end
  elseif (field.cell[self.y][self.x] == 'U' or field.cell[self.y][self.x] == 'u') or 
    (field.cell[self.y][self.x] == 'D' or field.cell[self.y][self.x] == 'd') or 
    (field.cell[self.y][self.x] == 'F' or field.cell[self.y][self.x] == 'f') then
    if field.cell[self.y + 1][self.x] == '*' then field.cell[self.y + 1][self.x] = 'null' end
  elseif (field.cell[self.y][self.x] == 'H' or field.cell[self.y][self.x] == 'h') then
    field.cell.params[self.y + 1][self.x].act = true
  elseif (field.cell[self.y][self.x] == 'X' or field.cell[self.y][self.x] == 'x') then
    local a = tonumber(field.cell[self.y][self.x - 2]) or 0 -- x
    local b = util.clamp(tonumber(field.cell[self.y][self.x - 1]) or 1, 1, 9) -- y
    field.cell.params[self.y + b][self.x + a].dot_cursor = false
    field.cell.params[self.y + b][self.x + a].cursor = false
    field.cell.params[self.y + b][self.x + a].placeholder = nil
  elseif (field.cell[self.y][self.x] == "'" or field.cell[self.y][self.x] == ':' or field.cell[self.y][self.x] == '/') then
    if field.cell[self.y][self.x] == '/' then softcut.play((field.cell[self.y][self.x + 1] == 0 and 1 or field.cell[self.y][self.x + 1]),0) end
    if field.cell[self.y][self.x] == "'" then local sample = orca:input(self.x + 1, self.y) or 0 engine.noteOff(sample) end

  end 
end

function orca:erase(x,y)
  self.x = x
  self.y = y
  if self:active() then 
    self:cleanup() 
  end
  orca:remove_from_queue(self.x,self.y)  
  self:replace('null')
end

function orca:explode()
  self:replace('*')
  self:add_to_queue(self.x,self.y)
end

function orca:id(x, y)
  return tostring(x .. ":" .. y)
end

function orca:add_to_queue(x,y)
  x = util.clamp(x,1,XSIZE + 1)
  y = util.clamp(y,1,YSIZE + 1)
  field.active[orca:id(x,y)] = {x, y, field.cell[y][x]}
end

function orca.removeKey(t, k_to_remove)
  local new = {}
  for k, v in pairs(t) do
    new[k] = v
  end
  new[k_to_remove] = nil
  return new
end


function orca:remove_from_queue(x,y)
  self.x = x
  self.y = y
  field.active = orca.removeKey(field.active, orca:id(self.x,self.y))
end

function orca:exec_queue()
  frame = (frame + 1) % 99999
  for k,v in pairs(field.active) do
    if k ~= nil then
    local x = util.clamp(field.active[k][1],1,XSIZE)
    local y = util.clamp(field.active[k][2],1,YSIZE)
    local op = field.active[k][3]
    if op == orca.list[string.upper(op)] and orca.is_op(x,y) then
      operators[op](self, x, y, frame, field.cell) 
    end
    end
  end
end

function orca:move(x,y)
  a = self.y + y
  b = self.x + x
  local collider = field.cell[a][b]
  -- collide rules
  if collider ~= 'null'  then
    if field.cell[a][b] ~= nil then
      if collider == '*' then
        orca:move_cell(b,a)
        self:erase(self.x,self.y)
      elseif field.cell.params[a][b].op == false or (collider == '.' and field.cell.params[a][b].op == false) then
        orca:move_cell(b,a)
      elseif (
        (collider == '.' and field.cell.params[a][b].op == true)
        or
        collider == field.cell[self.y][self.x]
        or
        (orca:active() and orca.list[string.upper(field.cell[a][b])])
        or
        collider == tonumber(collider)
        or
        collider ~= orca.is_op(a,b)
        or
        orca.is_bang(a,b)
        )
      then
        self:explode()
      -- L fix
      elseif field.cell.params[a][b].op == false or (collider == '.' and field.cell.params[a][b].op == false ) then
        orca:move_cell(b,a)
        self:erase(self.x,self.y)
      end
    else
      self:explode()
    end
  else
    orca:move_cell(b,a)
  end
end

function orca:move_cell(x,y)
  field.cell[y][x] = field.cell[self.y][self.x]
  self:erase(self.x,self.y)
  orca:add_to_queue(x,y)
end

function orca:clean_ports(t, x1, y1)
  for i=1,#t do
    if t[i] ~= nil then
      for l=1,#t[i]-2 do
        local x = util.clamp(x1 ~= nil and x1 + t[i][l]  or self.x + t[i][l],1,XSIZE)
        local y = util.clamp(y1 ~= nil and y1 + t[i][l+1] or self.y + t[i][l+1],1,XSIZE)
        field.cell.params[self.y][self.x].lit = false
        if field.cell[y][x] ~= nil then
          if t[i][l + 2] == 'output' then
            field.cell.params[y][x].lit_out = false
            field.cell.params[y][x].dot_port = false
          elseif t[i][l + 2] == 'input' then
            field.cell.params[y][x].dot_port = false
          elseif t[i][l + 2] == 'input_op' then
            field.cell.params[y][x].op = true
            field.cell.params[y][x].dot_port = false
          elseif t[i][l + 2] == 'output_op' then
            field.cell.params[y][x].op = true
            field.cell.params[y][x].dot_port = false
            field.cell.params[y][x].lit_out = false
          end
        end
      end
    end
  end
end

function orca:spawn(t)
  for i=1,#t do
    for l= 1, #t[i] - 2 do
      local x = self.x + t[i][l]
      local y = self.y + t[i][l+1]
      local existing = field.cell[y][x] ~= nil and field.cell[y][x] or 'null'
      local port_type = t[i][l + 2]

      if existing == orca.list[string.upper(existing)] then
        orca:clean_ports(orca.ports[existing], x,y)
      end

      -- draw frame
      if field.cell[self.y][self.x] ~= string.lower(field.cell[self.y][self.x]) then
        field.cell.params[self.y][self.x].lit = true
      elseif (field.cell[self.y][self.x] == "'" or field.cell[self.y][self.x]  == ':' or field.cell[self.y][self.x]  == '/') then
        field.cell.params[self.y][self.x].lit = true
      end

      -- draw inputs / outputs
      if field.cell[y][x] ~= nil then
        if port_type == 'output' then
          field.cell.params[y][x].lit_out = true
          field.cell.params[y][x].dot_port = true
        elseif port_type == 'input' then
          field.cell.params[y][x].dot_port = true
        elseif port_type == 'input_op' then
          field.cell.params[y][x].op = false
          field.cell.params[y][x].dot_port = true
          field.cell.params[y][x].lit = false
        elseif port_type == 'output_op' then
          field.cell.params[y][x].lit_out = true
          field.cell.params[y][x].op = false
          field.cell.params[y][x].dot_port = true
        end
      end
    end
  end
end
-----


function init()
  for y = 0,YSIZE + YSIZE do
    field.cell[y] = {}
    field.cell.params[y] = {}
    for x = 0,XSIZE + XSIZE do
      table.insert(field.cell[y], 'null')
      table.insert(field.cell.params[y], {op = true, lit = false, lit_out = false, act = true, cursor = false, dot_cursor = false, dot_port = false, dot = false, placeholder = nil})
    end
  end
  params:add_trigger('save_p', "save project" )
  params:set_action('save_p', function(x) textentry.enter(orca.save_project, 'untitled' ) end)
  params:add_trigger('load_p', "load project" )
  params:set_action('load_p', function(x) fileselect.enter(norns.state.data, orca.load_project) end)
  params:add_trigger('new', "new" )
  params:set_action('new', function(x) init() end)
  params:add_separator()
  params:add_control("EXT", "softcut ext level", controlspec.new(0, 1, 'lin', 0, 1, ""))
  params:set_action("EXT", function(x) audio.level_adc_cut(x) end)
  params:add_control("ENG", "softcut eng level", controlspec.new(0, 1, 'lin', 0, 1, ""))
  params:set_action("ENG", function(x) audio.level_eng_cut(x) end)
  params:add_separator()


  softcut.reset()
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  for i=1,max_sc_ops do
    softcut.level(i,1)
    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
    softcut.pan(i, 0.5)
    softcut.play(i, 0)
    softcut.rate(i, 1)
    softcut.loop_start(i, 0)
    softcut.loop_end(i, #orca.chars + 1)
    softcut.loop(i, 0)
    softcut.rec(i, 0)
    softcut.fade_time(i,0.02)
    softcut.level_slew_time(i,0.01)
    softcut.rate_slew_time(i,0.01)
    softcut.rec_level(i, 1)
    softcut.pre_level(i, 1)
    softcut.position(i, 0)
    softcut.buffer(i,1)
    softcut.enable(i, 1)
    softcut.filter_dry(i, 1);
    softcut.filter_fc(i, 0);
    softcut.filter_lp(i, 0);
    softcut.filter_bp(i, 0);
    softcut.filter_rq(i, 0);
  end
  redraw_metro = metro.init(function(stage) redraw() end, 1/30)
  redraw_metro:start()
  clk.on_step = function() orca:exec_queue() end
  clk:add_clock_params()
  params:set("bpm", 120)
  clk:start()
  notes_off_metro.event = all_notes_off
  params:add_separator()


  Timber.add_params()
  for i = 0, NUM_SAMPLES - 1 do
    local extra_params = {
      {type = "option", id = "launch_mode_" .. i, name = "Launch Mode", options = {"Gate", "Toggle"}, default = 1, action = function(value)
        Timber.setup_params_dirty = true
      end},
    }
    params:add_separator()
    Timber.add_sample_params(i, true, extra_params)
    params:set("play_mode_" .. i, 4) -- set all to 1-shot 
  end



  params:add_separator()
  midi_out_device = midi.connect(1)
  midi_out_device.event = function() end
  params:add{type = "number", id = "midi_out_device", name = "midi out device",
  min = 1, max = 4, default = 1,
  action = function(value) midi_out_device = midi.connect(value) end}
end

local function get_key(code, val, shift)
  if keycodes.keys[code] ~= nil and val == 1 then
    if (shift) then
      if keycodes.shifts[code] ~= nil then
        return(keycodes.shifts[code])
      else
        return(keycodes.keys[code])
      end
    else
      return(string.lower(keycodes.keys[code]))
    end
  elseif keycodes.cmds[code] ~= nil and val == 1 then
    if (code == hid.codes.KEY_ENTER) then
      -- enter 
    end
  end
end

local function update_offset()
    if x_index < bounds_x + (field_offset_x - 24)  then 
      field_offset_x =  util.clamp(field_offset_x - 1,0,XSIZE - field_offset_x) 
    elseif x_index > field_offset_x + 25  then 
      field_offset_x =  util.clamp(field_offset_x + 1,0,XSIZE - bounds_x) 
    end
    if y_index  > field_offset_y + (bar and 7 or 8)   then 
        field_offset_y =  util.clamp(field_offset_y + 1,0,YSIZE - bounds_y) 
      elseif y_index < bounds_y + (field_offset_y - 7)  then 
      field_offset_y = util.clamp(field_offset_y - 1,0,YSIZE - bounds_y)
    end
end


function keyb.event(typ, code, val)
   --print("hid.event ", typ, code, val)
  if ((code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 1 or val == 2)) then
    shift  = true;
  elseif (code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 0) then
    shift = false;
  elseif (code == hid.codes.KEY_BACKSPACE or code == hid.codes.KEY_DELETE) then
    orca:erase(x_index,y_index)
  elseif (code == hid.codes.KEY_LEFT) and (val == 1 or val == 2) then
    if shift then selected_area_x = util.clamp(selected_area_x - 1,1,XSIZE) else x_index = util.clamp(x_index -1,1,XSIZE) end
    update_offset()
  elseif (code == hid.codes.KEY_RIGHT) and (val == 1 or val == 2) then
    if shift then selected_area_x = util.clamp(selected_area_x + 1,1,XSIZE) else x_index = util.clamp(x_index + 1,1,XSIZE) end
    update_offset()
  elseif (code == hid.codes.KEY_DOWN) and (val == 1 or val == 2) then
    if shift then selected_area_y = util.clamp(selected_area_y + 1,1,YSIZE) else y_index = util.clamp(y_index + 1,1,YSIZE) end
    update_offset()
  elseif (code == hid.codes.KEY_UP) and (val == 1 or val == 2) then
    if shift then selected_area_y = util.clamp(selected_area_y - 1,1,YSIZE) else y_index = util.clamp(y_index - 1 ,1,YSIZE) end
    update_offset()
  elseif (code == hid.codes.KEY_TAB and val == 1) then
    bar = not bar
  elseif (code == 41 and val == 1) then
    help = not help
  -- bypass crashes  -- 2do F1-F12 (59-68, 87,88)
  elseif (code == 26 and val == 1) then
    field_grid = util.clamp(field_grid - 1, 1, 8)
  elseif (code == 27 and val == 1) then
    field_grid = util.clamp(field_grid + 1, 1, 8)
  elseif (code == hid.codes.KEY_102ND and val == 1) then
  elseif (code == hid.codes.KEY_ESC and val == 1) then
    selected_area_y = 1
    selected_area_x = 1
  elseif (code == hid.codes.KEY_ENTER and val == 1) then

  elseif (code == hid.codes.KEY_LEFTALT and val == 1) then
  elseif (code == hid.codes.KEY_RIGHTALT and val == 1) then
  elseif (code == hid.codes.KEY_LEFTCTRL and (val == 1 or val == 2)) then
    ctrl = true
  elseif (code == hid.codes.KEY_LEFTCTRL and val == 0) then
    ctrl = false
  elseif (code == hid.codes.KEY_RIGHTCTRL and (val == 1 or val == 2)) then
    ctrl = true
  elseif (code == hid.codes.KEY_RIGHTCTRL and val == 0) then
    ctrl = false
  elseif (code == hid.codes.KEY_DELETE and val == 1) then
  elseif (code == hid.codes.KEY_CAPSLOCK and val == 1) then
     map = not map
  elseif (code == hid.codes.KEY_NUMLOCK and val == 1) then
  elseif (code == hid.codes.KEY_SCROLLLOCK and val == 1) then
  elseif (code == hid.codes.KEY_SYSRQ and val == 1) then
  elseif (code == hid.codes.KEY_HOME and val == 1) then
  elseif (code == hid.codes.KEY_PAGEUP and val == 1) then
  elseif (code == hid.codes.KEY_DELETE and val == 1) then
  elseif (code == hid.codes.KEY_END and val == 1) then
  elseif (code == hid.codes.KEY_PAGEUP and val == 1) then
  elseif (code == hid.codes.KEY_PAGEDOWN and val == 1) then
  elseif (code == hid.codes.KEY_INSERT and val == 1) then
  elseif (code == hid.codes.KEY_END and val == 1) then
  elseif (code == hid.codes.KEY_LEFTMETA and val == 1) then
  elseif (code == hid.codes.KEY_RIGHTMETA and val == 1) then
  elseif (code == hid.codes.KEY_COMPOSE and val == 1) then
  elseif (code == 119 and val == 1) then
  elseif ((code == 88 or code == 87) and val == 1) then
  elseif (code == hid.codes.KEY_SPACE) and (val == 1) then
    if clk.playing then
      clk:stop()
      engine.noteKillAll()
      for i=1,max_sc_ops do
        softcut.play(i,0)
      end
    else
      frame = 0
      clk:start()
    end
  else
    if val == 1 then
      keyinput = get_key(code, val, shift)
      if not ctrl then
        if orca.is_op(x_index,y_index) then
          orca:erase(x_index,y_index)
        elseif orca.list[string.upper(keyinput)] == 'H' or orca.list[string.upper(keyinput)] == 'h' then
        elseif orca.is_op(x_index, y_index - 1) then
        elseif orca.is_op(x_index,y_index + 1) then
          if orca.list[string.upper(keyinput)] == keyinput then
            -- remove southward op if new one have output
            for i = 1,#orca.ports[string.upper(keyinput)] do
              if orca.ports[string.upper(keyinput)][i][2] == 1 then
                orca:erase(x_index,y_index + 1)
              else
                orca:erase(x_index,y_index)
              end
            end
          end 
        elseif (orca.is_op(x_index,y_index - 1) and tonumber(field.cell[y_index][x_index])) then
        end
        field.cell[y_index][x_index] = keyinput
        orca:add_to_queue(x_index,y_index)
      end
    elseif ctrl then 
      if code == 45 then -- cut
        orca.cut_area()
      elseif code == 46 then -- copy
        orca.copy_area()
      elseif code == 47 then -- paste
        orca.paste_area()
      end
    end
  end
end


local function draw_op_frame(x,y)
  screen.level(4)
  screen.rect((x * 5)-5, ((y*8) - 5) - 3, 5,8)
  screen.fill()
end

local function draw_op_out(x,y)
  if field.cell.params[y][x].act then
    screen.level(1)
    screen.rect((x * 5)-5, ((y*8) - 5) - 3, 5,8)
    screen.fill()
  end
end

local function draw_op_cursor(x,y)
  screen.level(1)
  screen.rect((x * 5)-5, ((y*8) - 5) - 3, 5,8)
  screen.fill()
end


local function draw_grid()
  screen.font_face(25)
  screen.font_size(6)
  for y= 1, bounds_y do
    for x = 1,bounds_x do
      local y = y + field_offset_y
      local x = x + field_offset_x
      if field.cell.params[y][x].lit then
        draw_op_frame(x - field_offset_x,y - field_offset_y)
      end
      if field.cell.params[y][x].cursor then
        draw_op_cursor(x - field_offset_x,y - field_offset_y)
      end
      if field.cell.params[y][x].lit_out then
        draw_op_out(x - field_offset_x,y - field_offset_y)
      end
      -- levels
      if field.cell[y][x] ~= 'null' then
        if orca.is_op(x,y) then
          screen.level(15)
        elseif field.cell.params[y][x].lit then
          screen.level(12)
        elseif field.cell.params[y][x].cursor then
          screen.level(12)
        elseif field.cell.params[y][x].lit_out then
          screen.level(12)
        elseif field.cell.params[y][x].dot_port then
          screen.level(9)
        elseif field.cell.params[y][x].dot_cursor then
          screen.level(12)
        elseif field.cell.params[y][x].dot then
          screen.level(5)
        else
          screen.level(3)
        end
      elseif field.cell[y][x] == 'null' then
        if field.cell.params[y][x].dot_port then
          screen.level(9)
        elseif field.cell.params[y][x].dot_cursor then
          screen.level(12)
        elseif field.cell.params[y][x].dot then
          screen.level(5)
        elseif field.cell.params[y][x].placeholder ~= nil then
          screen.level(12)
        else
          screen.level(1)
        end
      end
      screen.move(((x - field_offset_x) * 5) - 4 , ((y - field_offset_y )* 8) - (field.cell[y][x] and 2 or 3))
      --
      if field.cell[y][x] == 'null' or field.cell[y][x] == nil then
        if field.cell.params[y][x].dot_port then
          screen.text('.')
        elseif field.cell.params[y][x].dot_cursor then
          screen.text('.')
        elseif field.cell.params[y][x].dot then
          screen.text('.')
        elseif field.cell.params[y][x].placeholder ~= nil then
          screen.text(field.cell.params[y][x].placeholder)
        else
          screen.text( (x % field_grid == 0 and y % util.clamp(field_grid - 1,1,8) == 0) and  '.' or '')
        end
      else
        screen.text(field.cell[y][x])
      end
      screen.stroke()
    end
  end
end

local function draw_area(x,y)
  local x_pos = (((x - field_offset_x) * 5) - 5) 
  local y_pos = (((y - field_offset_y) * 8) - 8)
  screen.level(2)
  screen.rect(x_pos,y_pos, 5 * selected_area_x , 8 * selected_area_y )
  screen.fill()
end

local function draw_cursor(x,y)
  local x_pos = ((x * 5) - 5) 
  local y_pos = ((y * 8) - 8)
  local x_index = x + field_offset_x
  local y_index = y + field_offset_y
  if field.cell[y_index][x_index] == 'null' then
  screen.level(2)
  screen.rect(x_pos,y_pos, 5, 8)
  screen.fill()
    screen.move(x_pos,y_pos+6)
    screen.level(14)
    screen.font_face(0)
    screen.font_size(8)
    screen.text('@')
    screen.stroke()
  elseif field.cell[y_index][x_index] ~= 'null'  then
    screen.level(15)
    screen.rect(x_pos,y_pos,5 , 8)
    screen.fill()
    screen.move(x_pos + 1,y_pos+6)
    screen.level(1)
    screen.font_face(25)
    screen.font_size(6)
    screen.text(field.cell[y_index][x_index])
    screen.stroke()
  end
end

local function draw_bar()
  screen.level(0)
  screen.rect(0,56,128,8)
  screen.fill()
  screen.level(15)
  screen.move(2,63)
  screen.font_face(25)
  screen.font_size(6)
  screen.text(frame .. 'f')
  screen.stroke()
  screen.move(40,63)
  screen.text_center(field.cell[y_index][x_index] and orca.names[string.upper(field.cell[y_index][x_index])] or 'empty')
  screen.stroke()
  screen.move(75,63)
  screen.text(params:get("bpm") .. (frame % 4 == 0 and ' *' or ''))
  screen.stroke()
  screen.move(123,63)
  screen.text_right(x_index .. ',' .. y_index)
  screen.stroke()
end



--- wip 

local function draw_help()
  if orca.info[string.upper(field.cell[y_index][x_index])] then
    screen.level(15)
    screen.rect(0,29,128,25)
    screen.fill()
    screen.level(0)
    screen.rect(1,30,126,23)
    screen.fill()
    if bar then
      screen.level(15)
      screen.move(36,53)
      screen.line_rel(4,4)
      screen.move(44,53)
      screen.line_rel(-4,4)
      screen.stroke()
      screen.level(0)
      screen.move(37,54)
      screen.line_rel(6,0)
      screen.stroke()
    end
    screen.font_face(25)
    screen.font_size(6)
    if orca.info[string.upper(field.cell[y_index][x_index])] then
      local s = orca.info[string.upper(field.cell[y_index][x_index])]
      local description = tab.split(s, ' ')
      screen.level(9)
      screen.move(3,38)
      local y = 40
      for i = 1, #description do
        screen.text(description[i] .. " ")
        if i == 4 or i == 9 then
          y = y + 8
          lenl = 0
          screen.move(3,y)
        end
      end
      screen.stroke()
    end
  else
  end
end

local function draw_map()
    -- window
  screen.level(15)
  screen.rect(4,5,120,55)
  screen.fill()
  screen.level(0)
  screen.rect(5,6,118,53)
  screen.fill()
    
  for y = 1, YSIZE do
    for x = 1, XSIZE do
      if field.cell[y][x] ~= 'null' then
      screen.level(1)
      screen.rect(((x / XSIZE ) * 114) + 5, ((y / YSIZE) * 48) + 7, 3,3 )
      screen.fill()
      end
      if field.cell.params[y][x].lit then
      screen.level(4)
      screen.rect(((x / XSIZE ) * 114) + 5, ((y / YSIZE) * 48) + 7, 3,3 )
      screen.fill()
      end
    end
  end
  screen.level(2)
  screen.rect((((util.clamp(x_index,1,78) / XSIZE) ) * 114) + 5, ((util.clamp(y_index,2,28) / YSIZE) * 48) + 5, (bounds_x / XSIZE) * 114 ,(bounds_y / YSIZE) * 48 )
  screen.stroke()
  screen.level(15)
  screen.rect(((x_index / XSIZE ) * 114) + 5, ((y_index / YSIZE) * 48) + 7, 1,1 )
  screen.fill()
end

function enc(n,d)
  if n == 2 then
   x_index = util.clamp(x_index + d, 1, XSIZE)
  elseif n == 3 then
   y_index = util.clamp(y_index + d, 1, YSIZE)
  end
  update_offset()
end

function redraw()
  screen.clear()
  draw_area(x_index, y_index)
  draw_grid()
  draw_cursor(util.clamp(x_index - field_offset_x,1,XSIZE), util.clamp(y_index - field_offset_y, 1, YSIZE))
  if bar then draw_bar() else  end
  if help then draw_help() else end
  if map then draw_map() else end
  screen.update()
end