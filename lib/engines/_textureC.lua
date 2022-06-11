local engine_textureC = {
  input_ids = {
    "octave",
    "note",
    "vel"
  },
  param_ids = {
    "mode",
    "position",
    "size",
    "dens",
    "texture",
    "drywet",
    "in_gain",
    "spread",
    "rvb",
    "feedback",
    "freeze",
    "lofi",
    "trig",
  },
  param_names = {
    "mode",
    "position",
    "size",
    "dens",
    "texture",
    "drywet",
    "in_gain",
    "spread",
    "rvb",
    "feedback",
    "freeze",
    "lofi",
    "trig",
  },
  param_display_value = nil,
  ports = {}
}

local prev_transposed

local clouds_mode = {"Granular","Stretch","Looping_Delay","Spectral"}

--- Initializes engine and sets default values.
function engine_textureC.init()
  print("textureC init()")

  -- for id in engine_textureC.param_ids do
  --   engine.commands[id].func(0)
  -- end
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_textureC.run(octave, note, cls)
  local transposed = cls:transpose(note, octave)
  local vel = cls:listen(cls.x + 3, cls.y) or 100

  if cls:neighbor(cls.x, cls.y, "*") and note ~= "." and note ~= "" then
    engine.noteOn(transposed[1], vel)
    prev_transposed = transposed
  else
    if prev_transposed ~= nil then
      engine.noteOff(prev_transposed[1])
    end
  end
end

local function mode_value(index)
  index = index or 1
  return util.clamp(index,1,4) - 1
end

--- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_textureC.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_textureC.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local val_norm = (val / 35) or 0
  local num = (param == 0 or param == 1) and mode_value(val) -- mode (0 -- 3)
    or param == 3 and (val_norm or 0.6) -- position  -- (0 -- 1)
    or param == 3 and (val_norm or 0.2) -- size  -- (0 -- 1)
    or param == 3 and (val_norm or 0.25) -- dens  -- (0 -- 1)
    or param == 3 and (val_norm or 0.1) -- texture  -- (0 -- 1)
    or param == 3 and (val_norm or 0.5) -- drywet  -- (0 -- 1)
    or param == 3 and (val_norm or 2) -- in_gain  -- 0.125 -- 8
    or param == 3 and (val_norm or 1) -- spread  -- (0 -- 1)
    or param == 3 and (val_norm or 0.2) -- rvb  -- (0 -- 1)
    or param == 3 and (val_norm or 0.2) -- feedback  -- (0 -- 1)
    or param == 3 and (val_norm or 0) -- freeze  -- (0 -- 1)
    or param == 3 and (val_norm or 0) -- lofi  -- (0 -- 1)
    or param == 3 and (val_norm or 0) -- trig  -- (0 -- 1)
    or val_norm

  local id = engine_textureC.param_ids[param]
  
  engine_textureC.param_display_value = ((param == 0 or param == 1) and clouds_mode[num+1]) or nil

  if cls:neighbor(cls.x, cls.y, "*") and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[id].func(num)
    end
  end
end

return engine_textureC

