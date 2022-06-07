
local engine_macroB = {
  input_ids = {
    "octave",
    "note",
    "vel",
    -- "trig", -- needed?
    "timbre",
    "color"
  },
  param_ids = {
    "model",
    "resamp",
    "decim",
    "bits",
    "ws",
    "ampAtk",
    "ampDec",
    "ampSus",
    "ampRel"
  },
  param_names = {
    "Model",
    "Resamp",
    "Decim",
    "Bits",
    "WS",
    "Attack",
    "Decay",
    "Sustain",
    "Release"
  },
  ports = {}
}

local prev_transposed

local function model(index)
  index = index or 1
  local items = {"CSAW","/\\/|-_-_","/|/|-_-_","FOLD","_|_|_|_|_","-_-_SUB","/|/|SUB","SYN-_-_","SYN/|","/|/|x3","-_-_x3","/\\x3","SIx3","RING","/|/|/|/|","/|/|_|_|_","TOY*","ZLPF","ZPKF","ZBPF","ZHPF","VOSM","VOWL","VFOF","HARM","FM","FBFM","WTFM","PLUK","BOWD","BLOW","FLUTE","BELL","DRUM","KICK","CYMB","SNAR","WTBL","WMAP","WLIN","WTx4","NOIS","TWNQ","CLKN","CLOU","PRTC","QPSK","????"}
  -- TODO figure out best way to support > 36 options
  return index % #items
end

local function resamp(num)
  return util.linexp(0, 1, 0.01, 1, num) or  0.01
end

local function decim(num)
  if not num then
    num = 0
  end
  return util.clamp(num,0,32)
end

local function bits(num)
  if not num then
    num = 0
  end
  return util.clamp(num,0,7)
end

local function ws(num)
  return util.linexp(0, 1, 0.01, 1, num) or  0.01
end

local function attack(num)
  return util.linexp(0, 1, 0.01, 1, num) or  0.01
end

local function decay(num)
  return util.linexp(0, 1, 0.01, 1, num) or  0.01
end

local function sustain(num)
  return util.linexp(0, 1, 0.01, 1, num) or 1
end

local function release(num)
  return util.linexp(0, 1, 0.01, 1, num) or 1
end


--- Initializes engine and sets default values.
function engine_macroB.init()
  print("macroB init()")

  -- for id in engine_macroB.param_ids do
  --   engine.commands[id].func(0)
  -- end
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_macroB.run(octave, note, cls)
  local transposed = cls:transpose(note, octave)
  local vel = cls:listen(cls.x + 3, cls.y) or 100
  local timbre = (cls:listen(cls.x + 4, cls.y) or 0) / 35 or 0
  local color = (cls:listen(cls.x + 5, cls.y) or 0) / 35 or 0

  if cls:neighbor(cls.x, cls.y, "*") and note ~= "." and note ~= "" then
    engine.noteOn(transposed[1], vel)
    engine.timbre(timbre)
    engine.color(color)
    prev_transposed = transposed
  else
    if prev_transposed ~= nil then
      engine.noteOff(prev_transposed[1])
    end
  end
end

--- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_macroB.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_macroB.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local val_norm = (val / 35) or 0
  local num = (param == 0 or param == 1) and model(val) -- model
            or param == 2 and resamp(val_norm) -- resamp
            or param == 3 and decim(val)  -- decim
            or param == 4 and bits(val)  -- bits
            or param == 5 and ws(val) -- ws
            or param == 6 and attack(val_norm) -- ampAtk
            or param == 7 and decay(val_norm) -- ampDec
            or param == 8 and sustain(val_norm) -- ampSys
            or param == 9 and release(val_norm) -- ampRel
            or val_norm

  local id = engine_macroB.param_ids[param]

  if cls:neighbor(cls.x, cls.y, "*") and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[id].func(num)
    end
  end
end

return engine_macroB