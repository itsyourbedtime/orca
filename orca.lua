-- ORCA
-- v0.9.9.8 @its_your_bedtime
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
local dot_density = 7
local copy_buffer = { }

local orca = {
  project = 'untitled',
  XSIZE = 60,
  YSIZE = 60,
  frame = 0,
  grid = { },
  vars = { },
  cell = { },
  locks = { },
  inf = { },
  active_notes = { },
  music = require 'musicutil',
  euclid = require 'er',
  chars = keycodes.chars,
  base36 = keycodes.base36,
  num = keycodes.num,
  keyboard = hid.connect( ),
  g = grid.connect( ),
  notes = { "C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B" },
  xy = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } },
  sc_ops = { count = 0, max = 6, pos = {0, 0, 0, 0, 0, 0} },
}

-- midi / audio related
function orca.normalize(n)
  return n == 'e' and 'F' or n == 'b' and 'C' or n
end

function orca.transpose(n, o)
  local n = (n == nil or n == '.') and 'C' or tostring(n)
  local o = (o == nil or o == '.' )and 3 or o
  local note = orca.normalize(string.sub(transpose_table[n], 1, 1))
  local octave = util.clamp(orca.normalize(string.sub(transpose_table[n], 2)) + o, 0, 8)
  local value = tab.key(orca.notes, note)
  local id = math.ceil( util.clamp((octave * 12) + value, 0, 127) - 1)
  return {id, value, note, octave, orca.music.note_num_to_name(id)}
end

function orca.sc_clear_region(p, l) 
  softcut.buffer_clear_region(orca.sc_ops.pos[p], l) 
end

function orca:add_note(ch, note, length, mono)
  local id = self.index_at(self.x,self.y)
  if orca.active_notes[id] == nil then
    orca.active_notes[id] = {}
  end
  if mono then
    orca.active_notes[id][ch] = {note, length}
  else
    if orca.active_notes[id][note] ~= nil then orca.midi_out_device:note_off(note, nil, ch)
      orca.active_notes[id][note] = {note, length}
    end
  end
end

function orca:notes_off(ch)
  local id = self.index_at(self.x,self.y)
  if orca.active_notes[id] ~= nil then
    for k, v in pairs(orca.active_notes[id]) do
      local note, length = self.active_notes[id][k][1], self.active_notes[id][k][2]
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
      orca.cell = saved
      local name = string.sub(string.gsub(pth, '%w+/',''),2,-6)
      orca.project = name 
      softcut.buffer_read_mono(norns.state.data .. name .. '_buffer.aif', 0, 0, #orca.chars, 1, 1)
      params:read(norns.state.data .. name ..".pset")
      print ('loaded ' .. norns.state.data .. name .. '_buffer.aif')
    else
      print("no data")
    end
  end
end

function orca.save_project(txt)
  if txt then orca.project = txt
    tab.save(orca.cell, norns.state.data .. txt ..".orca")
    softcut.buffer_write_mono(norns.state.data..txt .."_buffer.aif",0,#orca.chars, 1)
    params:write(norns.state.data .. txt .. ".pset")
    print ('saved ' .. norns.state.data .. txt .. '_buffer.aif')
  else print("save cancel") end
end

-- cut / copy / paste

function orca.copy_area( delete ) copy_buffer = { }
  for y=y_index, y_index + selected_area_y - 1 do 
    copy_buffer[y -  y_index ] = {}
    for x = x_index - 1, (x_index + selected_area_x) - 1 do
      copy_buffer[y - y_index ][x - x_index ] = orca.copy(orca.cell[y][x])
      if delete then orca.erase(x, y) end
    end
  end
end

function orca.paste_area()
  local b = copy_buffer
  for y=0, #b or 1 do 
    for x = 0, #b[y] or 1 do
    if orca.inbounds(x_index + x, y_index + y) then
      orca.erase(x_index + x , y_index + y)
      orca.cell[y_index + y][(x_index + x)] = b[y][x] or '.' 
      end 
    end 
  end
end

-- core
function orca.up(i) 
  local l = tostring(i) return string.upper(l) or '.'
end

function orca.inbounds(x, y)
  return ((x > 0 and x < orca.XSIZE) and (y > 0 and y < orca.YSIZE)) and true
end

function orca:replace(i)
  self.cell[self.y][self.x] = i
end

function orca:explode()
  self:replace('*')
end

function orca:listen(x, y)
  local l = string.lower(self:glyph_at(x,y) or '.') return self.base36[l] 
end

function orca:glyph_at(x, y) 
  if not self.inbounds(x, y) then return '.'  else l = self.cell[y][x] return l end 
end

function orca.locked(x, y)
  local p = orca.locks[orca.index_at(x, y)] return p and p[1] or false
end

function orca.erase(x, y) 
  orca.cleanup(x, y) orca.cell[y][x] = '.'  
end

function orca.index_at(x, y) 
  return x + (orca.XSIZE * y)
end

function orca.op(x, y) 
  local c = orca.cell[y][x] return (library[orca.up(c)] ~= nil) and true 
end


function orca:banged()
  for i = 1, 4 do
    if self.cell[self.y + self.xy[i][2]][self.x + self.xy[i][1]] == '*' then
    self.unlock(self.x, self.y) 
    return true end
  end
end

function orca.copy(obj)
  if type(obj) ~= 'table' then return obj end local res = {} 
  for k, v in pairs(obj) do res[orca.copy(k)] = orca.copy(v) end
  return res
end

function orca:write(x, y, g)
  if not self.inbounds(self.x + x, self.y + y) then return false
  elseif self.cell[self.y + y][self.x + x] == g then return false 
  else self.cell[self.y + y][self.x + x] = g return true end
end

function orca.lock(x, y, locks, dot, active, out)
  local at = orca.index_at(x, y)  
  orca.locks[at] = { locks, dot, active, out }
end

function orca.unlock(x, y, locks, dot, active, out)
  local at = orca.index_at(x, y)
  orca.locks[at] = {locks, false, active, out}
end

function orca:shift(s, e)
  local data = orca.cell[self.y][self.x + s]
  table.remove(orca.cell[self.y], self.x + s)
  table.insert(orca.cell[self.y], self.x + e, data)
end


function orca:move(x, y)
  local a, b = self.y + y, self.x + x
  if self.inbounds(b,a) then
    local c = orca.cell[a][b]
    if c ~= '.' and c ~= '*' then 
      self:explode()
    else 
      local l = orca.cell[self.y][self.x]
      self:replace('.') 
      orca.cell[a][b] = l 
    end
  else 
    self:explode() 
  end
end

function orca:spawn(p)
  local at =  self.index_at(self.x, self.y)
  self.inf[at] = self.name 
  self.locks[at] = { false, false, not self.passive, false }
  for k = 1, #p do 
    local x, y, info, type = self.x + p[k][1], self.y + p[k][2], p[k][3], p[k][4]
    if self.inbounds(x, y) then 
      self.lock(x, y, (type == 'input' or type == 'output') and true, true, false, type == 'output' and true ) 
      self.inf[self.index_at(x, y)] = p[k][3] 
    end 
  end
end

function orca.cleanup(x, y)
  local at = orca.index_at(x,y)
  orca.locks[at] = { false, false, false, false }
  orca.inf[at] = nil
  if orca.cell[y][x] == '/' then 
    softcut.play(orca:listen(x + 1, y) or 1, 0) 
    orca.sc_ops.count = util.clamp(orca.sc_ops.count - 1, 0, orca.sc_ops.max) 
  end

end

-- exec
function orca:parse()
  local a,b = {},1 
  for y = 0, self.YSIZE do 
    for x = 0, self.XSIZE do
      if self.op(x, y) then 
        local g = self.cell[y][x] 
        local o =  library[self.up(g)] 
        local x, y, g = x, y, g 
        a[b] = { o, x, y, g }
        b = b + 1
      end 
    end 
  end 
  self.locks = {}  --self.inf = {}
  return a
end

function orca:operate()
  self.frame = self.frame + 1 
  local l = self:parse()
  for i = 1, #l do 
    local op, x, y, g = l[i][1], l[i][2], l[i][3], l[i][4]
    if not self.locked(x, y) then 
      op(self, x, y, g) 
    end 
  end
end

-- grid 
function orca.g.key(x, y, z) 
  local last = orca.grid[y][x] 
  orca.grid[y][x] = z == 1 and 15 or last < 6 and last or 0 
end

function orca.g.redraw() 
  for y = 1, orca.g.rows do 
    for x = 1, orca.g.cols do 
      orca.g:led(x, y, orca.grid[y][x] or 0  ) 
      end 
    end 
  orca.g:refresh()
end

function init()
  -- 
  for y = 0, orca.YSIZE do 
    orca.cell[y] = {} 
    for x = 0, orca.XSIZE do 
      orca.cell[y][x] = '.' 
    end 
  end
  for i = 1, orca.g.rows do 
    orca.grid[i] = {} 
  end
  -- 
  clock.on_step = function() orca:operate()  orca.g:redraw() end,
  clock:add_clock_params()
  clock:start()
  --
  params:set("bpm", 120)
  params:add_separator()
  params:add_trigger('save_p', "< Save project" )
  params:set_action('save_p', function(x) textentry.enter(orca.save_project,  orca.project) end)
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
  -- 
  params:add_separator()
  orca.midi_out_device = midi.connect(1)
  orca.midi_out_device.event = function() end
  params:add{ type = "number", id = "midi_out_device", name = "midi out device", min = 1, max = 4, default = 1,
  action = function(value) orca.midi_out_device = midi.connect(value) end }
  --
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
    if not orca.locked(x_index,y_index) and keyinput ~= orca.cell[y_index][x_index] then orca.erase(x_index,y_index)
    if orca.cell[y_index][x_index] == '/' then orca.sc_ops.count = util.clamp(orca.sc_ops.count - 1, 1, orca.sc_ops.max) end end 
    orca.cell[y_index][x_index] = keyinput or '.' end
    if ctrl then if code == 45 then orca.copy_area(true) elseif code == 46 then orca.copy_area() elseif code == 47 then orca.paste_area() end end
    end
  end
end

local function draw_op_frame(x, y, b)
  screen.level(b) screen.rect(( x * 5 ) - 5, (( y * 8 ) - 5 ) - 3, 5, 8) screen.fill()
end

local function draw_grid()
  screen.font_face(25)
  screen.font_size(6)
  for y= 1, bounds_y do 
    local y = y + field_offset_y for x = 1, bounds_x do
    local x = x + field_offset_x
    local f = orca.locks[orca.index_at(x,y)] or {}
    local cell = orca.cell[y][x] or '.'
    local ofst = ( x % dot_density == 0 and y % util.clamp(dot_density - 1, 1, 8) == 0 )
    if f[3] then draw_op_frame(x - field_offset_x, y - field_offset_y, 4) end
    if f[4] then draw_op_frame(x - field_offset_x, y - field_offset_y, 1) end
    if cell ~= '.' or cell ~= nil then screen.level( orca.op(x, y) and 15 or ( f[2] or f[3] or f[4]) and 12 or 1 )
    elseif cell == '.' then screen.level( f[2] and 9 or 1) end
    screen.move((( x - field_offset_x ) * 5) - 4 , (( y - field_offset_y )* 8) - ( orca.cell[y][x] and 2 or 3))
    if cell == '.' or cell == nil then screen.text(f.dot and '.' or ofst and ( dot_density > 4 and '+') or '.')
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
  local x_pos, y_pos = ((x * 5) - 5), ((y * 8) - 8)
  local x_index, y_index = x + field_offset_x, y + field_offset_y
  local cell = tostring(orca.cell[y_index][x_index])
  screen.level(cell == '.' and 2 or 15) screen.rect(x_pos, y_pos, 5, 8) screen.fill()
  screen.font_face(cell == '.' and 0 or 25) screen.font_size(cell == '.' and 8 or 6)
  screen.level(cell == '.' and 14 or 1) screen.move(x_pos + ((cell ~= '.' ) and 1 or 0), y_pos + 6)
  screen.text((cell == '.' or cell == nil) and '@' or cell) screen.stroke()
end

local function draw_bar()
  local text = orca.inf[orca.index_at(x_index, y_index)] or 'empty'
  screen.level(0) screen.rect(0, 56, 128, 8) screen.fill()
  screen.level(9) screen.move(2, 63) 
  screen.font_face(25) screen.font_size(6) screen.text(text) screen.stroke()
  screen.move(80,63) screen.text(params:get("bpm") .. (orca.frame % 4 == 0 and ' *' or '')) screen.stroke()
  screen.move(123,63) screen.text_right(x_index .. ',' .. y_index) screen.stroke()
end

local function map_y (p)  return ((p / orca.YSIZE) * 53) + 8 end
local function map_x (p)  return ((p / orca.XSIZE) * 117) + 5 end


local function draw_sliders()
  screen.level(1) screen.move(map_x(x_index), bar and 57 or 64) screen.line_rel(-4,0) screen.stroke()
  screen.level(1) screen.move( 128, map_y(y_index)) screen.line_rel(0,-4) screen.stroke()
end

function enc(n, d)
  if n == 2 then 
    x_index = util.clamp(x_index + d, 1, orca.XSIZE)
  elseif n == 3 then 
    y_index = util.clamp(y_index + d, 1, orca.YSIZE) 
  end
  update_offset(x_index, y_index)
end

function redraw()
  screen.clear()
  draw_area(x_index, y_index)
  draw_grid()
  draw_cursor(x_index - field_offset_x , y_index - field_offset_y)
  if bar then draw_bar() end
  draw_sliders ()
  screen.update()
end