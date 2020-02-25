-- TODO(frederickk): Implement R, maybe...
local engine_r = {
  input_ids = {
    "octave",
    "note"
  },
  param_ids = {
    "octave",
    "note"
  },
  param_names = {}
  ports = {}
}


-- Initializes engine and sets default values.
function engine_r.init() 
  print("R init()")
end

-- Executes/plays the engine, "|" operator plays on bang.
-- @param octave {int}   octave index
-- @param note {string}  note letter
-- @param cls {class}    Orca class
function engine_r.run( octave, note, cls ) 

  local transposed = cls:transpose( note, octave )
  local hz = cls:note_freq( transposed[1] )

  if cls:neighbor( cls.x, cls.y, "*" ) and note ~= "." and note ~= "" then
  end

end

-- Executes the engines params, "-" operator updates on bang.
-- @param cls {class}    Orca class
function engine_r.param( cls )

  if cls:neighbor( cls.x, cls.y, "*" ) then
    if num == nil or unexpected_condition then
      print("Oops! Unexpected " .. engine.name .. " engine error.")
    else
      engine.commands[ id ].func( num )
    end
  end

end

return engine_r