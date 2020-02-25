local fileselect = require "fileselect"

local fm7 = include( "lib/engines/_fm7" )
local passersby = include( "lib/engines/_passersby" )
local polyperc = include( "lib/engines/_polyperc" )
-- local r = include( "lib/engines/_r" )
-- local timber = include( "lib/engines/_timber" )

-- Softcut only supports max. 2 mono samples
local NUM_SAMPLES = 2 

-- Set FM7 as default engine
-- engine.name = "FM7"
engine.name = "Passersby"
-- engine.name = "PolyPerc"


local orca_engine = {
  engine_list = { "FM7", "Passersby", "PolyPerc" },
  -- TODO(frederickk): Add additional engines.
  -- engine_list = { "FM7", "Passersby", "PolyPerc", "R", "Timber" }
  change_init = false
}

function unrequire( name )
  package.loaded[name] = nil
  _G[name] = nil
end

function engine_loaded()
  print( engine.is_loading )
  orca_engine.change_init = false

  orca_engine.get_synth().init()
end

-- Loads selected engine. 
local load_engine = function( index )
  local name = orca_engine.engine_list[index]

  orca_engine.change_init = true

  if engine.is_loading then
    print( "'" .. name .. "'" .. " engine is already loading..." )
  else
    engine.load( name, engine_loaded )
    engine.name = name
  end
end

function orca_engine.load_folder( file, add )
  -- if add then
  --   for i = NUM_SAMPLES - 1, 0, -1 do
  --     if Timber.samples_meta[i].num_frames > 0 then
  --       sample_id = i + 1
  --       break
  --     end
  --   end
  -- end

  -- Timber.clear_samples( sample_id, NUM_SAMPLES - 1 )
  softcut.buffer_clear()

  local sample_id = 0
  local split_at = string.match( file, "^.*()/" )
  local folder = string.sub( file, 1, split_at )
  file = string.sub( file, split_at + 1 )

  local found = false
  for k, v in ipairs ( fileselect.list ) do
    if v == file then found = true end
    if found then
      if sample_id > ( NUM_SAMPLES - 1 ) then
        print( "Max files loaded" )
        break
      end
      -- Check file type
      local lower_v = v:lower()
      if string.find( lower_v, ".wav" ) or string.find( lower_v, ".aif" ) or string.find( lower_v, ".aiff" ) then
        print( "Loading samples", folder .. v, sample_id, audio.file_info( folder .. v ) )
        -- Timber.load_sample(sample_id, folder .. v )
        -- params:set( "play_mode_" .. sample_id, 4 )
        softcut.buffer_read_mono( folder .. v, 0, 1, -1, 1, sample_id )
        sample_id = sample_id + 1
      else
        print( "Skipped", v )
      end
    end
  end
end

function orca_engine.add_params()
  params:add_separator("ENGINE")
  params:add{
    type = "option",
    id = "engine_name",
    name = "Engine",
    options = orca_engine.engine_list,
    default = 2,
    action = load_engine
  }

  params:add_trigger( "load_f", "+ Load samples" )
  params:set_action( "load_f", function() 
    fileselect.enter( _path.audio, function( file )
      if file ~= "cancel" then
        orca_engine.load_folder( file, add )
      end
    end )
  end )
end

function orca_engine.get_synth()
  if string.lower( engine.name ) == "fm7" then return fm7
  elseif string.lower( engine.name ) == "passersby" then return passersby
  elseif string.lower( engine.name ) == "polyperc" then return polyperc
  -- elseif string.lower( engine.name ) == "r" then return r
  -- elseif string.lower( engine.name ) == "timber" return timber
  end
end

function orca_engine.init()
  -- softcut
  softcut.reset()
  audio.level_cut( 1 )
  audio.level_adc_cut( 1 )
  audio.level_eng_cut( 1 )

  for i = 1, 6 do
    softcut.level( i,1 )
    softcut.level_input_cut( 1, i, 1.0 )
    softcut.level_input_cut( 2, i, 1.0 )
    softcut.pan( i, 0.5 )
    softcut.play( i, 0 )
    softcut.rate( i, 1 )
    softcut.loop_start( i, 0 )
    softcut.loop_end( i, 36 )
    softcut.loop( i, 0 )
    softcut.rec( i, 0 )
    softcut.fade_time( i, 0.02 )
    softcut.level_slew_time( i, 0.01 )
    softcut.rate_slew_time( i, 0.01 )
    softcut.rec_level( i, 1 )
    softcut.pre_level( i, 1 )
    softcut.position( i, 0 )
    softcut.buffer( i,1 )
    softcut.enable( i, 1 )
    softcut.filter_dry( i, 1 )
    softcut.filter_fc( i, 0 )
    softcut.filter_lp( i, 0 )
    softcut.filter_bp( i, 0 )
    softcut.filter_rq( i, 0 )
  end

end

return orca_engine