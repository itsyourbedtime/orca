local I = function (self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'increment'
  self.info = 'Increments southward operator.'
  self.ports = { {-1, 0 , 'in-a', 'haste'}, {1, 0, 'in-b', 'input'}, {0, 1, 'i-out', 'output'} }

  local a = self:listen(self.x - 1, self.y) or 0
  local b = self:listen(self.x + 1, self.y) or 9
  local l = self:glyph_at(self.x + 1, self.y)
  b = b ~= a and b or a + 1 if b < a then a,b = b,a end
  val = ( math.floor( self.frame ) % b ) + 1
  local cap = l ~= '.' and l == self.up(l) and true
  local value = cap and self.up(self.chars[val]) or self.chars[val]

  self:spawn(self.ports)
  self:write(0, 1, value)
  
end

return I