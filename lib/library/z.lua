Z = function (self, x, y, frame, grid)
  self.name = 'Z'
  self.x = x
  self.y = y
  local rate = self:listen(x - 1, y) or 1
  local target  = self:listen(x + 1, y) or 1
  rate = rate == 0 and 1 or rate
  local val = self:listen(x, y + 1) or 0
  local mod = val <= target - rate and rate or val >= target + rate and  -rate  or target - val
  out = self.chars[val + mod]
  if self:active() then
    self:spawn(self.ports[self.name])
      grid[y + 1][x] = out
  end
end

return Z