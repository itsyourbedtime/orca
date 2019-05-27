local Y = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'jymper'
  self.info = 'Outputs the westward operator'

  self.ports = { 
    input = {-1, 0, 'j-input'}, 
    output = {1, 0, 'j-output'}
  }

  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y][self.x + 1] = self.data.cell[self.y][self.x - 1]
  elseif self:banged() then
    self.data.cell[self.y][self.x + 1] = self.data.cell[self.y][self.x - 1]
  end

end

return Y