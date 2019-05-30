local rnote = function ( self, x, y )
  
  self.y = y
  self.x = x

  self.glyph = '^'
  self.name = 'r.note'
  self.info = 'Outputs random note within octave.'
  self.passive = false
  self.ports = { {-1, 0, 'in-rate', 'haste'}, {1, 0, 'in-scale', 'input'}, {0, 1, 'r.note-output', 'output'} }
  
  local mode = self:listen( self.x - 1, self.y )
  local scale = self:listen( self.x + 1, self.y ) or 47 scale = scale == 0 and 47 or scale
  local scale_name = self.music.SCALES[scale].name
  local note_array = self.music.generate_scale(1, scale_name, 1)
  local out = mode and self.notes[note_array[mode % #note_array]] or self.notes[note_array[math.random(#note_array)]]
  
  self.ports[2][3] = string.lower(scale_name)
  self:spawn(self.ports)
  
  if not mode and self:banged() then 
    self:write(self.ports[3][1], self.ports[3][2], out)
  elseif mode then
    self:write(self.ports[3][1], self.ports[3][2], out)
  end
  
end

return rnote