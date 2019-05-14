D = function (self, x, y, frame, grid)
  self.name = 'D'
  self.y = y
  self.x = x
  local mod = self:input(x + 1, y) or 9
  local rate = self:input(x - 1, y) or 1
  if mod == 0 then mod = 1 end
  if rate == 0 then rate = 1 end
  local val = (frame % (mod * rate))
  local out = (val == 0 or mod == 1) and '*' or 'null'
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = out
  elseif not self:active() then
    if self.banged(x,y) then
      self:spawn(self.ports[self.name])
      grid[y+1][x] = out
    end
  end
end

return D