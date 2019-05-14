R = function (self, x, y, frame, grid)
  self.name = 'R'
  self.y = y
  self.x = x
  local a, b
  a = self:input(x - 1, y, 1) 
  b = self:input(x + 1, y, 9)
  a = util.clamp(a or 1,0,#self.chars)
  b = util.clamp(b or 9,1,#self.chars)
  if b == 27 and a == 27 then 
    a = math.random(#self.chars) 
    b = math.random(#self.chars) 
  end
  if b < a then a,b = b,a end
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = self.chars[math.random((a or 1),(b or 9))]
  end
end

return R