local F = function( self, x, y, glyph )

  self.y = y
  self.x = x

  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'if'
  self.info = 'Bangs if both inputs are equal.'

  self.ports = {
    {-1, 0, 'in-a', 'haste'}, 
    {1, 0, 'in-b', 'input'}, 
    {0, 1, 'f-output', 'output'}
  }
  


  local b = self:listen( self.x + 1, self.y)
  local a = self:listen( self.x - 1, self.y)
  local val = a == b and '*' or '.'
  val = a == false and b == false and '.' or val
  self.data.cell[self.y + 1][self.x] = val

  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = val
  elseif self:banged( ) then
    self.data.cell[self.y + 1][self.x] = val
  end
  
end

return F