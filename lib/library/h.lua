local H = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'halt'
  self.info = 'Stops southward operator from operating.'
  self.ports = { {0, 1, 'h-output', 'output'} }

  if not self.passive or self:banged() then
    self:spawn(self.ports)
  end
  
end

return H