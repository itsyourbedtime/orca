local engine_modalE = {
  input_ids = {
    "octave",
    "note",
    "vel"
  },
  param_ids = {
    "strength",
    "contour",
    "bow_level",
    "blow_level",
    "strike_level",
    "flow",
    "mallet",
    "bow_timb",
    "blow_timb",
    "strike_timb",
    "geom",
    "bright",
    "damp",
    "pos",
    "space",
    "model",
    "mul",
    "add"
  },
  param_names = {
    "Strength",
    "Contour",
    "Bow Level",
    "Blow Level",
    "Strike Level",
    "Flow",
    "Mallet",
    "Bow Timb",
    "Blow Timb",
    "Strike Timb",
    "Geom",
    "Bright",
    "Damp",
    "Pos",
    "Space",
    "Model",
    "Mul",
    "Add"
  },
  param_display_value = nil,
  ports = {}
}

local prev_transposed

--- Initializes engine and sets default values.
function engine_modalE.init()
  print("modalE init()")

  -- for id in engine_modalE.param_ids do
  --   engine.commands[id].func(0)
  -- end
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_modalE.run(octave, note, cls)
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
function engine_modalE.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_modalE.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local val_norm = (val / 35) or 0
  local num = (param == 0 or param == 1) and (val_norm or 0.5) -- strength
    or param == 2 and (val_norm or 0.5) -- contour
    or param == 3 and (val_norm or 1) -- bow_level
    or param == 4 and (val_norm or 0) -- blow_level
    or param == 5 and (val_norm or 0) -- strike_level
    or param == 6 and (val_norm or 0.25) -- flow
    or param == 7 and (val_norm or 0.5) -- mallet
    or param == 8 and (val_norm or 0.4) -- bow_timb
    or param == 9 and (val_norm or 0.6) -- blow_timb
    or param == 10 and (val_norm or 0.5) -- strike_timb
    or param == 11 and (val_norm or 0.4) -- geom
    or param == 12 and (val_norm or 0.2) -- bright
    or param == 13 and (val_norm or 0.5) -- damp
    or param == 14 and (val_norm or 0) -- pos
    or param == 15 and (val_norm or 0.25) -- space
    or param == 16 and (val_norm or 0) -- model
    or param == 17 and (val_norm or 1.0) -- mul
    or param == 18 and (val_norm or 0) -- add
    or val_norm

  local id = engine_modalE.param_ids[param]

  if cls:neighbor(cls.x, cls.y, "*") and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[id].func(num)
    end
  end
end

return engine_modalE
