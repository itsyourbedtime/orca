-- ORCA
-- v0.9.1 @its_your_bedtime
-- llllllll.co/t/orca

local tab = require 'tabutil'
local fileselect = require "fileselect"
local textentry = require "textentry"
local beatclock = require 'beatclock'
local keycodes = include("lib/keycodes")
local transpose_table = include("lib/transpose")
local operators = include("lib/library")
local orca_softcut = include("lib/sc")
local orca_engine = include("lib/engine")
local keyb = hid.connect(2)
local keyinput = ""
local x_index, y_index, field_offset_x, field_offset_y = 1, 1, 0, 0
local selected_area_y, selected_area_x = 1, 1
local bounds_x, bounds_y = 25, 8
local bar, help, map = false
local dot_density, frame = 1, 1
local copy_buffer = {cell = {}}
local keyb_layout = 1 -- PC
g = grid.connect()
local field = { 
  project = 'untitled',
  active = {},
  cell = {
    params = {},
    vars = {},
    active_notes = {},
    grid = {},
    sc_ops = {},  
    sc_ops_pos = {0, 0, 0, 0, 0, 0},
    etc = {}
  },
}

local orca = {
  XSIZE = 101,
  YSIZE = 41,
  bounds_x = bounds_x,
  bounds_y = bounds_y,
  music = require 'musicutil',
  clk = beatclock.new(),
  sc_ops = 0,
  max_sc_ops = 6,
  info = include("lib/library/__info"),
  list = include("lib/library/__all"),
  ports = include("lib/library/__ports"),
  chars = include("lib/chars"),
  notes = {"C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B"},
}

function orca.sc_clear_region(p, l)
  softcut.buffer_clear_region(field.cell.sc_ops_pos[p], l)
end

function orca.copy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do
    res[simplecopy(k)] = simplecopy(v)
  end
  return res
end

function orca:add_note(ch, note, length)
  local id = self:id(self.x,self.y) 
  if field.cell.active_notes[id] == nil then 
    field.cell.active_notes[id] = {}
  end
  if field.cell.active_notes[id][note] == {note, length} then
    orca.midi_out_device:note_off(note, nil, ch)
  end
  field.cell.active_notes[id][note] = {note, length}
end

function orca:add_note_mono(ch, note, length)
  local id = self:id(self.x,self.y) 
  if field.cell.active_notes[id] == nil then 
    field.cell.active_notes[id] = {}
  end
  field.cell.active_notes[id][ch] = {note, length}
end

function orca:notes_off(ch)
  local id = self:id(self.x,self.y)
  if field.cell.active_notes[id] ~= nil then
    for k, v in pairs(field.cell.active_notes[id]) do
      local note = field.cell.active_notes[id][k][1]
      local length = util.clamp(field.cell.active_notes[id][k][2], 1, #orca.chars)
      if frame % length  == 0 then 
        orca.midi_out_device:note_off(note, nil, ch)
        field.cell.active_notes[id][k] = nil
      end
    end
  end
end

function orca.load_project(pth)
  if string.find(pth, 'orca') ~= nil then
    local saved = tab.load(pth)
    if saved ~= nil then
      print("data found")
      field = saved
      local name = string.sub(string.gsub(pth, '%w+/',''),2,-6)
      field.project = name 
      softcut.buffer_read_mono(norns.state.data .. name .. '_buffer.aif', 0, 0, #orca.chars, 1, 1)
      params:read(norns.state.data .. name ..".pset")
      print ('loaded ' .. norns.state.data .. name .. '_buffer.aif')
    else
      print("no data")
    end
  end
end

function orca.save_project(txt)
  if txt then
    field.project = txt
    tab.save(field, norns.state.data .. txt ..".orca")
    softcut.buffer_write_mono(norns.state.data..txt .."_buffer.aif",0,#orca.chars, 1)
    params:write(norns.state.data .. txt .. ".pset")
    print ('saved ' .. norns.state.data .. txt .. '_buffer.aif')
  else
    print("save cancel")
  end
end

function orca.copy_area()
  for y=y_index, y_index + selected_area_y do
    copy_buffer.cell[y -  y_index ] = {}
    for x = x_index, x_index + selected_area_x do
      copy_buffer.cell[y -  y_index ][x -  x_index ] = orca.copy(field.cell[y][x])
    end
  end
end

function orca.cut_area()
  for y=y_index, y_index +  selected_area_y do
    copy_buffer.cell[util.clamp(y -  y_index, 0, orca.YSIZE) ] = {}
    for x = x_index, x_index + selected_area_x do
      local to_copy = orca.copy(field.cell[y][x])
      orca:erase(x, y)
      copy_buffer.cell[y -  y_index ][x -  x_index ] = to_copy
    end
  end
end

function orca.paste_area()
  for y=0, #copy_buffer.cell - 1 do
    for x = 0, #copy_buffer.cell[y] do
      orca:erase(util.clamp(x_index + x, 0, orca.XSIZE), util.clamp(y_index + y, 0, orca.YSIZE))
      field.cell[y_index + y][(x_index + x)] = orca.copy(copy_buffer.cell[y][x])
      orca:add_to_queue(x_index + x, y_index + y)
    end
  end
end

function orca.normalize(n)
  return n == 'e' and 'F' or n == 'b' and 'C' or n
end

function orca.transpose(n, o)
  if n == nil or n == 'null' then n = 'C' else n = tostring(n) end 
  if o == nil or o == 'null' then o = 3 end
  local note = orca.normalize(string.sub(transpose_table[n], 1, 1))
  local octave = util.clamp(orca.normalize(string.sub(transpose_table[n], 2)) + o,0,8)
  local value = tab.key(orca.notes, note)
  local id = math.ceil( util.clamp((octave * 12) + value, 0, 127) - 1)
  return {id, value, note, octave, orca.music.note_num_to_name(id)}
end

function orca:listen(x,y)
  local value = string.lower(tostring(field.cell[y][x]))
  return (value ~= nil and value ~= 'null') and tab.key(orca.chars, value) or value == 0 and 0 or false
end 

function orca.is_op(x,y)
  --local x = util.clamp(x, 1, orca.XSIZE)
  --local y = util.clamp(y, 1, orca.YSIZE)
  local cell = field.cell[y][x]
  local lock = field.cell.params[y][x].lock
  if orca.list[string.upper(cell)] and lock == false then
    return true
  else
    return false
  end
end

function orca.banged(x,y)
  local x = util.clamp(x, 0, orca.XSIZE)
  local y = util.clamp(y, 0, orca.YSIZE)
  if field.cell[y][x - 1] == '*' then
    field.cell.params[y][x].lit = false
    return true
  elseif field.cell[y][x + 1] == '*' then
    field.cell.params[y][x].lit = false
    return true
  elseif field.cell[y - 1][x] == '*' then
    field.cell.params[y][x].lit = false
    return true
  elseif field.cell[y + 1][x] == '*' then 
    field.cell.params[y][x].lit = false
    return true
  else
    if field.cell[y][x] == string.upper(field.cell[y][x]) then
      field.cell.params[y][x].lit = true
    end
    return false
  end
end

function orca:active()
  local cell = field.cell[self.y][self.x]
  if cell == string.upper(cell) then
    return true
  elseif cell == string.lower(cell) then
    return false
  end
end

function orca:replace(i)
  field.cell[self.y][self.x] = i
end

function orca:shift(s, e)
  local data = field.cell[self.y][self.x + s]
  local params = field.cell.params[self.y][self.x + s]
  table.remove(field.cell[self.y], self.x + s)
  table.remove(field.cell.params[self.y], self.x + s)
  table.insert(field.cell[self.y], self.x + e, data)
  table.insert(field.cell.params[self.y], self.x + e, params)
end

function orca:cleanup()
  local cell = field.cell[self.y][self.x]
  local params = field.cell.params
  local ops_to_clear = {P = true , p = true , L = true, l = true, T = true, t = true, G = true, g = true, K = true, k = true}
  params[self.y][self.x] = {lit = false, lit_out = false, lock = false, cursor = false, dot = false}
  if orca.is_op(self.x,self.y) then self:clean_ports(orca.ports[string.upper(field.cell[self.y][self.x])]) end
  if field.cell[self.y + 1][self.x] == '*' then field.cell[self.y + 1][self.x] = 'null' end
  if ops_to_clear[cell] then
    local offset = (cell == 'P' or cell == 'p') and 1 or 0 
    local seqlen = orca:listen(self.x - 1, self.y) or 1
    for i=0, seqlen do
      params[self.y + offset][(self.x + i)] = {lit = false, lit_out = false, lock = false, cursor = false, dot = false}
      if self.is_op((self.x + i), self.y + offset) then 
        self:add_to_queue(self.x + i, self.y) 
      end
    end
  elseif cell == '<' then
    local col = util.clamp(self:listen( self.x - 2, self.y ) or 0 % g.cols, 1, g.cols)
    local row = util.clamp(self:listen( self.x - 1, self.y ) or 0 % g.rows, 1, g.rows)
  elseif cell == '#' then
    for i = self.x, orca.XSIZE do params[self.y][i].lock = false params[self.y][i].dot = false end
  elseif cell == '/' then 
    softcut.play(orca:listen(self.x + 1, self.y) or 1, 0) 
    orca.sc_ops = util.clamp(orca.sc_ops - 1, 1, orca.max_sc_ops)
  end
end

function orca:erase(x, y)
  self.x = x
  self.y = y
  if self:active() then self:cleanup() end
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
  local x = util.clamp(x, 0, orca.XSIZE)
  local y = util.clamp(y, 0, orca.YSIZE)
  local id = orca:id(x ,y)
  if orca.is_op(x, y) then
    field.active[id] = {x, y, field.cell[y][x]}
  end
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
  local id = orca:id(self.x,self.y)
  field.active = orca.removeKey(field.active, id)
end

function orca:exec_queue()
  frame = (frame + 1) % 99999
  for k,v in pairs(field.active) do
    if v ~= nil then 
      local y = field.active[k][2]
      local x = field.active[k][1]
      local op = field.active[k][3]
      if (string.upper(op) == orca.list[string.upper(op)] and orca.is_op(x,y)) then
        operators[string.upper(op)](self, x, y, frame, field.cell) 
      end
    end
  end
end

function orca:move_cell(x,y)
  field.cell[y][x] = field.cell[self.y][self.x]
  self:erase(self.x,self.y)
  orca:add_to_queue(x,y)
end

function orca:move(x,y)
  local a = util.clamp(self.y + y, 1, orca.YSIZE)
  local b = util.clamp(self.x + x, 1, orca.XSIZE)
  local collider = field.cell[a][b]
  -- collide rules
  if collider ~= 'null'  then
    if field.cell[a][b] ~= nil then
      if collider == '*' then
        orca:move_cell(b,a)
        self:erase(self.x,self.y)
      elseif orca.is_op(b, a) then
        self:explode()
      elseif field.cell.params[a][b].lock then
        self:explode()
      end
    else
      self:explode()
    end
  else
    orca:move_cell(b,a)
  end
end


function orca:clean_ports(t, x1, y1)
  if t ~= nil then
    for i=1,#t do
        for l=1,#t[i]-2 do
          local x = x1 ~= nil and x1 + t[i][l]  or self.x + t[i][l]
          local y = y1 ~= nil and y1 + t[i][l + 1] or self.y + t[i][l+1]
          local is_op = orca.is_op(x, y)
            if t[i][l + 2] == 'output' then
              field.cell.params[y][x].lit_out = false
              field.cell.params[y][x].lit = false
              field.cell.params[y][x].dot = false
            elseif t[i][l + 2] == 'input' then
              field.cell.params[y][x].dot = false
              field.cell.params[y][x].lit = false
            elseif t[i][l + 2] == 'input_op' then
              field.cell.params[y][x].lit = false
              field.cell.params[y][x].lock = false
              field.cell.params[y][x].dot = false
              self:add_to_queue(x, y) 
            elseif t[i][l + 2] == 'output_op' then
              field.cell.params[y][x].lit = false
              field.cell.params[y][x].lock = false
              field.cell.params[y][x].dot = false
              field.cell.params[y][x].lit_out = false
              self:add_to_queue(x, y)
            end
          end
    end
  end
end

function orca:spawn(t)
  field.cell.params[self.y][self.x].lit = true
  for i=1,#t do
    for l= 1, #t[i] - 2 do
      local x = util.clamp(self.x + t[i][l], 0, orca.XSIZE)
      local y = util.clamp(self.y + t[i][l+1], 0, orca.YSIZE)
      local existing = field.cell[y][x]
      local port_type = t[i][l + 2]
      local out = t[i][2] == 1 and true or false
      
      if existing ~= 'null' then 
        if field.cell.params[y][x].lock == false then
          orca:clean_ports(orca.ports[existing], x, y)
        end
      end
      if field.cell[y][x] ~= nil then
        if port_type == 'output' then
          field.cell.params[y][x].lit_out = true
          field.cell.params[y][x].dot = true
        elseif port_type == 'input' then
          field.cell.params[y][x].dot = true
        elseif port_type == 'input_op' then
          field.cell.params[y][x].lock = true
          field.cell.params[y][x].dot = true
          field.cell.params[y][x].lit = false
        elseif port_type == 'output_op' then
          field.cell.params[y][x].lit_out = true
          field.cell.params[y][x].lock = true
          field.cell.params[y][x].dot = true
        end
      end
    end
  end
end

function init()
  -- field 
  for y = 0, orca.YSIZE + orca.YSIZE do
    field.cell[y] = {}
    field.cell.params[y] = {}
    for x = 0,orca.XSIZE + orca.XSIZE do
      table.insert(field.cell[y], 'null')
      table.insert(field.cell.params[y], {lit = false, lit_out = false, lock = false, cursor = false, dot = false})
    end
  end
  -- grid 
  for i = 1, g.rows do
    field.cell.grid[i] = {}
  end
  -- ops exec 
  orca.clk.on_step = function() orca:exec_queue() end,
  orca.clk:add_clock_params()
  orca.clk:start()
  -- params
  params:add{
    type = "number", id = "keyb_layout", 
    name = "Keyboard", min = 1, max = 2, default = 1,
    action = function(value) keyb_layout = value end 
  }
  params:set("bpm", 120)
  params:add_separator()
  params:add_trigger('save_p', "< Save project" )
  params:set_action('save_p', function(x) textentry.enter(orca.save_project,  field.project) end)
  params:add_trigger('load_p', "> Load project" )
  params:set_action('load_p', function(x) fileselect.enter(norns.state.data, orca.load_project) end)
  params:add_trigger('new', "+ New" )
  params:set_action('new', function(x) init() end)
  params:add_separator()
  params:add_control("EXT", "/ External level", controlspec.new(0, 1, 'lin', 0, 1, ""))
  params:set_action("EXT", function(x) audio.level_adc_cut(x) end)
  params:add_control("ENG", "/ Engine level", controlspec.new(0, 1, 'lin', 0, 1, ""))
  params:set_action("ENG", function(x) audio.level_eng_cut(x) end)
  params:add_separator()
  orca_softcut.init()
  orca_engine.init()
  -- midi
  params:add_separator()
  orca.midi_out_device = midi.connect(1)
  orca.midi_out_device.event = function() end
  params:add{
    type = "number", id = "midi_out_device", 
    name = "midi out device", min = 1, max = 4, default = 1,
    action = function(value) orca.midi_out_device = midi.connect(value) end 
  }
  -- redraw metro
  redraw_metro = metro.init(function(stage) redraw() g:redraw() end, 1/30)
  redraw_metro:start()
end

local function update_offset()
  if x_index < bounds_x + (field_offset_x - 24)  then 
    field_offset_x =  util.clamp(field_offset_x - 1,0,orca.XSIZE - field_offset_x) 
  elseif x_index > field_offset_x + 25  then 
    field_offset_x =  util.clamp(field_offset_x + 1,0,orca.XSIZE - bounds_x) 
  end
  if y_index  > field_offset_y + (bar and 7 or 8)   then 
      field_offset_y =  util.clamp(field_offset_y + 1,0,orca.YSIZE - bounds_y) 
    elseif y_index < bounds_y + (field_offset_y - 7)  then 
    field_offset_y = util.clamp(field_offset_y - 1,0,orca.YSIZE - bounds_y)
  end
end

local function get_key(code, val, shift)
  if keycodes.keys[code] ~= nil and val == 1 then
    if shift then
      if keycodes.shifts[code] ~= nil then
        return keycodes.shifts[code]
      else
        return keycodes.keys[code]
      end
    else
      return string.lower(keycodes.keys[code])
    end
  end
end

function keyb.event(typ, code, val)
  local menu = norns.menu.status()
  local CTRLCMD 
  if (keyb_layout == 2) then
    CTRLCMDLEFT = hid.codes.KEY_LEFTMETA
    CTRLCMDRIGHT = hid.codes.KEY_RIGHTMETA
  else
    CTRLCMDLEFT = hid.codes.KEY_LEFTCTRL
    CTRLCMDRIGHT = hid.codes.KEY_RIGHTCTRL
  end
   --print("hid.event ", typ, code, val)
  if ((code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 1 or val == 2)) then
    shift  = true;
  elseif (code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 0) then
    shift = false;
    elseif ((code == CTRLCMDLEFT or code == CTRLCMDRIGHT) and (val == 1 or val == 2)) then
    ctrl = true
  elseif ((code == CTRLCMDLEFT or code == CTRLCMDRIGHT) and val == 0) then
    ctrl = false
  elseif (code == hid.codes.KEY_BACKSPACE or code == hid.codes.KEY_DELETE) then
    orca:erase(x_index,y_index)
  elseif (code == hid.codes.KEY_LEFT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x - 1,1,orca.XSIZE) else x_index = util.clamp(x_index -1,1,orca.XSIZE) end
      update_offset()
    elseif menu then
      norns.enc(3, shift and -20 or -2)
    end
  elseif (code == hid.codes.KEY_RIGHT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x + 1,1,orca.XSIZE) else x_index = util.clamp(x_index + 1,1,orca.XSIZE) end
      update_offset()
    elseif menu then
      norns.enc(3, shift and 20 or 2)
    end
  elseif (code == hid.codes.KEY_DOWN) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y + 1,1,orca.YSIZE) else y_index = util.clamp(y_index + 1,1,orca.YSIZE) end
      update_offset()
    elseif menu then
      norns.enc(2, shift and 104 or 2)
    end
  elseif (code == hid.codes.KEY_UP) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y - 1,1,orca.YSIZE) else y_index = util.clamp(y_index - 1 ,1,orca.YSIZE) end
      update_offset()
    elseif menu then
     norns.enc(2, shift and -104 or -2)
    end
  elseif (code == hid.codes.KEY_TAB and val == 1) then
    bar = not bar
  elseif (code == 41 and val == 1) then
    help = not help
  -- bypass crashes  -- 2do F1-F12 (59-68, 87,88)
  elseif (code == 26 and val == 1) then
    dot_density = util.clamp(dot_density - 1, 1, 8)
  elseif (code == 27 and val == 1) then
    dot_density = util.clamp(dot_density + 1, 1, 8)
  elseif (code == hid.codes.KEY_102ND and val == 1) then
  elseif (code == hid.codes.KEY_ESC and (val == 1 or val == 2)) then
        selected_area_y, selected_area_x = 1, 1
      if menu and shift then 
        norns.key(1, 1)
      elseif menu and not shift then 
        norns.key(2, 1)
      end
  elseif (code == hid.codes.KEY_ENTER and val == 1) then
    if menu then
      norns.key(3, 1)
    end
  elseif (code == hid.codes.KEY_LEFTALT and val == 1) then
  elseif (code == hid.codes.KEY_RIGHTALT and val == 1) then
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
    if orca.clk.playing then
      orca.clk:stop()
      engine.noteKillAll()
      for i=1, orca.max_sc_ops do
        softcut.play(i,0)
      end
    else
      frame = 0
      orca.clk:start()
    end
  else
    if val == 1 then
      keyinput = get_key(code, val, shift)
      if not ctrl then
        if orca.is_op(x_index,y_index) and keyinput ~= field.cell[y_index][x_index] then
          orca:erase(x_index,y_index)
          if field.cell[y_index][x_index] == '/' then
            orca.sc_ops = util.clamp(orca.sc_ops - 1, 1, orca.max_sc_ops)
          end
        elseif keyinput == 'H' then
        end
        field.cell[y_index][x_index] = keyinput
        orca:add_to_queue(x_index,y_index)
      end
      if ctrl then 
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
end

local function draw_op_frame(x, y, brightness)
  screen.level(brightness)
  screen.rect(( x * 5 ) - 5, (( y * 8 ) - 5 ) - 3, 5, 8)
  screen.fill()
end

local function draw_grid()
  screen.font_face(25)
  screen.font_size(6)
  for y= 1, bounds_y do
    for x = 1, bounds_x do
      local y = y + field_offset_y
      local x = x + field_offset_x
      local f = field.cell.params[y][x]
      local cell = field.cell[y][x]
      if f.lit then draw_op_frame(x - field_offset_x,y - field_offset_y, 4) end
      if f.lit_out or f.cursor then draw_op_frame(x - field_offset_x,y - field_offset_y, 1) end
      if cell ~= 'null' or cell ~= nil then
        screen.level( orca.is_op( x, y ) and 15 or ( f.lit or f.cursor or f.lit_out or f.dot) and 12 or 1 )
      elseif cell == 'null' then
        screen.level( f.dot and 9 or 1)
      end
      screen.move((( x - field_offset_x ) * 5) - 4 , (( y - field_offset_y )* 8) - ( field.cell[y][x] and 2 or 3))
      if cell == 'null' or cell == nil then
        screen.text(f.dot and '.' or ( x % dot_density == 0 and y % util.clamp(dot_density - 1, 1, 8) == 0 ) and  '.' or '')
      else
        screen.text(cell)
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
  local cell = field.cell[y_index][x_index]
  screen.level(cell == 'null' and 2 or 15)
  screen.rect(x_pos, y_pos, 5, 8)
  screen.fill()
  screen.move(x_pos + ((cell ~= 'null' ) and 1 or 0), y_pos + 6)
  screen.level(cell == 'null' and 14 or 1)
  screen.font_face(cell == 'null' and 0 or 25)
  screen.font_size(cell == 'null' and 8 or 6)
  screen.text((cell == 'null' or cell == nil) and '@' or cell)
end

local function draw_bar()
  screen.level(0)
  screen.rect(0, 56, 128, 8)
  screen.fill()
  screen.level(15)
  screen.move(2, 63)
  screen.font_face(25)
  screen.font_size(6)
  screen.text(frame .. 'f')
  screen.stroke()
  screen.move(44, 63)
  screen.text_center(field.cell[y_index][x_index] and orca.info.names[string.upper(field.cell[y_index][x_index])] or 'empty')
  screen.stroke()
  screen.move(75,63)
  screen.text(params:get("bpm") .. (frame % 4 == 0 and ' *' or ''))
  screen.stroke()
  screen.move(123,63)
  screen.text_right(x_index .. ',' .. y_index)
  screen.stroke()
end

local function draw_help()
  if orca.info.description[string.upper(field.cell[y_index][x_index])] then
    screen.level(15)
    screen.rect(0, 29, 128, 25)
    screen.fill()
    screen.level(0)
    screen.rect(1, 30, 126, 23)
    screen.fill()
    if bar then
      screen.level(15)
      screen.move(40, 53)
      screen.line_rel(4, 4)
      screen.move(48, 53)
      screen.line_rel(-4, 4)
      screen.stroke()
      screen.level(0)
      screen.move(41, 54)
      screen.line_rel(6, 0)
      screen.stroke()
    end
    screen.font_face(25)
    screen.font_size(6)
    if orca.info.description[string.upper(field.cell[y_index][x_index])] then
      local s = orca.info.description[string.upper(field.cell[y_index][x_index])]
      local description = tab.split(s, ' ')
      screen.level(9)
      screen.move(3, 38)
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
  end
end

local function draw_map()
  screen.level(15)
  screen.rect(4,5,120,55)
  screen.fill()
  screen.level(0)
  screen.rect(5,6,118,53)
  screen.fill()
  for y = 1, orca.YSIZE do
    for x = 1, orca.XSIZE do
      if field.cell[y][x] ~= 'null' then
        screen.level(1)
        screen.rect(((x / orca.XSIZE ) * 114) + 5, ((y / orca.YSIZE) * 48) + 7, 3,3 )
        screen.fill()
      elseif field.cell.params[y][x].lit then
        screen.level(4)
        screen.rect(((x / orca.XSIZE ) * 114) + 5, ((y / orca.YSIZE) * 48) + 7, 3,3 )
        screen.fill()
      end
    end
  end
  screen.level(2)
  screen.rect((((util.clamp(x_index,1,78) / orca.XSIZE) ) * 114) + 5, ((util.clamp(y_index,2,28) / orca.YSIZE) * 48) + 5, (bounds_x / orca.XSIZE) * 114 ,(bounds_y / orca.YSIZE) * 48 )
  screen.stroke()
  screen.level(15)
  screen.rect(((x_index / orca.XSIZE ) * 114) + 5, ((y_index / orca.YSIZE) * 48) + 7, 1,1 )
  screen.fill()
end

function enc(n,d)
  if n == 2 then
   x_index = util.clamp(x_index + d, 1, orca.XSIZE)
  elseif n == 3 then
   y_index = util.clamp(y_index + d, 1, orca.YSIZE)
  end
  update_offset()
end

function g.key(x, y, z)
  local last = field.cell.grid[y][x]
    field.cell.grid[y][x] = z == 1 and 15 or last < 6 and last or 0
end

function g.redraw()
  for y = 1, g.rows do
    for x = 1, g.cols do
      if field.cell.grid[y][x] ~= nil then
        g:led(x, y, field.cell.grid[y][x] )
      end
    end
  end
  g:refresh()
end

function redraw()
  screen.clear()
  draw_area(x_index, y_index)
  draw_grid()
  draw_cursor(x_index - field_offset_x , y_index - field_offset_y)
  if bar then 
    draw_bar() 
  end
  if help then 
    draw_help() 
  end
  if map then
    draw_map() 
  end
  screen.update()
end
