-- TODO(frederickk): Implement Timber.
-- unrequire( "timber/lib/timber_engine" )
local Timber = include( "timber/lib/timber_engine" )
-- engine.name = "Timber"

local engine_timber = {
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
    "mod_env_release"
  },
  param_names = { 
    "attack",
    "decay",
    "sustain", 
    "release",
    "detune", 
    "stretch",
    "cutoff", 
    "resonance", 
    "type", 
    "quality",
    "1 freq mod", 
    "2 freq mod",
    "1 cutff.mod", 
    "2 cutff mod", 
    "1 pan mod", 
    "2 pan mod", 
    "1 amp mod", 
    "2 amp mod",
    "env f.mod",
    "c.env mod", 
    "c.mod vel", 
    "pressure", 
    "tracking",
    "pan e.mod",
    "attack e.mod", 
    "decay e.od", 
    "sust e.mod", 
    "rel e.mod"
  },
  ports = {
    "sample"
  }
}

-- Initializes engine and sets default values.
function engine_timber.init()
  
  print("Timber init()")
  
  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.options.PLAY_MODE_STREAMING_DEFAULT = 3

  params:add_separator("TIMBER")
  params:add_trigger( "load_t", "+ Load samples" )
  params:set_action( "load_t", function() 
    Timber.FileSelect.enter( _path.audio,  function( file )
      if file ~= "cancel" then
        orca_engine.load_folder( file, add ) 
      end 
    end ) 
  end )
  Timber.add_params()

  for i = 0, engine_timber.num_samples - 1 do
    --[[
    local extra_params = {
      {type = "option", id = "launch_mode_" .. i, name = "Launch Mode", options = {"Gate", "Toggle"}, default = 1, action = function( value )
        Timber.setup_params_dirty = true
      end},
    }
    params:add_separator()
    Timber.add_sample_params( i, true, extra_params )
    --params:set( "play_mode_" .. i, 4 )
    --params:set( "amp_env_sustain_" .. i, 0 )
    --]]  
  end
  
end

-- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_timber.run( octave, note, cls ) 

  local transposed = cls:transpose( note, octave )
  local hz = cls:note_freq( transposed[1] )

  local sample = cls:listen( cls.x + 3, cls.y ) or 0
  local level = cls:listen( cls.x + 4, cls.y ) or 28
  local start = cls:listen( cls.x + 5, cls.y ) or 0
  local n, oct, lev = transposed[1], transposed[4], ( ( level / 35 ) * 100 ) - 84
  local length = params:get( "end_frame_" .. sample )
  local start_pos = util.clamp( ( ( start / 35 ) * 2 ) * length, 0, length )
  
  if cls:neighbor( cls.x, cls.y, "*" ) and note ~= "." and note ~= "" then
    params:set( "start_frame_" .. sample, start_pos )
    params:set( "amp_" .. sample, lev )
    engine.noteOn( sample, cls:note_freq( n ), 1, sample )
  end

end

-- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_timber.param( cls )

  local sample = cls:listen( cls.x + 1, cls.y ) or 0
  local param = util.clamp( cls:listen( cls.x + 2, cls.y ) or 1, 1, #param_ids )
  local val = cls:listen( cls.x + 3, cls.y ) or 0
  local val_scaled = math.floor( ( val / 35 ) * 100 )
  local value = ( param == 1 or param == 2 or param == 3 or param == 4 ) and ( val / 35 ) * 5 -- attack / decay
               or param == 6 and val_scaled * 2 -- stretch
               or param == 7 and val_scaled * 200  -- filter freq
               or param == 8 and ( val / 35 )  -- res
               or param == 9 and ( val % 2 ) + 1
               or param == 10 and ( val % 4 ) + 1  
               or param > 10 and ( val / 35 ) -- other
               or val_scaled
              
  if cls:neighbor( cls.x, cls.y, "*" ) then
    params:set( param_ids[ param ] .. "_" .. sample, value )
  end

end

return engine_timber