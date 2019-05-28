local A = function ( self, x, y, glyph )
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'add'
  self.info = 'Outputs the sum of inputs.'
  
  self.ports = { 
    {-1, 0, 'input-a', 'haste'},
    {1, 0, 'input-b', 'input'}, 
    {0, 1, 'add-output', 'output'} 
  }
  
  local b = self:listen( self.x + self.ports[1][1], self.y + self.ports[1][2]) or 0
  local a = self:listen( self.x + self.ports[2][1], self.y + self.ports[2][2]) or 0
  local sum  = self.chars[ ( a + b )  % ( #self.chars + 1 ) ]

  sum = sum == '0' and '.' or sum
  
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + self.ports[3][2]][self.x + self.ports[3][1]] = sum 
  elseif self:banged() then
    self.data.cell[self.y + self.ports[3][2]][self.x + self.ports[3][1]] = sum 
  end
end


return A