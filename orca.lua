-- ORCA
-- v0.9.9.6 @its_your_bedtime
-- llllllll.co/t/orca

local tab = require 'tabutil'
local fileselect = require "fileselect"
local textentry = require "textentry"
local beatclock = require 'beatclock'
local clock = beatclock.new()
local keycodes = include("lib/keycodes")
local transpose_table = include("lib/transpose")
local library = include( "lib/library" )
local engines = include( "lib/engines" )
local keyinput = ""
local x_index, y_index, field_offset_x, field_offset_y = 1, 1, 0, 0
local selected_area_y, selected_area_x, bounds_x, bounds_y = 1, 1, 25, 8
local bar, help, map = false
local dot_density = 1
local copy_buffer = { cell = {} }

local orca = {
  XSIZE = 60,
  YSIZE = 60,
  frame = 0,
  grid = { },
  vars = { },
  music = require 'musicutil',
  euclid = require 'er',
  chars = keycodes.chars,
  base36 = keycodes.base36,
  keyboard = hid.connect( ),
  g = grid.connect( ),
  notes = { "C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B" },
  around = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } },
  defaults = { lit = false, lit_out = false, lock = false, dot = false, spawned = { }},
  active_notes = { },
  sc_ops = { count = 0, max = 6, pos = {0, 0, 0, 0, 0, 0} },  
  data = { project = 'untitled', cell = { params = { } } }
}


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
  softcut.buffer_clear_region(orca.sc_ops.pos[p], l) 
end

function orca:add_note(ch, note, length)
  local id = self.index_at(self.x,self.y) 
  if orca.active_notes[id] == nil then 
    orca.active_notes[id] = {}
  end
  if orca.active_notes[id][note] == {note, length} then
    orca.midi_out_device:note_off(note, nil, ch)
  end
  orca.active_notes[id][note] = {note, length}
end

function orca:add_note_mono(ch, note, length)
  local id = self.index_at(self.x,self.y) 
  if orca.active_notes[id] == nil then 
    orca.active_notes[id] = {}
  end
  orca.active_notes[id][ch] = {note, length}
end

function orca:notes_off(ch)
  local id = self.index_at(self.x,self.y)
  if orca.active_notes[id] ~= nil then
    for k, v in pairs(orca.active_notes[id]) do
      local note = orca.active_notes[id][k][1]
      local length = util.clamp(orca.active_notes[id][k][2], 1, #orca.chars)
      if self.frame % length  == 0 then 
        orca.midi_out_device:note_off(note, nil, ch)
        orca.active_notes[id][k] = nil
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

-- cut / copy / paste 
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
      orca.erase(x, y)
    end
  end
end

function orca.paste_area()
  for y=0, #copy_buffer.cell do
    for x = 0, #copy_buffer.cell[y] do
      orca.erase(util.clamp(x_index + x, 0, orca.XSIZE), util.clamp(y_index + y, 0, orca.YSIZE))
      orca.data.cell[y_index + y][(x_index + x)] = orca.copy(copy_buffer.cell[y][x])
    end
  end
end

-- core
function orca.up(i) 
  local l = tostring(i)  return string.upper(l) or '.'
end

function orca.inbounds(x, y)
  return ((x > 0 and x < orca.XSIZE) and (y > 0 and y < orca.YSIZE)) and true
end

function orca:replace(i)
  orca.data.cell[self.y][self.x] = i
end

function orca:explode()
  self:replace('*')
end

function orca:listen(x, y)
  local c = self.data.cell return c[y] ~= nil and (c[y][x] ~= nil and orca.base36[string.lower(c[y][x])] or false) or false
end

function orca:glyph_at(x, y) 
  if not self.inbounds(x, y) then return '.'  else l = self.data.cell[y][x] return l end 
end

function orca.locked(x, y)
  local p = orca.data.cell.params return  p[y] ~= nil and (p[y][x] ~= nil and p[y][x].lock or false) or false
end

function orca.erase(x, y) 
  orca.cleanup(x, y) orca.data.cell[y][x] = '.'  
end

function orca.index_at(x, y) 
  return orca.inbounds(x, y) and tonumber(x + (orca.XSIZE * y)) 
end

function orca.op(x, y) 
  local c = orca.data.cell[y][x] return (library[orca.up(c)] ~= nil) and true 
end

function orca.spawned(x, y) 
  return orca.data.cell.params[y][x].spawned.info and true or false 
end

function orca:banged( )
  for i = 1, #self.around do
    if self:glyph_at( self.x + self.around[i][1], self.y + self.around[i][2] ) == '*' then
    self.data.cell.params[self.y][self.x].lit = false return true end
  end
end

function orca.copy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {} for k, v in pairs(obj) do res[orca.copy(k)] = orca.copy(v) end
  return res
end

function orca:write(x, y, g)
  if not self.inbounds(self.x + x, self.y + y) then return false
  elseif self.data.cell[self.y + y][self.x + x] == g then return false 
  else self.data.cell[self.y + y][self.x + x] = g return true
  end
end

function orca.lock(x, y, active, out, locks)
  if orca.inbounds(x, y) then 
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
  end
end

function orca:shift(s, e)
  if orca.inbounds(self.x + e, self.y) then
    local data = orca.data.cell[self.y][self.x + s]
    table.remove(orca.data.cell[self.y], self.x + s)
    table.insert(orca.data.cell[self.y], self.x + e, data)
  end
end


function orca:move(x, y)
  local a = self.y + y
  local b = self.x + x
  if self.inbounds(b,a) then
  local collider = orca.data.cell[a][b]
  if collider ~= '.' and collider ~= '*' then self:explode()
  else local l = orca.data.cell[self.y][self.x]
  self:replace('.') orca.data.cell[a][b] = l end
  else self:explode() end
end

function orca:spawn(ports)
  local cell = orca.data.cell.params[self.y][self.x]
  cell.spawned.ports = ports or {}
  cell.spawned.info = { self.name, self.info }
  cell.lit = not self.passive
  for k = 1, #ports do
    local type = ports[k][4]
    local x = self.x + ports[k][1]
    local y = self.y + ports[k][2]
    if self.inbounds(x, y) then
      self.lock( x, y, false, type == 'output' and true or false, (type == 'input' or type == 'output') and true )
      orca.data.cell.params[y][x].spawned.info = { ports[k][3] }
    end
  end
end

function orca.cleanup(x, y)
    local ports = orca.data.cell.params[y][x].spawned.ports or false
    if ports then
      for k = 1, #ports do
        local type = ports[k][4]
        local X = x + ports[k][1]
        local Y = y + ports[k][2]
        orca.unlock(X, Y, false, false, false)
      end
    end
  if orca.data.cell[y][x] == '/' then 
    softcut.play(orca:listen(x + 1, y) or 1, 0) 
    orca.sc_ops.count = util.clamp(orca.sc_ops.count - 1, 0, orca.sc_ops.max)
  end
  orca.data.cell.params[y][x].lit = false
  orca.data.cell.params[y][x].spawned = { }
end

-- exec
function orca:parse()
  local a = {}
  for y = 0, self.YSIZE do
    for x = 0, self.XSIZE do
      if (self.op(x, y) and not self.locked(x, y)) then
        local g = self.data.cell[y][x]
        local o =  library[self.up(g)]
        local x, y, g = x, y, g
        a[#a + 1] = { o, x, y, g } 
      else
        self.unlock(x, y, false, false, false)
      end
    end
  end
  return a
end

function orca:operate()
  self.frame = self.frame + 1
  local l = self:parse()
  for i = 1, #l do local op, x, y, g = l[i][1], l[i][2], l[i][3], l[i][4]
    if not self.locked(x, y) then op(self, x, y, g) end
  end
end

-- grid 
function orca.g.key(x, y, z) 
  local last = orca.grid[y][x] orca.grid[y][x] = z == 1 and 15 or last < 6 and last or 0 
end

function orca.g.redraw() 
  for y = 1, orca.g.rows do for x = 1, orca.g.cols do orca.g:led(x, y, orca.grid[y][x] or 0  ) end end orca.g:refresh()
end

function init()
  -- orca.data 
  for y = 0, orca.YSIZE do
    orca.data.cell[y] = {}
    orca.data.cell.params[y] = {}
    for x = 0, orca.XSIZE do
      orca.data.cell[y][x] = '.'
      orca.data.cell.params[y][x] = orca.copy(orca.defaults)
    end
  end
  -- grid 
  for i = 1, orca.g.rows do
    orca.grid[i] = {}
  end
  -- ops exec 
  clock.on_step = function() orca:operate()  orca.g:redraw() end,
  clock:add_clock_params()
  clock:start()
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
  engines.init()
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
-- UI / controls
local function update_offset(x ,y)
  if x < bounds_x + ( field_offset_x - 24 )  then
    field_offset_x =  util.clamp(field_offset_x - (ctrl and 9 or 1), 0, orca.XSIZE - field_offset_x)
  elseif x > field_offset_x + 25  then
    field_offset_x =  util.clamp(field_offset_x + (ctrl and 9 or 1), 0, orca.XSIZE - bounds_x)
  end
  if y  > field_offset_y + ( bar and 7 or 8 )   then
      field_offset_y =  util.clamp(field_offset_y + (ctrl and 9 or 1), 0, orca.YSIZE - bounds_y)
    elseif y < bounds_y + ( field_offset_y - 7)  then
    field_offset_y = util.clamp( field_offset_y - (ctrl and 9 or 1), 0, orca.YSIZE - bounds_y)
  end
end

local function get_key(code, val, shift)
  if keycodes.keys[code] ~= nil and val == 1 then
    if shift then if keycodes.shifts[code] ~= nil then return keycodes.shifts[code]
    else return keycodes.keys[code] end
    else return string.lower(keycodes.keys[code]) end
  end
end

local kb = {s = {[42] = true, [54] = true }, c = {[29] = true, [125] = true, [127] = true, [97] = true}}
function orca.keyboard.event(typ, code, val)
  local menu = norns.menu.status()
  --print("hid.event ", typ, code, val)
  if kb.s[code] then
    shift  =  (val == 1 or val == 2) and true
  elseif kb.c[code] then
    ctrl = (val == 1 or val == 2) and true
  elseif (code == hid.codes.KEY_LEFT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x -  (ctrl and 9 or 1) ,1,orca.XSIZE) 
      else x_index = util.clamp(x_index - (ctrl and 9 or 1), 1,orca.XSIZE) end
      update_offset(x_index, y_index)
    elseif menu then if ctrl then norns.enc(1, -8) else norns.enc(3, shift and -20 or -2) end end
  elseif (code == hid.codes.KEY_RIGHT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x + (ctrl and 9 or 1), 1,orca.XSIZE) 
      else x_index = util.clamp(x_index + (ctrl and 9 or 1), 1,orca.XSIZE) end
      update_offset(x_index, y_index)
    elseif menu then if ctrl then norns.enc(1, 8) else norns.enc(3, shift and 20 or 2) end end
  elseif (code == hid.codes.KEY_DOWN) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y + (ctrl and 9 or 1), 1,orca.YSIZE) 
      else y_index = util.clamp(y_index + (ctrl and 9 or 1), 1,orca.YSIZE) end
      update_offset(x_index, y_index)
    elseif menu then norns.enc(2, shift and 104 or 2) end
  elseif (code == hid.codes.KEY_UP) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y - (ctrl and 9 or 1), 1,orca.YSIZE) 
      else y_index = util.clamp(y_index - (ctrl and 9 or 1) ,1,orca.YSIZE) end
      update_offset(x_index, y_index)
    elseif menu then norns.enc(2, shift and -104 or -2) end
  elseif (code == hid.codes.KEY_TAB and val == 1) then bar = not bar
  elseif (code == 41 and val == 1) then map = not map
  elseif (code == 14 or code == 111) then orca.erase(x_index,y_index)
  elseif code == 58 or code == 56 then -- caps/alt 
  elseif code == 110 then orca.paste_area() 
  elseif code == 102 then x_index, y_index = 1,1 field_offset_x, field_offset_y = 1,1 update_offset(x_index, y_index)
  elseif (code == 26 and val == 1) then dot_density = util.clamp(dot_density - 1, 1, 8)
  elseif (code == 27 and val == 1) then dot_density = util.clamp(dot_density + 1, 1, 8)
  elseif (code == hid.codes.KEY_ESC and (val == 1 or val == 2)) then 
    selected_area_y, selected_area_x = 1, 1
    if shift then norns.menu.set_status(not menu)
    elseif menu and not shift then norns.key(2, 1) end
  elseif (code == hid.codes.KEY_ENTER and val == 1) then
    if menu then norns.key(3, 1) end
  elseif (code == hid.codes.KEY_SPACE) and (val == 1) then
    if clock.playing then clock:stop() engine.noteKillAll()
    for i=1, orca.sc_ops.max do softcut.play(i,0) end
    else clock:start() end
  else if val == 1 then keyinput = get_key(code, val, shift) if not ctrl then
    if not orca.locked(x_index,y_index) and keyinput ~= orca.data.cell[y_index][x_index] then orca.erase(x_index,y_index)
    if orca.data.cell[y_index][x_index] == '/' then orca.sc_ops.count = util.clamp(orca.sc_ops.count - 1, 1, orca.sc_ops.max) end end 
    orca.data.cell[y_index][x_index] = keyinput or '.' end
    if ctrl then if code == 45 then orca.cut_area() elseif code == 46 then orca.copy_area() elseif code == 47 then orca.paste_area() end end
    end
  end
end

local function draw_op_frame(x, y, b)
  screen.level(b) screen.rect(( x * 5 ) - 5, (( y * 8 ) - 5 ) - 3, 5, 8) screen.fill()
end

local function draw_grid()
  screen.font_face(25)
  screen.font_size(6)
  for y= 1, bounds_y do local y = y + field_offset_y for x = 1, bounds_x do
    local x = x + field_offset_x
    local f = orca.data.cell.params[y][x] or {}
    local cell = orca.data.cell[y][x] or '.'
    if f.lit then draw_op_frame(x - field_offset_x, y - field_offset_y, 4) end
    if f.lit_out then draw_op_frame(x - field_offset_x, y - field_offset_y, 1) end
    if cell ~= '.' or cell ~= nil then screen.level( orca.op(x, y) and 15 or ( f.lit or f.lit_out or f.dot) and 12 or 1 )
    elseif cell == '.' then screen.level( f.dot and 9 or 1) end
    screen.move((( x - field_offset_x ) * 5) - 4 , (( y - field_offset_y )* 8) - ( orca.data.cell[y][x] and 2 or 3))
    if cell == '.' or cell == nil then
      screen.text(f.dot and '.' or ( x % dot_density == 0 and y % util.clamp(dot_density - 1, 1, 8) == 0 ) and  '.' or '')
    elseif cell == tostring(cell) then screen.text(cell) end
    screen.stroke()
    end
  end
end

local function draw_area(x,y)
  local x_pos = (((x - field_offset_x) * 5) - 5) 
  local y_pos = (((y - field_offset_y) * 8) - 8)
  screen.level(2) screen.rect(x_pos,y_pos, 5 * selected_area_x , 8 * selected_area_y ) screen.fill()
end

local function draw_cursor(x,y)
  local x_pos = ((x * 5) - 5) 
  local y_pos = ((y * 8) - 8)
  local x_index = x + field_offset_x
  local y_index = y + field_offset_y
  local cell = tostring(orca.data.cell[y_index][x_index])
  screen.level(cell == '.' and 2 or 15) screen.rect(x_pos, y_pos, 5, 8) screen.fill()
  screen.font_face(cell == '.' and 0 or 25) screen.font_size(cell == '.' and 8 or 6)
  screen.level(cell == '.' and 14 or 1) screen.move(x_pos + ((cell ~= '.' ) and 1 or 0), y_pos + 6)
  screen.text((cell == '.' or cell == nil) and '@' or cell) screen.stroke()
end

function draw_bar()
  local info = orca.data.cell.params[y_index][x_index].spawned.info or {}
  local text = info[1] or 'empty'
  screen.level(0) screen.rect(0, 56, 128, 8) screen.fill()
  screen.level(9) screen.move(2, 63) 
  screen.font_face(25) screen.font_size(6) screen.text(text) screen.stroke()
  screen.move(80,63) screen.text(params:get("bpm") .. (orca.frame % 4 == 0 and ' *' or '')) screen.stroke()
  screen.move(123,63) screen.text_right(x_index .. ',' .. y_index) screen.stroke()
end

local function map_y (p)  return ((p / orca.YSIZE) * 48) + 7 end
local function map_x (p)  return ((p / orca.XSIZE) * 114) + 7 end
local function map_index_x (p)  return ((util.clamp(p,2,30) / orca.YSIZE) * 48) + 5 end
local function map_index_y (p)  return (((util.clamp(p,1, 60) / orca.XSIZE) ) * 114) + 5 end


local function draw_map()
  screen.level(15) screen.rect(4,5,120,55) screen.fill()
  screen.level(0) screen.rect(5,6,118,53) screen.fill()
  for y = 1, orca.YSIZE do for x = 1, orca.XSIZE do
  if orca.data.cell[y][x] ~= '.' then screen.level(1) screen.rect(map_x(x), map_y(y), 3,3 ) screen.fill()
  elseif orca.data.cell.params[y][x].lit then screen.level(4) screen.rect(map_x(x), map_y(y), 3,3 ) screen.fill() end end end
  screen.level(2) screen.rect(map_x(x_index), map_y(y_index), 24, 14 ) screen.stroke()
end

function enc(n, d)
  if n == 2 then x_index = util.clamp(x_index + d, 1, orca.XSIZE)
  elseif n == 3 then y_index = util.clamp(y_index + d, 1, orca.YSIZE) end
  update_offset(x_index, y_index)
end

function key(n, z) 
  map = n == 1 and z == 1 and true 
end

function redraw()
  screen.clear()
  draw_area(x_index, y_index)
  draw_grid()
  draw_cursor(x_index - field_offset_x , y_index - field_offset_y)
  if bar then draw_bar() end
  if map then draw_map() end
  screen.update()
end