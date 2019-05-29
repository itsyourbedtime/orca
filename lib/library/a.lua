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
  
  local b = self:listen( self.x - 1, self.y) or 0
  local a = self:listen( self.x + 1, self.y) or 0
  local sum  = self.chars[ ( a + b )  % ( #self.chars + 1 ) ]
  sum = sum == '0' and '.' or sum
  
  if not self.passive then
    self:spawn(self.ports)
    self:write(self.ports[3][1], self.ports[3][2], sum)
  elseif self:banged() then
    self:spawn({{0, 1, self.glyph, 'output'}})
    self:write(self.ports[3][1], self.ports[3][2], sum)
  end
end


return A