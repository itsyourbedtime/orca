local Y = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'jymper'
  self.info = 'Outputs the westward operator'
  self.ports = { {-1, 0, 'j-input', 'haste'}, {1, 0, 'j-output', 'output' } }
  
  local input = self:glyph_at(self.x - 1, self.y)

  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(1, 0, input )
  end

end

return Y