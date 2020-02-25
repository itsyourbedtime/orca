local engine_polyperc = {
  input_ids = {
    "octave",
    "note"
  },
  param_ids = {
    "pw",
    "amp",
    "release",
    "cutoff",
    "gain",
    "pan"
  },
  param_names = {
    "pw",
    "amp",
    "release",
    "cutoff",
    "gain",
    "pan"
  }
}


-- Initializes engine and sets default values.
function engine_polyperc.init() 

  print("PolyPerc init()")

  engine.amp( 0.5 )
  engine.pw( 50 )
  engine.release( 1.2 )
  engine.cutoff( 800 )
  engine.gain( 1 )
  engine.pan( 0 )

end

-- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_polyperc.run( octave, note, cls ) 

  local transposed = cls:transpose( note, octave )
  local hz = cls:note_freq( transposed[1] )

  if cls:neighbor( cls.x, cls.y, "*" ) and note ~= "." and note ~= "" then
    engine.hz( hz )
  end

end

-- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_polyperc.param( cls )

  local param = util.clamp( cls:listen( cls.x + 1, cls.y ) or 1, 1, #engine_polyperc.param_ids )
  local val = cls:listen( cls.x + 2, cls.y ) or 1
  local val_norm = ( val / 35 )
  local num = ( param == 0 or param == 1 ) and val_norm -- pw
             or param == 2 and val_norm -- amp
             or param == 3 and util.clamp( val_norm * 3.2 or 1.2, 0.1, 3.2 )  -- release
             or param == 4 and util.clamp( val_norm * 5000 or 800, 50, 5000 )  -- cutoff
             or param == 5 and util.clamp( val_norm * 4, 0, 4 ) -- gain
             or param == 6 and util.linlin( 0, 1, -1, 1, val_norm ) -- pan
             or val_norm

  local id = engine_polyperc.param_ids[ param ]

  if cls:neighbor( cls.x, cls.y, "*" ) and param ~= "." and param ~= "" then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[ id ].func( num )
    end
  end

end

return engine_polyperc