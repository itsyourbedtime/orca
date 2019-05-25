local I = function (self, x, y, frame, grid)
  
  self.y = y
  self.x = x
  
  self.name = 'increment'
  self.info = 'Increments southward operator.'
  
  self.ports = {{-1, 0, 'input'}, {1, 0, 'input_op'}, {0, 1 , 'output'}}
  self:spawn(self.ports)
  
  local a = self:listen(self.x - 1, self.y, 0) or 0
  local b = self:listen(self.x + 1, self.y, 9)
  
  b = b ~= a and b or a + 1
  if b < a then 
    a,b = b,a 
  end
  
  val = util.clamp(( frame  % (b + 1)), a, b )
  
  if self:active() then
    grid[self.y + 1][self.x] = self.chars[val]
  elseif self.banged( self.x, self.x ) then
    grid[self.y + 1][self.x] = self.chars[val]
  end
  
end

return I