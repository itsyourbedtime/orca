I = function (self, x, y, frame, grid)
  self.name = 'I'
  self.y = y
  self.x = x
  local a, b
  a = self:listen(self.x - 1, self.y, 0) or 0
  b = self:listen(self.x + 1, self.y, 9)
  b = b ~= a and b or a + 1
  if b < a then 
    a,b = b,a 
  end
  val = util.clamp(( frame  % math.ceil(b)) + 1, a, b )
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y + 1][self.x] = self.chars[val]
  elseif self.banged( self.x, self.x ) then
    grid[self.y + 1][self.x] = self.chars[val]
  end
end

return I