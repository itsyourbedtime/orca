local Z = function (self, x, y, frame, grid)
  self.name = 'Z'
  self.x = x
  self.y = y
  local rate = self:listen(self.x - 1, self.y) or 1
  local target  = self:listen(self.x + 1, self.y) or 1
  rate = rate == 0 and 1 or rate
  local val = self:listen(x, y + 1) or 0
  local mod = val <= target - rate and rate or val >= target + rate and  -rate  or target - val
  out = self.chars[val + mod]
  if self:active() then
    self:spawn(self.name)
    grid[self.y + 1][self.x] = out
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = out
  end
end

return Z