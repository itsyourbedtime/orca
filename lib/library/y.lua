local Y = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'jymper'
  self.info = 'Outputs the westward operator'

  self.ports = { 
    {-1, 0, 'j-input', 'haste'}, 
    {1, 0, 'j-output', 'output'}
  }
  local input = self:glyph_at(self.x - 1, self.y)

  if not self.passive then
    self:spawn(self.ports)
    self:write(self.ports[2][1], self.ports[2][2], input)
  elseif self:banged() then
    self:spawn({{1, 0, self.glyph, 'output'}})
    self:write(self.ports[2][1], self.ports[2][2], input)
  end

end

return Y