R = function (self, x, y, frame, grid)
  self.name = 'R'
  self.y = y
  self.x = x
  local a, b
  a = self:listen(self.x - 1, self.y, 1) 
  b = self:listen(self.x + 1, self.y, 9)
  a = util.clamp(a or 1,0,#self.chars)
  b = util.clamp(b or 9,1,#self.chars)
  if b == 27 and a == 27 then 
    a = math.random(#self.chars) 
    b = math.random(#self.chars) 
  end
  if b < a then a,b = b,a end
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y + 1][self.x] = self.chars[math.random((a or 1),(b or 9))]
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = self.chars[math.random((a or 1),(b or 9))]
  end
end

return R