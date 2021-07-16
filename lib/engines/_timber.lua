local timber_lib = include("timber/lib/timber_engine")

local engine_timber = {
  lib = timber_lib,
  num_samples = 36,
  input_ids = {
    "octave",
    "note",
    "sample",
    "level",
    "position"
  },
  param_ids = {
    "amp_env_attack",
    "amp_env_decay",
    "amp_env_sustain",
    "amp_env_release",
    "detune_cents",
    "by_percentage",
    "filter_freq",
    "filter_resonance",
    "filter_type",
    "quality",
    "freq_mod_lfo_1",
    "freq_mod_lfo_2",
    "filter_freq_mod_lfo_1",
    "filter_freq_mod_lfo_2",
    "pan_mod_lfo_1",
    "pan_mod_lfo_2",
    "amp_mod_lfo_1",
    "amp_mod_lfo_2",
    "freq_mod_env",
    "filter_freq_mod_env",
    "filter_freq_mod_vel",
    "filter_freq_mod_pressure",
    "filter_tracking",
    "pan_mod_env",
    "mod_env_attack",
    "mod_env_decay",
    "mod_env_sustain",
    "transpose",
    "by_length",
    "by_bars",
    "pan",
    "amp",
    "mod_env_release",
    "start_frame",
    "end_frame",
  },
  param_names = {
    "Amp env attack",
    "Amp env decay",
    "Amp env sustain",
    "Amp env release",
    "Detune cents",
    "Stretch: percentage",
    "Filter freq",
    "Filter resonance",
    "Filter type",
    "Quality",
    "Freq m. LFO 1",
    "Freq m. LFO 2",
    "Filter freq m. LFO 1",
    "Filter freq m. LFO 2",
    "Pan m. LFO 1",
    "Pan m. LFO 2",
    "Amp m. LFO 1",
    "Amp m. LFO 2",
    "Freq m. env",
    "Filter freq m. env",
    "Filter freq m. vel",
    "Filter freq m. pressure",
    "Filter tracking",
    "Pan m. env",
    "Env. attack",
    "Env. decay",
    "Env. sustain",
    "Transpose",
    "Stretch: length",
    "Stretch: bars",
    "Pan",
    "Amp",
    "Env release",
    "Start frame",
    "End frame",
  },
  ports = {
    "sample"
  }
}

--- Initializes engine and sets default values.
function engine_timber.init()
  print("Timber init()")

  timber_lib.options.PLAY_MODE_BUFFER_DEFAULT = 3
  timber_lib.options.PLAY_MODE_STREAMING_DEFAULT = 3
end

--- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_timber.run(octave, note, cls)
  local transposed = cls:transpose(note, octave)
  local hz = cls:note_freq(transposed[1])

  local sample = cls:listen(cls.x + 3, cls.y) or 0
  local level = cls:listen(cls.x + 4, cls.y) or 28
  local start = cls:listen(cls.x + 5, cls.y) or 0
  local n, oct, lev = transposed[1], transposed[4], util.linlin(0, 35, -48, 16, level)
  local length = params:get("end_frame_" .. sample)
  local start_pos = util.clamp((start / 35) * length, 0, length)

  if cls:neighbor(cls.x, cls.y, "*") and note ~= "." and note ~= "" then
    -- TODO(frederickk): Determine why file I/O occurs intermittently.
    -- TODO(frederickk): Determine why using "params:set" wasn't actually
    -- setting Timber params for level and position.
    cls:try_catch_(function()
        engine.amp(sample, lev)
        engine.startFrame(sample, start_pos)
      end,
      function(e)
        print("Timber warning:", e)
      end
    )
    engine.noteOn(sample, cls:note_freq(n), 1, sample)
  end
end

--- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_timber.param(cls)
  local param = util.clamp(cls:listen(cls.x + 1, cls.y) or 1, 1, #engine_timber.param_ids - 1)
  local val = cls:listen(cls.x + 2, cls.y) or 0
  local sample = cls:listen(cls.x + 3, cls.y) or 0

  local val_scaled = math.floor((val / 35) * 100)
  local value = (param == 1 or param == 2 or param == 3 or param == 4 or param == 33) and (val / 35) * 5 -- attack / decay
              or param == 6 and val_scaled * 2 -- stretch [percentage]
              or param == 7 and val_scaled * 200 -- filter freq
              or param == 8 and (val / 35) -- res
              or param == 9 and (val % 2) + 1 -- filter type
              or param == 10 and (val % 4) + 1 -- quality
              or param == 30 and (val % 13) + 1 -- stretch [bars]
              or param > 10 and (val / 35) -- other
              or val_scaled

  if cls:neighbor(cls.x, cls.y, "*") then
    -- TODO(frederickk): Determine why file I/O occurs intermittently.
    cls:try_catch_(function()
        params:set(engine_timber.param_ids[param] .. "_" .. sample, value)
      end,
      function(e)
        -- params:add_number(engine_timber.param_ids[param] .. "_" .. sample, value)
        print("Timber Param warning:", e)
      end
    )
  end
end

return engine_timber