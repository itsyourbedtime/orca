local I = function (self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'increment'
  self.info = {'Increments southward operator.', 'in-a', 'in-b', 'inc-out'}
  
  self.ports = {
    haste = {-1, 0 , 'in-a' }, 
    input = {1, 0, 'in-b'}, 
    output = {0, 1, 'i-out'}
  }

  local a = self:listen(self.x - 1, self.y, 0) or 0
  local b = self:listen(self.x + 1, self.y, 9)
  
  b = b ~= a and b or a + 1
  if b < a then 
    a,b = b,a 
  end
  
  val = util.clamp(( self.frame  % (b + 1)), a, b )
  
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = self.chars[val]
  elseif self:banged(  ) then
    self.data.cell[self.y + 1][self.x] = self.chars[val]
  end
  
end

return I