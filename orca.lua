-- ORCA
-- v0.9.9.1 @its_your_bedtime
-- llllllll.co/t/orca

local tab = require 'tabutil'
local fileselect = require "fileselect"
local textentry = require "textentry"
local beatclock = require 'beatclock'
local keycodes = include("lib/keycodes")
local transpose_table = include("lib/transpose")
local keyboard = hid.connect()
local keyinput = ""
local x_index, y_index, field_offset_x, field_offset_y = 1, 1, 0, 0
local selected_area_y, selected_area_x, bounds_x, bounds_y = 1, 1, 25, 8
local bar, help, map = false
local dot_density = 1
local copy_buffer = { cell = {} }

orca = {
  __index = orca,
  XSIZE = 101,
  YSIZE = 41,
  frame = 0,
  bounds_x = bounds_x,
  bounds_y = bounds_y,
  g = grid.connect(),
  music = require( 'musicutil') ,
  operators = include( "lib/library" ),
  engines = include( "lib/engines" ),
  euclid = require 'er',
  clock = beatclock.new(),
  sc_ops = 0,
  max_sc_ops = 6,
  chars = keycodes.chars,
  notes = { "C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B" },
  moving_ops = { w = true, e = true, s = true, n = true },
  xy = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } },
  data = {
    __index = data,
    project = 'untitled',
    active = { __index = { 0, 0 } },
    cell = {
      __index = '.',
      params = {
        __index = { lit = false, lit_out = false, lock = false, cursor = false, dot = false, spawned = {} }
      },
      vars = {},
      active_notes = {},
      grid = {},
      sc_ops = {},  
      sc_ops_pos = { 0, 0, 0, 0, 0, 0 },
      defaults = { lit = false, lit_out = false, lock = false, cursor = false, dot = false, spawned = {}}
    },
  }
}

function orca.up(i)
  local l = tostring(i) 
  return string.upper(l) or '.'
end

-- midi / audio related
function orca.normalize(n)
  return n == 'e' and 'F' or n == 'b' and 'C' or n
end

function orca.transpose(n, o)
  local n = n == nil or n == '.' and 'C' or tostring(n)
  local o = o == nil or o == '.' and 3 or o
  local note = orca.normalize(string.sub(transpose_table[n], 1, 1))
  local octave = util.clamp(orca.normalize(string.sub(transpose_table[n], 2)) + o, 0, 8)
  local value = tab.key(orca.notes, note)
  local id = math.ceil( util.clamp((octave * 12) + value, 0, 127) - 1)
  return {id, value, note, octave, orca.music.note_num_to_name(id)}
end

function orca.sc_clear_region(p, l)
  softcut.buffer_clear_region(orca.data.cell.sc_ops_pos[p], l)
end

function orca:add_note(ch, note, length)
  local id = self.index_at(self.x,self.y) 
  if orca.data.cell.active_notes[id] == nil then 
    orca.data.cell.active_notes[id] = {}
  end
  if orca.data.cell.active_notes[id][note] == {note, length} then
    orca.midi_out_device:note_off(note, nil, ch)
  end
  orca.data.cell.active_notes[id][note] = {note, length}
end



function orca:add_note_mono(ch, note, length)
  local id = self.index_at(self.x,self.y) 
  if orca.data.cell.active_notes[id] == nil then 
    orca.data.cell.active_notes[id] = {}
  end
  orca.data.cell.active_notes[id][ch] = {note, length}
end

function orca:notes_off(ch)
  local id = self.index_at(self.x,self.y)
  if orca.data.cell.active_notes[id] ~= nil then
    for k, v in pairs(orca.data.cell.active_notes[id]) do
      local note = orca.data.cell.active_notes[id][k][1]
      local length = util.clamp(orca.data.cell.active_notes[id][k][2], 1, #orca.chars)
      if self.frame % length  == 0 then 
        orca.midi_out_device:note_off(note, nil, ch)
        orca.data.cell.active_notes[id][k] = nil
      end
    end
  end
end

-- save / load 
function orca.load_project(pth)
  if string.find(pth, 'orca') ~= nil then
    local saved = tab.load(pth)
    if saved ~= nil then
      print("data found")
      orca.data = saved
      local name = string.sub(string.gsub(pth, '%w+/',''),2,-6)
      orca.data.project = name 
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
    orca.data.project = txt
    tab.save(orca.data, norns.state.data .. txt ..".orca")
    softcut.buffer_write_mono(norns.state.data..txt .."_buffer.aif",0,#orca.chars, 1)
    params:write(norns.state.data .. txt .. ".pset")
    print ('saved ' .. norns.state.data .. txt .. '_buffer.aif')
  else
    print("save cancel")
  end
end

-- cut/copy/paste 
function orca.copy_area()
  copy_buffer = { cell = {} }
  for y=y_index, y_index + selected_area_y - 1 do
    copy_buffer.cell[y -  y_index ] = {}
    for x = x_index - 1,( x_index + selected_area_x ) - 1 do
      copy_buffer.cell[y -  y_index ][x -  x_index ] = orca.copy(orca.data.cell[y][x])
    end
  end
end

function orca.cut_area()
  copy_buffer = { cell = {} }
  for y=y_index, y_index + selected_area_y - 1 do
    copy_buffer.cell[y -  y_index ] = {}
    for x = x_index, (x_index + selected_area_x) - 1 do
      copy_buffer.cell[y -  y_index ][x -  x_index ] = orca.copy(orca.data.cell[y][x])
      orca:erase(x, y)
    end
  end
end

function orca.paste_area()
  for y=0, #copy_buffer.cell do
    for x = 0, #copy_buffer.cell[y] do
      orca:erase(util.clamp(x_index + x, 0, orca.XSIZE), util.clamp(y_index + y, 0, orca.YSIZE))
      orca.data.cell[y_index + y][(x_index + x)] = orca.copy(copy_buffer.cell[y][x])
    end
  end
end

-- core
function orca.copy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do
    res[orca.copy(k)] = orca.copy(v)
  end
  return res
end

function orca.inbounds(x, y)
  local x, y = x or 0, y or 0
  return ((x > 0 and x < orca.XSIZE) and (y > 0 and y < orca.YSIZE)) and true
end

function orca:replace(i)
  orca.data.cell[self.y][self.x] = i
end

function orca:explode()
  self:replace('*')
end

function orca:listen(x, y)
  local value = string.lower(orca.data.cell[y][x] or '.')
  return value ~= '.' and tab.key(orca.chars, value) or false
end 

function orca:active(x, y)
  local x,y = x ~= nil and x or self.x, y ~= nil and y or self.y
  return orca.data.cell[y][x] == self.up(orca.data.cell[y][x]) and true
end

function orca.write(x, y, g)
  if g == '.' then return false 
  elseif string.len(g) ~= 1 then return false
  elseif not orca.inbounds(x, y) then return false
  elseif orca.glyph_at(x, y) == g then return false 
  else
    orca.cleanup(x, y)
    orca.data.cell[y][x] = g
    return true
  end
end

function orca:erase(x, y)
  self.x, self.y = x, y
  if self.op(self.x, self.y) then
    self.cleanup(x, y)
    self:replace('.')
  else
    self:replace('.')
  end
end

--
function orca.op(x, y)
  return (orca.operators[orca.up(orca.data.cell[y][x])] ~= nil) and true
end

function orca.is_op(op)
  return (orca.operators[orca.up(op)] ~= nil) and true
end

function orca.locked(x, y)
  return orca.data.cell.params[y][x].lock
end

function orca.spawned(x, y)
  return orca.data.cell.params[y][x].spawned.info and true or false
end

function orca.lock(x, y, active, out, locks)
  if orca.inbounds(x, y) then 
    if locks and orca.spawned(x, y) then orca.cleanup(x, y) end
    orca.data.cell.params[y][x].dot = not active
    orca.data.cell.params[y][x].lock = locks
    orca.data.cell.params[y][x].lit = active
    orca.data.cell.params[y][x].lit_out = out
  end
end

function orca.unlock(x, y, active, out, locks)
  if orca.inbounds(x, y) then
    orca.data.cell.params[y][x].dot = false
    orca.data.cell.params[y][x].lock = locks
    orca.data.cell.params[y][x].lit = active
    orca.data.cell.params[y][x].lit_out = out
    orca.data.cell.params[y][x].spawned = {}
  end
end

function orca:banged()
  for i = 1, #self.xy do
    if orca.data.cell[self.y + self.xy[i][2]][self.x + self.xy[i][1]] == '*' then
      orca.data.cell.params[self.y][self.x].lit = false
      --orca.data.cell.params[self.y + 1][self.x].lit_out = self.passive and not self.moving_ops[self.glyph] and true or false
      return true
    else
      if not self.passive then
        orca.data.cell.params[self.y][self.x].lit = true
      else
        --orca.data.cell.params[self.y + 1][self.x].lit_out = false
      end
      return false
    end
  end
end

function orca:shift(s, e)
  local data = orca.data.cell[self.y][self.x + s]
  local params = orca.data.cell.params[self.y][self.x + s]
  table.remove(orca.data.cell[self.y], self.x + s)
  table.remove(orca.data.cell.params[self.y], self.x + s)
  table.insert(orca.data.cell[self.y], self.x + e, data)
  table.insert(orca.data.cell.params[self.y], self.x + e, params)
end


function orca:move(x,y)
  local a = self.y + y
  local b = self.x + x
  local collider = orca.data.cell[a][b]
  if collider == '.' then
    local l = orca.data.cell[self.y][self.x]
    
    self.cleanup(self.x, self.y)
    self:replace('.')
    orca.data.cell[a][b] = l
  end
end   
    
--[[    if not self.locked(b, a) then
      self:explode()--and collider ~= '.' then
      --if orca.op(b, a) then
      --  self:explode()
    --  else
        --self:explode()
      ---end
    --else
    elseif self.op(b,a) then
      self:explode()
      
    else  
      local l = orca.data.cell[self.y][self.x]
      self.cleanup(self.x, self.y)
      self:replace('.')
      orca.data.cell[a][b] = l
    end
  end
end
]]
function orca:spawn(ports)
  self.lock(self.x, self.y, true, false, false)
  
  orca.data.cell.params[self.y][self.x].spawned.ports = ports
  orca.data.cell.params[self.y][self.x].spawned.info = { self.name, self.glyph }
  orca.data.cell.params[self.y][self.x].lit = not self.passive
  
  for k = 1, #ports do
    local type = ports[k][4]
    local x = self.x + ports[k][1]
    local y = self.y + ports[k][2]
    
    if self.inbounds(x, y) then
      if type == 'haste' then
        self.lock(x, y, false, false, false)
      elseif   type == 'input' then
        self.lock(x, y, false, false, true)
        orca.unlock(x + 1, y, false, false, false)
      elseif type == 'output' then
        self.lock(x, y, false, true,  true)
        orca.unlock(x + 1, y, false, false, false)
      end
      orca.data.cell.params[y][x].spawned.info = { ports[k][3], self.glyph }
    end
  end
end

function orca.unspawn(x, y)
  
  if orca.spawned(x, y) then
    local ports = orca.data.cell.params[y][x].spawned.ports or {}
    
  for k = 1, #ports do
      local type = ports[k][4]
      local X = x + ports[k][1]
      local Y = y + ports[k][2]
      
      if orca.inbounds(X, Y) then
        
        
        if type == 'haste' then
          orca.unlock(X, Y, false, false, false)
        elseif  type == 'input' then
          orca.unlock(X, Y, false, false, true)
        elseif type == 'output' then
          orca.unlock(X, Y, false, false, true)
        end
        
        orca.data.cell.params[Y][X].spawned.info = nil
     
      end
      
    end

    orca.clean_len_inputs(x, y)
    orca.data.cell.params[y][x].lit = false
    orca.data.cell.params[y][x].spawned = {}
    
  end
end

function orca.glyph_at(x, y)
  return orca.inbounds(x, y) and orca.data.cell[y][x] ~= '.' and orca.data.cell[y][x]
end

function orca.index_at(x, y)
  return orca.inbounds(x, y) and tonumber(x + (orca.XSIZE * y))
end

function orca.clean_len_inputs(x, y)
  local seqlen = orca.data.cell.params[y][x].spawned.seq or 0
  local offsets = orca.data.cell.params[y][x].spawned.offsets or { 0, 0 }
  if seqlen > 0 then
    for i=1, seqlen do
      orca.unlock( (x + i) + offsets[1], y + offsets[2], false, false, false)
    end
  end
end

function orca.cleanup(x, y)

  orca.unspawn( x, y )
  
  if orca.data.cell[y + 1][x] == '*' then 
    orca.data.cell[y + 1][x] = '.' 
  end
  
  if orca.data.cell[y][x] == '/' then 
    softcut.play(orca:listen(x + 1, y) or 1, 0) 
    orca.sc_ops = util.clamp(orca.sc_ops - 1, 0, orca.max_sc_ops)
  end
end

-- execution
function orca:parse()
  local a = {}
  for y = 0, self.YSIZE do
    for x = 0, self.XSIZE do
        if (self.op(x, y) and not self.locked(x, y) and self.inbounds(x, y)) then
          local g, t = self.data.cell[y][x]
          local operator =  self.operators[self.up(g)]
          local x, y, g = x, y, g
          a[#a + 1] = { operator, x, y, g } 
      end
    end
  end
  return a
end


function orca:operate()
  self.frame = (self.frame + 1) % 99999
  local l = self.frame % 1 == 0 and self:parse() or {}
  for i = 1, #l do
    local op = l[i][1]
    local x,y,g = l[i][2], l[i][3], l[i][4]
    if not self.locked(x, y) then -- this breaks
        op(self, x, y, g)
    end
  end
end




function init()
  -- orca.data 
  for y = 0, orca.YSIZE + orca.YSIZE do
    orca.data.cell[y] = {}
    orca.data.cell.params[y] = {}
    for x = 0, orca.XSIZE + orca.XSIZE do
      orca.data.cell[y][x] = '.'
      orca.data.cell.params[y][x] = orca.copy(orca.data.cell.params.__index)
    end
  end
  -- grid 
  for i = 1, orca.g.rows do
    orca.data.cell.grid[i] = {}
  end
  -- ops exec 
  orca.clock.on_step = function() orca:operate()  orca.g:redraw() end,
  orca.clock:add_clock_params()
  orca.clock:start()
  -- params
  params:set("bpm", 120)
  params:add_separator()
  params:add_trigger('save_p', "< Save project" )
  params:set_action('save_p', function(x) textentry.enter(orca.save_project,  orca.data.project) end)
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
  orca.engines.init()
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
  redraw_metro = metro.init(function(stage) redraw() end, 1/30)
  redraw_metro:start()
end



-- grid 
function orca.g.key(x, y, z)
  local last = orca.data.cell.grid[y][x]
    orca.data.cell.grid[y][x] = z == 1 and 15 or last < 6 and last or 0
end

function orca.g.redraw()
  for y = 1, orca.g.rows do
    for x = 1, orca.g.cols do
      orca.g:led(x, y, orca.data.cell.grid[y][x] or 0  )
    end
  end
  orca.g:refresh()
end


-- 
local function update_offset()
  if x_index < bounds_x + (field_offset_x - 24)  then
    field_offset_x =  util.clamp(field_offset_x - (ctrl and 9 or 1),0,orca.XSIZE - field_offset_x)
  elseif x_index > field_offset_x + 25  then
    field_offset_x =  util.clamp(field_offset_x + (ctrl and 9 or 1),0,orca.XSIZE - bounds_x)
  end
  if y_index  > field_offset_y + (bar and 7 or 8)   then
      field_offset_y =  util.clamp(field_offset_y + (ctrl and 9 or 1),0,orca.YSIZE - bounds_y)
    elseif y_index < bounds_y + (field_offset_y - 7)  then
    field_offset_y = util.clamp(field_offset_y - (ctrl and 9 or 1),0,orca.YSIZE - bounds_y)
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

function keyboard.event(typ, code, val)
  local menu = norns.menu.status()
   --print("hid.event ", typ, code, val)
  if ((code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 1 or val == 2)) then
    shift  = true;
  elseif (code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 0) then
    shift = false;
    elseif ((code == hid.codes.KEY_LEFTCTRL or code == hid.codes.KEY_RIGHTCTRL) and (val == 1 or val == 2)) then
    ctrl = true
  elseif ((code == hid.codes.KEY_LEFTCTRL or code == hid.codes.KEY_RIGHTCTRL) and val == 0) then
    ctrl = false
  elseif ((code == hid.codes.KEY_LEFTMETA or code == hid.codes.KEY_RIGHTMETA ) and (val == 1 or val == 2)) then
    ctrl = true
  elseif ((code == hid.codes.KEY_LEFTMETA or code == hid.codes.KEY_RIGHTMETA ) and val == 0) then
    ctrl = false
  elseif (code == hid.codes.KEY_BACKSPACE or code == hid.codes.KEY_DELETE) then
    orca:erase(x_index,y_index)
  elseif (code == hid.codes.KEY_LEFT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x -  (ctrl and 9 or 1) ,1,orca.XSIZE) else
        x_index = util.clamp(x_index - (ctrl and 9 or 1), 1,orca.XSIZE)
      end
      update_offset()
    elseif menu then
      if ctrl then 
        norns.enc(1, -8)
      else
        norns.enc(3, shift and -20 or -2)
      end
    end
  elseif (code == hid.codes.KEY_RIGHT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x + (ctrl and 9 or 1), 1,orca.XSIZE) else
        x_index = util.clamp(x_index + (ctrl and 9 or 1), 1,orca.XSIZE)
      end
      update_offset()
    elseif menu then
      if ctrl then 
        norns.enc(1, 8)
      else
        norns.enc(3, shift and 20 or 2)
      end
    end
  elseif (code == hid.codes.KEY_DOWN) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y + (ctrl and 9 or 1), 1,orca.YSIZE) else
        y_index = util.clamp(y_index + (ctrl and 9 or 1), 1,orca.YSIZE)
      end
      update_offset()
    elseif menu then
      norns.enc(2, shift and 104 or 2)
    end
  elseif (code == hid.codes.KEY_UP) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y - (ctrl and 9 or 1), 1,orca.YSIZE) else
        y_index = util.clamp(y_index - (ctrl and 9 or 1) ,1,orca.YSIZE)
      end
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
      if shift then
        norns.menu.set_status(not menu)
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
  elseif (code == hid.codes.KEY_RIGHTMETA and val == 1) then
  elseif (code == hid.codes.KEY_COMPOSE and val == 1) then
  elseif (code == 119 and val == 1) then
  elseif ((code == 88 or code == 87) and val == 1) then
  elseif (code == hid.codes.KEY_SPACE) and (val == 1) then
    if orca.clock.playing then
      orca.clock:stop()
      engine.noteKillAll()
      for i=1, orca.max_sc_ops do
        softcut.play(i,0)
      end
    else
      orca.clock:start()
    end
  else
    if val == 1 then
      keyinput = get_key(code, val, shift)
      if not ctrl then
        if not orca.locked(x_index,y_index) and keyinput ~= orca.data.cell[y_index][x_index] then
          orca:erase(x_index,y_index)
          if orca.data.cell[y_index][x_index] == '/' then
            orca.sc_ops = util.clamp(orca.sc_ops - 1, 1, orca.max_sc_ops)
          end
        elseif keyinput == 'H' then
        end
        orca.data.cell[y_index][x_index] = keyinput
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
      local f = orca.data.cell.params[y][x]
      local cell = orca.data.cell[y][x] == nil and '.' or orca.data.cell[y][x]
      if f.lit then 
        draw_op_frame(x - field_offset_x, y - field_offset_y, 4) 
      end
      if f.lit_out then 
        draw_op_frame(x - field_offset_x, y - field_offset_y, 1) 
      end
      if cell ~= '.' or cell ~= nil then
        screen.level( orca.op( x, y ) and 15 or ( f.lit or f.cursor or f.lit_out or f.dot) and 12 or 1 )
      elseif cell == '.' then
        screen.level( f.dot and 9 or 1)
      end
      screen.move((( x - field_offset_x ) * 5) - 4 , (( y - field_offset_y )* 8) - ( orca.data.cell[y][x] and 2 or 3))
      if cell == '.' or cell == nil then
        screen.text(f.dot and '.' or ( x % dot_density == 0 and y % util.clamp(dot_density - 1, 1, 8) == 0 ) and  '.' or '')
      elseif cell == tostring(cell) then
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
  local cell = tostring(orca.data.cell[y_index][x_index])
  
  screen.level(cell == '.' and 2 or 15)
  screen.rect(x_pos, y_pos, 5, 8)
  screen.fill()

  screen.font_face(cell == '.' and 0 or 25)
  screen.font_size(cell == '.' and 8 or 6)

  screen.level(cell == '.' and 14 or 1)
  screen.move(x_pos + ((cell ~= '.' ) and 1 or 0), y_pos + 6)
  screen.text((cell == '.' or cell == nil) and '@' or cell)
  
end

function orca:draw_bar()
  local info = orca.data.cell.params[y_index][x_index].spawned.info or {}
  local text = info[1] or 'empty'
  
  screen.level(0)
  screen.rect(0, 56, 128, 8)
  screen.fill()
  screen.level(9)
  screen.move(2, 63)
  screen.font_face(25)
  screen.font_size(6)
  screen.text(text)
  screen.stroke()
  screen.move(80,63)
  screen.text(params:get("bpm") .. (self.frame % 4 == 0 and ' *' or ''))
  screen.stroke()
  screen.move(123,63)
  screen.text_right(x_index .. ',' .. y_index)
  screen.stroke()
  
end

function orca:draw_help()
  
  if self.op(x_index, y_index) then
    
    screen.level(15)
    screen.rect(0, 29, 128, 25)
    screen.fill()
    screen.level(0)
    screen.rect(1, 30, 126, 23)
    screen.fill()
    screen.font_face(25)
    screen.font_size(6)
    local description = tab.split(orca.data.cell.params[y_index][x_index].spawned.info[2], ' ')
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

local function draw_map()
  
  screen.level(15)
  screen.rect(4,5,120,55)
  screen.fill()
  screen.level(0)
  screen.rect(5,6,118,53)
  screen.fill()
  
  for y = 1, orca.YSIZE do
    for x = 1, orca.XSIZE do
      if orca.data.cell[y][x] ~= '.' then
        screen.level(1)
        screen.rect(((x / orca.XSIZE ) * 114) + 5, ((y / orca.YSIZE) * 48) + 7, 3,3 )
        screen.fill()
      elseif orca.data.cell.params[y][x].lit then
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

function enc(n, d)
  if n == 2 then
    x_index = util.clamp(x_index + d, 1, orca.XSIZE)
  elseif n == 3 then
    y_index = util.clamp(y_index + d, 1, orca.YSIZE)
  end
  update_offset()
end

function key(n, z)
  map = n == 1 and z == 1 and true
end

function redraw()
  screen.clear()
  draw_area(x_index, y_index)
  draw_grid()
  draw_cursor(x_index - field_offset_x , y_index - field_offset_y)
  if bar then 
    orca:draw_bar() 
    if help then 
      orca:draw_help() 
    end
  end
  if map then
    draw_map() 
  end
  screen.update()
end