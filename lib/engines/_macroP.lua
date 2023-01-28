
local engine_macroP = {
  input_ids = {
    "octave",
    "note",
    "vel"
  },
  param_ids = {
    "eng",
    "harm",
    "timbre",
    "morph",
    "level",
    "fm_mod",
    "timb_mod",
    "morph_mod",
    "decay",
    "lpg_colour"
  },
  param_names = {
    "Engine",
    "Harmonics",
    "Timbre",
    "Morph",
    "Level",
    "FM Mod",
    "Timbre Mod",
    "Morph Mod",
    "Decay",
    "LPG Colour"
  },
  param_display_value = nil,
  ports = {}
}

local prev_transposed
local synthesis_engines = {"virtual analog","waveshaping","fm","grain","additive","wavetable","chord","speech","swarm","noise","particle","string","modal","bass drum","snare drum","hi hat"}

local function engine_map(index)
  index = index or 1
  return ((index - 1) % #synthesis_engines) + 1
end

--- Initializes engine and sets default values.
function engine_macroP.init()
  print("macroP init()")

  -- for id in engine_macroP.param_ids do
  --   engine.commands[id].func(0)
  -- end
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_macroP.run(octave, note, cls)
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

--- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_macroP.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_macroP.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local val_norm = (val / 35) or 0
  local num = (param == 0 or param == 1) and engine_map(val) -- engine, have to rename to avoid name conflict
            or param == 2 and (val_norm or 0.5) -- harmonics 
            or param == 3 and (val_norm or 0.5) -- timbre
            or param == 4 and (val_norm or 0.5) -- morph
            or param == 5 and (val_norm or 0) -- level 
            or param == 6 and (val_norm or 0) -- fm_mod
            or param == 7 and (val_norm or 0) -- timbre_mod
            or param == 8 and (val_norm or 0) -- morph_mod
            or param == 9 and (val_norm or 0.5) -- decay
            or param == 10 and (val_norm or 0.5) -- lpg_colour
            or val_norm

  local id = engine_macroP.param_ids[param]

  engine_macroP.param_display_value = ((param == 0 or param == 1) and synthesis_engines[num+1]) or nil

  if cls:neighbor(cls.x, cls.y, "*") and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[id].func(num)
    end
  end
end

return engine_macroP