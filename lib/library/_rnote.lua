local rnote = function ( self, x, y )
  
  self.y = y
  self.x = x

  self.glyph = '^'
  self.name = 'r.note'
  self.passive = false
  self.ports = { {-1, 0, 'in-rate', 'haste'}, {1, 0, 'in-scale', 'input'}, {0, 1, 'r.note-output', 'output'} }
  
  local mode = self:listen( self.x - 1, self.y )
  local scale = self:listen( self.x + 1, self.y ) or 47 scale = scale == 0 and 47 or scale
  local get_scale = self:get_scale(scale)
  local scale_name = get_scale[1]
  local note_array = get_scale[2]
  local out
  if mode then 
    if mode == 0 then
      out = self.notes[note_array[math.random(#note_array)]]
    else
      out = self.notes[note_array[math.floor(mode) % #note_array ]]
    end
  else 
    out = self.notes[note_array[math.random(#note_array)]]
  end
  
  self.ports[2][3] = scale_name
  self:spawn(self.ports)
  
  if not mode and self:neighbor(self.x, self.y, '*') then
    self:write(self.ports[3][1], self.ports[3][2], out)
  elseif mode then
    self:write(self.ports[3][1], self.ports[3][2], out)
  end
  
end

return rnote