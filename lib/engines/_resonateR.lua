local engine_resonateR = {
  input_ids = {
    "octave",
    "note",
    "vel"
  },
  param_ids = {
    "model",
    "struct",
    "bright",
    "damp",
    "position",
    "poly",
    "intern_exciter",
    "bypass",
    "easteregg",
  },
  param_names = {
    "Model",
    "Struct",
    "Bright",
    "Damp",
    "Position",
    "Poly",
    "Intern Exciter",
    "Bypass",
    "Easter Egg",
  },
  param_display_value = nil,
  ports = {}
}

local prev_transposed

local rings_models = {"Modal Resonator","Sympathetic String","Mod/Inharm String","2-Op Fm Voice","Sympth Str Quant","String And Reverb"}
local rings_egg_models = {"FX Formant","FX Chorus","FX Reverb","FX Formant","FX Ensemble","FX Reverb"}

--- Initializes engine and sets default values.
function engine_resonateR.init()
  print("resonateR init()")

  -- for id in engine_resonateR.param_ids do
  --   engine.commands[id].func(0)
  -- end
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_resonateR.run(octave, note, cls)
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

local function model_value(index)
  index = index or 1
  return util.clamp(index,1,6) - 1
end

local function easteregg_value(index)
  index = index or 1
  return util.clamp(index,1,6) - 1
end

--- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_resonateR.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_resonateR.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local val_norm = (val / 35) or 0
  local num = (param == 0 or param == 1) and model_value(val) -- model
    or param == 2 and (val_norm or 0.5) -- struct
    or param == 3 and (val_norm or 0.3) -- bright
    or param == 4 and (val_norm or 0.25) -- damp
    or param == 5 and (val_norm or 0.5) -- position
    or param == 6 and (val or 4) -- poly
    or param == 7 and (val_norm or 0) -- intern_exciter
    or param == 8 and (val or 0) -- bypass
    or param == 9 and easteregg_value(val) -- easteregg
    or val_norm

  local id = engine_resonateR.param_ids[param]

  engine_resonateR.param_display_value = ((param == 0 or param == 1) and rings_models[num+1]) or nil

  if cls:neighbor(cls.x, cls.y, "*") and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[id].func(num)
    end
  end
end

return engine_resonateR

