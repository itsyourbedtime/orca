B = function (self, x,y, frame, grid)
  self.name = 'B'
  self.y = y
  self.x = x
  local to = self:input(x + 1, y) or 1
  local rate = self:input(x - 1, y) or 1
  if to == 0 or to == nil then to = 1 end
  if rate == 0 or rate == nil then rate = 1 end
  local key = math.floor(frame / rate) % (to * 2)
  local val = key <= to and key or to - (key - to)
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y + 1][x] = self.chars[val]
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y + 1][x] = self.chars[val]
    end
  end
end

return B