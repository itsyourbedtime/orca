local music = require "musicutil"

local engine_passersby = {
  input_ids = {
    "octave",
    "note",
    "velocity",
    "timbre",
    "pitchBend",
    "pressure"
  },
  param_ids = {
    "amp",
    "attack",
    "decay",
    "drift",
    "envType",
    "fm1Amount",
    "fm1Ratio",
    "fm2Amount",
    "fm2Ratio",
    "glide",
    "lfoFreq",
    "lfoShape",
    "lfoToAttackAmount",
    "lfoToDecayAmount",
    "lfoToFm1Amount",
    "lfoToFm2Amount",
    "lfoToFreqAmount",
    "lfoToPeakAmount",
    "lfoToReverbMixAmount",
    "lfoToWaveFoldsAmount",
    "lfoToWaveShapeAmount",
    "peak",
    "pitchBendAll",
    "pressureAll",
    "reverbMix",
    "timbreAll",
    "waveFolds",
    "waveShape"
  },
  param_names = {
    "Amp",
    "Attack",
    "Decay",
    "Drift",
    "Envelope Type",
    "FM Low Amount",
    "FM Low Ratio",
    "FM High Amount",
    "FM High Ratio",
    "Glide",
    "LFO Frequency",
    "LFO Shape",
    "LFO > Attack",
    "LFO > Decay",
    "LFO > FM Low",
    "LFO > FM High",
    "LFO > Frequency",
    "LFO > Peak",
    "LFO > Reverb Mix",
    "LFO > Wave Folds",
    "LFO > Wave Shape",
    "Peak",
    "Pitch Bend All",
    "Pressure All",
    "Reverb Mix",
    "Timbre All",
    "Wave Folds",
    "Wave Shape"
  },
  ports = {}
}

local prev_transposed

local function amp(num)
  return util.linlin(0, 1, 1, 11, num) or 1
end

local function attack(num)
  return util.linexp(0, 1, 0.003, 8, num) or  0.04
end

local function decay(num)
  return util.linexp(0, 1, 0.01, 8, num) or 1
end

local function env_type(index)
  index = index or 1
  local items = { "LPG", "Sustain" }
  return index % #items
end

local function fm_high_ratio(num)
  return util.linlin(0, 1, 0.1, 1, num) or 0.66
end

local function fm_low_ratio(num)
  return util.linlin(0, 1, 1, 10, num) or 3.3
end

local function glide(num)
  return util.linlin(0, 1, 1, 5, num) or 0
end

local function lfo_freq(num)
  return util.linexp(0, 1, 0.001, 10.0, num) or  0.5
end

local function lfo_type(index)
  index = index or 1
  local items = { "Triangle", "Ramp", "Square", "Random" }
  return index % #items
end

local function peak(num)
  return util.linexp(0, 1, 100, 10000, num) or 10000
end

local function pitch(num)
  return music.interval_to_ratio((util.round(num / 2)) / 8192 * 2 - 1)
end

local function unipolar(num)
  return util.linlin(0, 1, 0, 1, num) or 0
end

local function wave_folds(num)
  return util.linlin(0, 1, 0.0, 3.0, num) or 0
end


--- Initializes engine and sets default values.
function engine_passersby.init()
  print("Passersby init()")

  -- for id in engine_passersby.param_ids do
  --   engine.commands[id].func(0)
  -- end
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_passersby.run(octave, note, cls)
  local transposed = cls:transpose(note, octave)
  local hz = cls:note_freq(transposed[1])
  local vel = cls:listen(cls.x + 3, cls.y) or 100
  local timbre = (cls:listen(cls.x + 4, cls.y) or 0) / 35 or 0
  local pitch_st = pitch(cls:listen(cls.x + 5, cls.y) or 0)
  local pressure = (cls:listen(cls.x + 6, cls.y) or 0) / 35 or 0

  if cls:neighbor(cls.x, cls.y, "*") and note ~= "." and note ~= "" then
    engine.noteOn(transposed[1], hz, vel)
    engine.timbre(transposed[1], timbre)
    engine.pitchBend(transposed[1], pitch_st)
    engine.pressure(transposed[1], pressure)

    prev_transposed = transposed
  else
    if prev_transposed ~= nil then
      engine.noteOff(prev_transposed[1])
    end
  end
end

--- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_passersby.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_passersby.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local val_norm = (val / 35) or 0
  local num = (param == 0 or param == 1) and val_norm -- amp
            or param == 2 and attack(val_norm) -- attack
            or param == 3 and decay(val_norm)  -- decay
            or param == 4 and unipolar(val_norm)  -- drift
            or param == 5 and env_type(val) -- envType
            or param == 6 and unipolar(val_norm) -- fm1Amount
            or param == 7 and fm_low_ratio(val_norm) -- fm1Ratio
            or param == 8 and unipolar(val_norm) -- fm2Amount
            or param == 9 and fm_high_ratio(val_norm) -- fm2Ratio
            or param == 10 and glide(val_norm) -- glide
            or param == 11 and lfo_freq(val_norm) -- lfoFreq
            or param == 12 and lfo_type(index) -- lfoShape
            or param == 13 and unipolar(val_norm) -- lfoToAttackAmount
            or param == 14 and unipolar(val_norm) -- lfoToDecayAmount
            or param == 15 and unipolar(val_norm) -- lfoToFm1Amount
            or param == 16 and unipolar(val_norm) -- lfoToFm2Amount
            or param == 17 and unipolar(val_norm) -- lfoToFreqAmount
            or param == 18 and unipolar(val_norm) -- lfoToPeakAmount
            or param == 19 and unipolar(val_norm) -- lfoToReverbMixAmount
            or param == 20 and unipolar(val_norm) -- lfoToWaveFoldsAmount
            or param == 21 and unipolar(val_norm) -- lfoToWaveShapeAmount
            or param == 22 and peak(val_norm) -- peak
            or param == 23 and pitch(val_norm) -- pitchBendAll
            or param == 24 and val_norm -- pressureAll
            or param == 25 and unipolar(val_norm) -- reverbMix
            or param == 26 and val_norm -- timbreAll
            or param == 27 and wave_folds(val_norm) -- waveFolds
            or param == 28 and func(val_norm) -- waveShape
            or val_norm

  local id = engine_passersby.param_ids[param]

  if cls:neighbor(cls.x, cls.y, "*") and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[id].func(num)
    end
  end
end

return engine_passersby