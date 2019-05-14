I = function (self, x, y, frame, grid)
  self.name = 'I'
  self.y = y
  self.x = x
  local a, b
  a = self:listen(x - 1, y, 0) or 0
  b = self:listen(x + 1, y, 9)
  b = b ~= a and b or a + 1
  if b < a then 
    a,b = b,a 
  end
  val = util.clamp(( frame  % math.ceil(b)) + 1, a, b )
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = self.chars[val]
  end
end

return I