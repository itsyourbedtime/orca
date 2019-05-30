local A = function ( self, x, y, glyph )
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'add'
  self.info = 'Outputs the sum of inputs.'
  self.ports = { {-1, 0, 'input-a', 'haste'}, {1, 0, 'input-b', 'input'}, {0, 1, 'add-output', 'output'} }
  
  local b = self:listen( self.x - 1, self.y) or 0
  local a = self:listen( self.x + 1, self.y) or 0
  local l = self:glyph_at(self.x + 1, self.y)
  local cap = l ~= '.' and l == self.up(l) and true
  local sum  = self.chars[ ( a + b )  % ( #self.chars + 1 ) ]
  sum = sum == '0' and '.' or (cap and self.up(sum) or sum)
  
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(0, 1, sum)
  end
end


return A