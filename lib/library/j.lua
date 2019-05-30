local J = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'jumper'
  self.name = 'Outputs the northward operator.'
  self.ports = { {0, -1, 'j-input', 'haste'}, {0, 1, 'j-output', 'output'} }
  
  local input = self:glyph_at(self.x, self.y - 1)
  
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(0, 1, input)
  end
  
end

return J