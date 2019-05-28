local J = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'jumper'
  self.name = 'Outputs the northward operator.'

  self.ports = {
    {0, -1, 'j-input', 'haste'}, 
    {0, 1, 'j-output', 'output'}
  }
  

  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = self.data.cell[self.y - 1][self.x]
  elseif self:banged() then
    self.data.cell[self.y + 1][self.x] = self.data.cell[self.y - 1][self.x]
  end
  
end

return J