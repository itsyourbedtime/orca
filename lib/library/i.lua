local I = function (self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'increment'
  self.info = 'Increments southward operator.'
  
  self.ports = {
    {-1, 0 , 'in-a', 'haste'}, 
    {1, 0, 'in-b', 'input'}, 
    {0, 1, 'i-out', 'output'}
  }

  local a = self:listen(self.x - 1, self.y) or 0
  local b = self:listen(self.x + 1, self.y) or 9
  b = b ~= a and b or a + 1 if b < a then a,b = b,a end
  val = util.clamp(( self.frame  % (b + 1)), a, b )
  
  if not self.passive then
    self:spawn(self.ports)
    self:write(self.ports[3][1], self.ports[3][2], self.chars[val])
  elseif self:banged(  ) then
    self:write(self.ports[3][1], self.ports[3][2], self.chars[val])
  end
  
end

return I