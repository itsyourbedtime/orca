-- . . . . . . . . . . . . . . . . . . . . . .
-- . . . . . . . . . . . . . . . . . . . . . .
-- . . . . . . . . . . . . . . . . . . . . . .
-- . . . . . . . . . . . . . . . . . . . . . .
-- . . . . . . . * O R C A . . . . . . . .
-- . . . . . . . . . . . . . . . . . . . . . .
-- . . . . . . . . . . . . . . . . . . . . . .
-- . . . . . . . . . . . . . . . . . . . . . .
--
--
-- A visual programming
-- language, designed to
-- create procedural
-- sequencers on the fly.
--
-- v1.4.6
--
-- K1 + E1  Select operator
-- K1 + E2  Select value
-- K1 + E3  Select note
--
-- K2  Clear character
-- K3  Toggle play/stop
--
--
-- llllllll.co/t/orca
--
-- @its_your_bedtime
-- @neauoire
-- @robbiecloset
-- @j-flee
-- @coollerue
-- @linusschrab
-- @frederickk
--

local VERSION = "1.4.6"

local euclid = require "er"
local fileselect = require "fileselect"
local music = require "musicutil"
local tab = require "tabutil"
local textentry = require "textentry"

local ccrow = include("lib/crow")
local engines = include("lib/engines")
local json = include("lib/JSON")
local keycodes = include("lib/keycodes")
local library = include("lib/library")
local transpose_table = include("lib/transpose")

local OPS_LIST = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "$", "?", "/", "\\", "|", "-", ":", "%", "!", "&", "^", "~", "]", "}", "`", ">", "<", "=", "*", "#"}
local VAL_LIST = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

local update_id
local running = true
local keyboard = hid.connect()
local g = grid.connect()
local val_index, ops_index, notes_index = 1, 1, 1
local key_pressed = {0, 0, 0}
local string = string
local x_index, y_index, field_offset_x, field_offset_y = 1, 1, 0, 0
local selected_area_y, selected_area_x, bounds_x, bounds_y = 1, 1, 25, 8
local cell_input = nil
local bar = true
local help, map, shift, alt, ctrl, enc_active = false
local hood = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
local dot_density = 7
local copy_buffer = {}
local pt = {}
local w = 128
local h = 48

local orca = {
  project = "untitled",
  state = paramset.new(),
  w = w,
  h = h,
  frame = 0,
  grid = {},
  vars = {
    midi = {},
    midi_cc = {},
  },
  cell = {},
  locks = {},
  info = {},
  active_notes = {},
  chars = keycodes.chars,
  notes = {"C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B"},
  sc_ops = {
    count = 0,
    max = 6,
    pos = {0, 0, 0, 0, 0, 0},
  },
}

function orca.normalize(n)
  return n == "e" and "F" or n == "b" and "C" or n
end

function orca:transpose(n, o)
  local n = (n == nil or n == ".") and "C" or tostring(n)
  local o = (o == nil or o == ".") and 3 or o
  local trans = transpose_table[n]

  if trans ~= nil then
    local note = self.normalize(string.sub(trans, 1, 1))
    local octave = util.clamp(self.normalize(string.sub(trans, 2)) + o, 0, 8)
    local value = tab.key(self.notes, note)
    local id = math.ceil(util.clamp((octave * 12) + value, 0, 127) - 1)
    return {id, value, note, octave, music.note_num_to_name(id)}
  end
  return nil
end

function orca.sc_clear_region(p, l)
  softcut.buffer_clear_region(orca.sc_ops.pos[p], l)
end

function orca:gen_pattern(p, s)
  return euclid.gen(p, s)
end

function orca:get_scale(s, k)
  local name = music.SCALES[s].name
  local notes = music.generate_scale_of_length(k or 1, name, 8)

  return {string.lower(name), notes}
end

function orca:note_freq(n)
  return music.note_num_to_freq(n)
end

function orca:interval_ratio(n)
  return music.interval_to_ratio(n)
end

function orca:add_note(ch, note, length, mono)
  local id = self:index_at(self.x, self.y)
  if self.active_notes[id] == nil then
    self.active_notes[id] = {}
  end
  if mono then
    self.active_notes[id][ch] = {note, length}
  elseif not mono then
    if self.active_notes[id][note] == note then
      self.midi_out_device:note_off(note, nil, ch)
    else
      self.active_notes[id][note] = {note, length}
    end
  end
end

function orca:notes_off(ch)
  local id = self:index_at(self.x, self.y)
  if self.active_notes[id] ~= nil then
    for k, v in pairs(self.active_notes[id]) do
      local note, length = self.active_notes[id][k][1], util.clamp(self.active_notes[id][k][2], 1, 16)
      if self.frame % length == 0 then
        self.midi_out_device:note_off(note, nil, ch)
        self.active_notes[id][k] = nil
      end
    end
  end
end

function orca.load_project(pth)
  local filename = pth:match("^.+/(.+)$")
  local ext = pth:match("^.+(%..+)$")
  local file = io.open(pth, "rb")
  local name = ""

  if ext == ".orca" then
    local saved = tab.load(pth)
    if saved ~= nil then
      print("data found")
      orca.project = saved[1]
      orca.w = saved[2]
      orca.h = saved[3]
      orca.cell = saved[4]
      softcut.buffer_read_mono(norns.state.data .. saved[1] .. "_buffer.aif", 0, 0, 35, 1, 1)
      orca:try_catch_(function()
          params:read(norns.state.data .. saved[1] .. ".pset")
        end,
        function(e)
          print("load_project warning:", e)
        end
      )
      orca.state:set("project", pth)
      print("loaded", pth)
      print("loaded " .. norns.state.data .. saved[1] .. "_buffer.aif")
    else
      print("no data")
    end
  elseif ext == ".json" then
    name = string.gsub(filename, ".json", "")
    local file = io.open(pth, "rb")
    if file then
      local json_file_str = file:read "*a"
      file:close()
      local json = json:decode(json_file_str)
      local l = {json[1], json[2], json[3], json[4]}
      tab.save(l, norns.state.data .. json[1] .. "_import.orca")
      print("imported '" .. norns.state.data .. name .. ".json' as '" .. norns.state.data .. json[1] .. "_import.orca'")
    end
  elseif ext == ".txt" then
    name = string.gsub(filename, ".txt", "")
    if file then
      cell = {}
      for line in io.lines(pth) do
        chars = {}
        for i = 1, #line do
          chars[i] = line:sub(i, i)
        end
        cell[#cell + 1] = chars
      end

      local l = {name, #cell[1], #cell, cell}
      tab.save(l, norns.state.data .. name .. "_import.orca")
      print("imported '" .. norns.state.data .. name .. ".txt' as '" .. norns.state.data .. name .. "_import.orca'")
    end
  else
    print("Error: no file found at " .. pth)
    return
  end

  if util.file_exists(norns.state.data .. name .. "_import.orca") then
    orca.load_project(norns.state.data .. name .. "_import.orca")
    orca.state:set("project", norns.state.data .. name .. "_import.orca")
  end
end

function orca.save_project(txt)
  if txt then
    local l = {txt, orca.w, orca.h, orca.cell}
    local full_path = norns.state.data .. txt
    tab.save(l, full_path .. ".orca")
    softcut.buffer_write_mono(full_path .. "_buffer.aif", 0, 35, 1)
    params:write(full_path .. ".pset")
    orca.state:set("project", full_path .. ".orca")
    print("saved " .. full_path .. "_buffer.aif")
  else
    print("save canceled")
  end
end

function orca.export(txt)
  if txt then
    local l = {txt, orca.w, orca.h, orca.cell}
    local full_path = norns.state.data .. txt
    local json = json:encode_pretty(l)
    local json_file = io.open(full_path .. ".json", "w+")
    io.output(json_file)
    io.write(json)
    io.close(json_file)
    print("exported JSON " .. full_path .. ".json")

    local txt_file = io.open(full_path .. ".txt", "w+")
    io.output(txt_file)
    for i = 1, #orca.cell do
      for j = 1, #orca.cell[i] do
        io.write(orca.cell[i][j])
      end
      io.write("\n")
    end
    io.close(txt_file)
    print("exported TXT " .. full_path .. ".txt")
  end
end

function orca:copy_area(a, b, cut)
  copy_buffer = {}
  for y = b, (b + selected_area_y) - 1 do
    copy_buffer[(y - b) + 1] = {}
    for x = a, (a + selected_area_x) - 1 do
      copy_buffer[(y - b) + 1][(x - a) + 1] = self.cell[y][x]
      if cut then self:erase(x, y) end
    end
  end
end

function orca:paste_area(a, b)
  if #copy_buffer > 0 then
    for y= 1, #copy_buffer do
      for x = 1, #copy_buffer[y] do
        self.cell[(b + y) - 1][(a + x) - 1] = copy_buffer[y][x] or "."
      end
    end
  end
end

function orca.up(i)
  return i and string.upper(i) or "."
end

function orca:inbounds(x, y)
  return ((x > 0 and x < self.w) and (y > 0 and y < self.h)) and true
end

function orca:replace(i)
  self.cell[self.y][self.x] = i
end

function orca:explode()
  self:replace("*")
end

function orca:listen(x, y)
  local l = string.lower(self:glyph_at(x, y))
  return l ~= "." and keycodes.base36[l] or false
end

function orca:glyph_at(x, y)
  if self:inbounds(x, y) then
    return self.cell[y][x] or "."
  else
    return "."
  end
end

function orca:locked(x, y)
  local p = self.locks[self:index_at(x, y)]
  return p and p[1] or false
end

function orca:erase(x, y)
  local at = self:index_at(x, y)
  self:unlock(x, y)
  if self.cell[y][x] == "/" then
    softcut.play(self:listen(x + 1, y) or 1, 0)
    self.sc_ops.count = util.clamp(self.sc_ops.count - 1, 0, 6)
  end
  self.cell[y][x] = "."
  self.info[at] = "empty"
end

function orca:index_at(x, y)
  return x + (self.w * y)
end

function orca:op(x, y)
  local c = self.cell[y][x] return (library[self.up(c)] ~= nil) and true
end

function orca:neighbor(x, y, g)
  for i = 1, 4 do
    if not self:inbounds(x + hood[i][1], y + hood[i][2]) then
      return false
    elseif self.cell[y + hood[i][2]][x + hood[i][1]] == g then
      self:unlock(x, y)
      return true
    end
  end
end

function orca:write(x, y, g)
  if not self:inbounds(self.x + x, self.y + y) then return false
  elseif self.cell[self.y + y][self.x + x] == g then return false
  else self.cell[self.y + y][self.x + x] = g return true end
end

function orca:lock(x, y, locks, dot, active, out)
  local at = self:index_at(x, y)
  self.locks[at] = {locks, dot, active, out}
end

function orca:unlock(x, y, locks, dot, active, out)
  local at = self:index_at(x, y)
  self.locks[at] = {locks, false, active, out}
end

function orca:shift(s, e)
  if self:inbounds(self.x + e, self.y) then
    local data = self.cell[self.y][self.x + s]
    table.remove(self.cell[self.y], self.x + s)
    table.insert(self.cell[self.y], self.x + e, data)
  end
end

function orca:move(x, y)
  local a, b = self.y + y, self.x + x
  if self:inbounds(b, a) then
    local c = orca.cell[a][b]
    if c ~= "." and c ~= "*" then
      self:explode()
    else
      local l = self.cell[self.y][self.x]
      self:replace(".")
      self.cell[a][b] = l
    end
  else
    self:explode()
  end
end

function orca:spawn(p)
  local at = self:index_at(self.x, self.y)
  self.info[at] = self.name
  self.locks[at] = {false, false, true, false}

  for k = 1, #p do
    local x, y, info = self.x + p[k][1], self.y + p[k][2], p[k][3]
    self:lock(x, y, self.x < x or self.y < y and true, true, false, self.y < y and true)
    self.info[self:index_at(x, y)] = p[k][3]
  end
end

--- FIXME(frederickk): Hack to handle misc. I/O errors.
function orca:try_catch_(f, catch_f)
  local status, exception = pcall(f)
  if not status then
    catch_f(exception)
  end
end

--- exec
function orca:parse()
  local b = 1

  for y = 1, self.h do
    for x = 1, self.w do
      if self:op(x, y) then
        pt[b] = {x, y, self.cell[y][x]}
        b = b + 1
      end
    end
  end
end

function orca:operate()
  self.locks = {}
  self.info = {}
  self:parse()

  for i = 1, #pt do
    local x, y, g = pt[i][1], pt[i][2], pt[i][3]
    if not self:locked(x, y) then
      local op = self.up(g)
      if op == g or self:neighbor(x, y, "*") then
        library[op](self, x, y)
      end
    end
  end

  pt = {}
  self.frame = self.frame + 1
end

--- grid
function g.key(x, y, z)
  local last = orca.grid[y][x]
  orca.grid[y][x] = z == 1 and 15 or last < 6 and last or 0
end

function g.redraw()
  for y = 1, 8 do
    for x = 1, 16 do
      g:led(x, y, orca.grid[y][x] or 0 )
    end
  end
  g:refresh()
end

function orca:init_field(w, h)
  self.w = w
  self.h = h

  for y = 0, self.h do
    self.cell[y] = {}
    for x = 0, self.w do
      self.cell[y][x] = "."
    end
  end

  self.locks = {}
  self.info = {}
end

function orca:clear()
  self:init_field(w, h)
  for i = 1, 8 do self.grid[i] = {} end
end

function orca:reload()
  self:clear()

  engines.init(self)

  redraw_metro = metro.init(function(stage)
    redraw()
  end, 1 / 60)
  redraw_metro:start()

  clock.transport.start()

  screen.ping()
end

local function add_params()
  -- params:add_number("clock_tempo")

  orca.state:add_text("project")
  orca.state:hide("project")

  params:add_separator("LOAD/SAVE")
  params:add_trigger("save_p", "< Save project")
  params:set_action("save_p", function(x)
    textentry.enter(orca.save_project, orca.project)
  end)

  params:add_trigger("load_p", "> Load project")
  params:set_action("load_p", function(x)
    fileselect.enter(norns.state.data, orca.load_project)
  end)

  params:add_trigger("export_p", "« Export txt")
  params:set_action("export_p", function(x)
    textentry.enter(orca.export, orca.project)
  end)

  params:add_trigger("new", "+ New")
  params:set_action("new", function(x)
    orca.state:set("project", "")
    orca:reload()
  end)

  -- TODO(frederickk): Implement Midi passthrough.
  params:add_separator("MIDI")
  params:add_number("midi_out_device", "Midi out device", 1, 4, 1)
  params:set_action("midi_out_device", function(val)
    orca.midi_out_device = midi.connect(val)
  end)

  ccrow.add_params()
  engines.add_params()

  -- load saved params
  params:read()
  orca.state:read(norns.state.data .. "orca-state.pset")

  if orca.state:get("project") ~= "" then
    print(orca.state:get("project"))
    orca.load_project(orca.state:get("project"))
  end
end

function update()
  while true do
    clock.sync(1 / 4) -- fires every quarter note
    orca:operate()
    g:redraw()
  end
end

function clock.transport.start()
  -- prevents CLOCK > RESET from creating a new clock.
  if running then
    return
  end

  print("Start Clock")
  update_id = clock.run(update)
  running = true
end

function clock.transport.stop()
  print("Stop Clock")
  clock.cancel(update_id)
  running = false
end

--- Copies ./tutorials into ~/dust/data/orca/tutorials
function install_tutorials()
  local demo_dir = norns.state.path .. "/tutorials"
  local data_demo_dir = _path.data .. norns.state.name .. "/tutorials"

  if util.file_exists(data_demo_dir) == false then
    util.make_dir(data_demo_dir)

    if util.file_exists(demo_dir) and util.file_exists(data_demo_dir) then
      for _, dir in ipairs(util.scandir(demo_dir)) do
        local from = demo_dir .. "/" .. dir
        local to = data_demo_dir .. "/" .. dir
        util.make_dir(to)
        util.os_capture("cp " .. from .. "* " .. to)
      end
    end
  end
end

function init()
  print(norns.state.name .. " v" .. VERSION)

  orca:reload()
  orca.midi_out_device = midi.connect(1)
  orca.midi_out_device.event = function(data)
    local m = midi.to_msg(data)
    if m.type == "cc" then
      orca.vars.midi_cc[m.cc] = m.val
    elseif m.type == "note_on" then
      orca.vars.midi[m.ch] = m.note
    end
  end

  add_params()
  install_tutorials()

  update_id = clock.run(update)
end


--- UI / controls
local function update_offset(x, y)
  if x < bounds_x + (field_offset_x - 24) then
    field_offset_x = util.clamp(field_offset_x - (ctrl and 9 or 1), 0, orca.w - field_offset_x)
  elseif x > field_offset_x + 25 then
    field_offset_x = util.clamp(field_offset_x + (ctrl and 9 or 1), 0, orca.w - bounds_x)
  end
  if y > field_offset_y + (bar and 7 or 8) then
    field_offset_y = util.clamp(field_offset_y + (ctrl and 9 or 1), 0, orca.h - bounds_y)
  elseif y < bounds_y + (field_offset_y - 7) then
    field_offset_y = util.clamp(field_offset_y - (ctrl and 9 or 1), 0, orca.h - bounds_y)
  end
end

local function get_key(code, val, shift)
  if keycodes.keys[code] ~= nil and val == 1 then
    if shift then if keycodes.shifts[code] ~= nil then return keycodes.shifts[code]
    else return keycodes.keys[code] end
    else return string.lower(keycodes.keys[code]) end
  end
end

local kb = {
  s = {[42] = true, [54] = true},
  c = {[29] = true, [125] = true, [127] = true, [97] = true}
}
function keyboard.event(typ, code, val)
  local menu = norns.menu.status()

  if kb.s[code] then
    shift = (val == 1 or val == 2) and true
  elseif kb.c[code] then
    ctrl = (val == 1 or val == 2) and true
  elseif (code == hid.codes.KEY_LEFT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x - (ctrl and 9 or 1), 1, orca.w)
      else x_index = util.clamp(x_index - (ctrl and 9 or 1), 1, orca.w) end
      update_offset(x_index, y_index)
    elseif menu then if ctrl then _norns.enc(1, -8) else _norns.enc(3, shift and -20 or -2) end end
  elseif (code == hid.codes.KEY_RIGHT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x + (ctrl and 9 or 1), 1, orca.w - x_index)
      else x_index = util.clamp(x_index + (ctrl and 9 or 1), 1, orca.w) end
      update_offset(x_index, y_index)
    elseif menu then if ctrl then _norns.enc(1, 8) else _norns.enc(3, shift and 20 or 2) end end
  elseif (code == hid.codes.KEY_DOWN) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y + (ctrl and 9 or 1), 1, orca.h - y_index)
      else y_index = util.clamp(y_index + (ctrl and 9 or 1), 1, orca.h) end
      update_offset(x_index, y_index)
    elseif menu then _norns.enc(2, shift and 104 or 2) end
  elseif (code == hid.codes.KEY_UP) and (val == 1 or val == 2) then
    if not menu then
      if shift then
        selected_area_y = util.clamp(selected_area_y - (ctrl and 9 or 1), 1, orca.h)
      else
        y_index = util.clamp(y_index - (ctrl and 9 or 1), 1, orca.h)
      end
      update_offset(x_index, y_index)
    elseif menu then
      _norns.enc(2, shift and -104 or -2)
    end
  elseif code == 56 then
    alt = (val == 1 or val == 2) and true or false
  elseif (code == hid.codes.KEY_TAB and val == 1) then
    if not alt then bar = not bar
    elseif alt then map = not map end
  elseif (code == 14 or code == 111) then
    orca:erase(x_index, y_index)
  elseif code == 58 or code == 56 then -- caps/alt
  elseif code == 110 then
    orca:paste_area(x_index, y_index)
  elseif code == 102 then
    x_index, y_index, field_offset_x, field_offset_y = 1, 1, 1, 1
    update_offset(x_index, y_index)
  elseif (code == hid.codes.KEY_ESC and (val == 1 or val == 2)) then
    selected_area_y, selected_area_x = 1, 1
    map = false
    if shift then
      norns.menu.toggle(not menu)
    elseif menu and not shift then
      _norns.key(2, 1)
    end
  elseif (code == hid.codes.KEY_ENTER and val == 1) then
    if menu then
      _norns.key(3, 1)
    else
      if orca:op(x_index, y_index) then
        local g = orca.up(orca:glyph_at(x_index, y_index))
        library[g](orca, x_index, y_index)
      end
    end
  elseif (code == hid.codes.KEY_SPACE) and (val == 1) then
    if running then
      clock.transport.stop()
      engine.noteKillAll()
      for i = 1, 6 do
        softcut.play(i, 0)
      end
    else
      clock.transport.start()
    end
  elseif ctrl and (code == hid.codes.KEY_COMMA) and (val == 1 or val == 2) then
    params:set("clock_tempo", params:get("clock_tempo") - 10)
  elseif ctrl and (code == hid.codes.KEY_DOT) and (val == 1 or val == 2) then
    if params:get("clock_tempo") == 1 then
      params:set("clock_tempo", 10)
    else
      params:set("clock_tempo", params:get("clock_tempo") + 10)
    end
  else if val == 1 then
    local keyinput = get_key(code, val, shift)
    if not ctrl then
        if orca.cell[y_index][x_index] == "/" then
          orca.sc_ops.count = util.clamp(orca.sc_ops.count - 1, 1, 6)
        end
      cell_input = keyinput
      orca.cell[y_index][x_index] = keyinput
      elseif ctrl then
        if code == 45 then
          orca:copy_area(x_index, y_index, true)
        elseif code == 46 then
          orca:copy_area(x_index, y_index)
        elseif code == 47 then
          orca:paste_area(x_index, y_index)
        end
      end
   end
 end
end

local function draw_op_frame(x, y, b)
  screen.level(b)
  screen.rect((x * 5) - 5, ((y * 8) - 5) - 3, 5, 8)
  screen.fill()
end

local function draw_grid()
  screen.font_face(25)
  screen.font_size(6)
  for y = 1, bounds_y do
    for x = 1, bounds_x do
      local y = y + field_offset_y
      local x = x + field_offset_x
      local f = orca.locks[orca:index_at(x, y)] or {false, false, false, false}
      local cell = orca.cell[y][x]
      local ofst = (x % dot_density == 0 and y % util.clamp(dot_density - 1, 1, 8) == 0)
      if f[3] then draw_op_frame(x - field_offset_x, y - field_offset_y, 4) end
      if f[4] then draw_op_frame(x - field_offset_x, y - field_offset_y, 1) end

      if cell ~= "." then
        if (orca:op(x, y) and cell == orca.up(cell)) or orca:neighbor(x, y, "*") then
          screen.level(15)
        elseif f[2] then
          screen.level(9)
        else
          screen.level(1)
        end
      else
        screen.level(f[2] and 9 or 1)
      end

      screen.move(((x - field_offset_x) * 5) - 4, ((y - field_offset_y)* 8) - (cell and 2 or 3))

      if cell == "." or cell == nil then
        screen.text(f.dot and "." or ofst and (dot_density > 4 and "+") or ".")
      else
        screen.text(cell)
      end
      screen.stroke()
    end
  end
end

local function draw_area(x, y)
  local x_pos = (((x - field_offset_x) * 5) - 5)
  local y_pos = (((y - field_offset_y) * 8) - 8)

  screen.level(2)
  screen.rect(x_pos, y_pos, 5 * selected_area_x, 8 * selected_area_y)
  screen.fill()
end

local function draw_cursor(x, y)
  local x_pos, y_pos = ((x * 5) - 5), ((y * 8) - 8)
  local x_index, y_index = x + field_offset_x, y + field_offset_y
  local cell = cell_input

  screen.level(cell == "." and 2 or 15)
  screen.rect(x_pos, y_pos, 5, 8)
  screen.fill()
  screen.font_face(cell == "." and 0 or 25)
  screen.font_size(cell == "." and 8 or 6)
  screen.level(cell == "." and 14 or 1)
  screen.move(x_pos + ((cell ~= ".") and 1 or 0), y_pos + 6)
  screen.text((cell == "." or cell == nil) and "@" or cell)
  screen.stroke()
end

local function draw_bar()
  local text = orca.info[orca:index_at(x_index, y_index)] or "empty"
  screen.level(0)
  screen.rect(0, 56, 128, 8)
  screen.fill()

  screen.level(9)
  screen.move(2, 63)

  screen.font_face(25)
  screen.font_size(6)
  screen.text(string.sub(text, 0, 12))
  screen.stroke()

  screen.move(55, 63)
  screen.text(string.sub(engine.name, 0, 6))
  screen.stroke()

  screen.move(85, 63)
  screen.text(params:get("clock_tempo") .. (orca.frame % 4 == 0 and " *" or ""))
  screen.stroke()

  screen.move(123, 63)
  screen.text_right(x_index .. "," .. y_index)
  screen.stroke()
end

local function scale_slider_y(p)
  return ((p / orca.h) * 53) + 8
end

local function scale_slider_x(p)
  return ((p / orca.w) * 117) + 5
end

local function draw_sliders()
  screen.level(1)
  screen.move(scale_slider_x(x_index), bar and 57 or 64)
  screen.line_rel(-4, 0)
  screen.stroke()
  screen.level(1)
  screen.move(128, scale_slider_y(y_index))
  screen.line_rel(0, -4)
  screen.stroke()
end

local function scale_map_y(p)
  return ((p / orca.h) * 47) + 2
end

local function scale_map_x(p)
  return ((p / orca.w) * 93) + 15
end

local function draw_map()
  local c = orca.cell
  screen.level(15)
  screen.rect(14, 0, 100, 55)
  screen.fill()
  screen.level(0)
  screen.rect(15, 1, 98, 53)
  screen.fill()

  for y = 1, orca.h do
    for x = 1, orca.w do
      if c[y][x] ~= "." then
        screen.level(2)
        screen.rect(scale_map_x(x), scale_map_y(y), 2, 2)
        screen.fill()
      end
    end
  end

  screen.level(15)
  screen.rect(scale_map_x(x_index), scale_map_y(y_index), 3, 3)
  screen.fill()
end

--- Events
function key(n, is_pressed)
  key_pressed[n] = is_pressed

  if n == 1 and is_pressed == 0 then
    -- TODO(frederickk): On 1st click set current char to value.
    if enc_active == true and cell_input then
      orca.cell[y_index][x_index] = cell_input
      cell_input = "."
      enc_active = false
    end
  elseif n == 2 and is_pressed == 1 then
    orca:erase(x_index, y_index)
    cell_input = "."
  elseif n == 3 and is_pressed == 1 then
    if running then
      clock.transport.stop()
    else
      clock.transport.start()
    end
  end
end

function enc(n, delta)
  if key_pressed[1] == 1 then
    enc_active = true

    if n == 1 then
      ops_index = util.clamp((ops_index + delta) % (#OPS_LIST + 1), 1, #OPS_LIST + 1)
      cell_input = OPS_LIST[ops_index]
    end
    if n == 2 then
      val_index = util.clamp((val_index + delta) % (#VAL_LIST + 1), 1, #VAL_LIST + 1)
      cell_input = VAL_LIST[val_index]
    end
    if n == 3 then
      notes_index = util.clamp((notes_index + delta) % (#orca.notes + 1), 1, #orca.notes + 1)
      cell_input = orca.notes[notes_index]
    end
  else
    if n == 2 then
      x_index = util.clamp(x_index + delta, 1, orca.w)
    elseif n == 3 then
      y_index = util.clamp(y_index + delta, 1, orca.h)
    end
    update_offset(x_index, y_index)
  end
end

--- UI
function redraw()
  screen.clear()
  draw_area(x_index, y_index)
  draw_grid()
  draw_cursor(x_index - field_offset_x, y_index - field_offset_y)

  if bar then
    draw_bar()
  end

  if map then
    draw_map()
  end

  draw_sliders()
  screen.update()
end

--- Writes Orca state params on script end.
function cleanup()
  orca.state:write(norns.state.data .. "orca-state.pset")
end

