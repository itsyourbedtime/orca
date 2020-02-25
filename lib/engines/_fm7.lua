local MAX_NUM_VOICES = 16

local engine_fm7 = {
  input_ids = {
    "octave",
    "note",
    "voice",
    "amp"
  },
  param_ids = {
    "hz",
    "phase",
    "amp",
    "carrier",
    "opAmpA",
    "opAmpD",
    "opAmpS",
    "opAmpR",
    "hz1_to_hz",
    "hz2_to_hz",
    "hz3_to_hz",
    "hz4_to_hz",
    "hz5_to_hz",
    "hz6_to_hz"
  },
  param_names = {
    "Osc Freq Mult",
    "Osc Phase",
    "Osc Amplitude",
    "Carrier Amplitude",
    "Osc Amp Env Attack",
    "Osc Amp Env Decay",
    "Osc Amp Env Sustain",
    "Osc Amp Env Release",
    "Osc1 Phase Mod Osc",
    "Osc2 Phase Mod Osc",
    "Osc3 Phase Mod Osc",
    "Osc4 Phase Mod Osc",
    "Osc5 Phase Mod Osc",
    "Osc6 Phase Mod Osc"
  },
  ports = {
    "num"
  }  
}

local prev_transposed

function hz( num )
  return util.linlin( 0, 1, 1, 32, num ) or 1
end

function phase( num )
  return util.linlin( 0, 1, 0, 2 * math.pi, num ) or 0
end

function amp( num )
  return util.linlin( 0, 1, 0, 1, num ) or 1
end 

function carrier( num )
  return util.linlin( 0, 1, 0, 1, num ) or 1
end

function attack_release( num )
  return util.linlin( 0, 1, 0.01, 10, num ) or 0.05
end

function decay( num )
  return util.linlin( 0, 1, 0, 2, num ) or 0.1
end

function sustain( num )
  return util.linlin( 0, 1, 0, 1, num ) or 1
end


-- Initializes engine and sets default values.
function engine_fm7.init()
  print("FM7 init()")
end

-- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_fm7.run( octave, note, cls ) 

  local transposed = cls:transpose( note, octave )
  local hz = cls:note_freq( transposed[1] )
  -- local amp = ( cls:listen( cls.x + 4, cls.y ) / 35 ) or 1

  -- inckude handling of on bang
  if cls:neighbor( cls.x, cls.y, "*" ) and note ~= "." and note ~= "" then
    if prev_transposed ~= nil then
      engine.stop( prev_transposed[1] )
    end
    -- engine.amp( amp )
    engine.start( transposed[1], hz )
    
    prev_transposed = transposed
  else
    if prev_transposed ~= nil then
      engine.stop( prev_transposed[1] )
    end
  end

end

-- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_fm7.param( cls )

  local param = util.clamp( cls:listen( cls.x + 1, cls.y ) or 1, 1, #engine_fm7.param_ids )
  local mod_num = util.clamp( cls:listen( cls.x + 3, cls.y ) or 1, 1, 6 ) or 1
  local val = cls:listen( cls.x + 3, cls.y ) or 1
  local val_norm = ( val / 35 )

  local name = engine_fm7.param_names[ param ]
  local id = engine_fm7.param_ids[ param ]
  
  if cls:neighbor( cls.x, cls.y, "*" ) then
    local num = -1

    if string.find( id, "hz" ) then
      num = hz( val_norm )
    elseif string.find( id, "phase" ) then
      num = phase( val_norm )
    elseif string.find( id, "amp" ) then
      num = amp( val_norm )
    elseif string.find( id, "_to_" ) then
      num = phase( val_norm )
    elseif string.find( id, "carrier" ) then
      num = carrier( val_norm )
    elseif string.find( id, "opAmpA" ) then
      num = attack_release( val_norm )
    elseif string.find( id, "opAmpD" ) then
      num = decay( val_norm )
    elseif string.find( id, "opAmpS" ) then
      num = sustain( val_norm )
    elseif string.find( id, "opAmpR" ) then
      num = attack_release( val_norm )
    end

    if cls:neighbor( cls.x, cls.y, "*" ) and param ~= "." and param ~= "" then
      if num == nil or unexpected_condition then
        print("Oops! Unexpected " .. engine.name .. " engine error.")
      else
        engine.commands[ id .. mod_num ].func( num )
      end
    end
  end

end

return engine_fm7