F = function(self, x, y, frame, grid)
  self.name = 'F'
  self.y = y
  self.x = x
  local b = self:input(x + 1, y)
  local a = self:input(x - 1, y)
  local val = a == b and '*' or 'null'
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = val
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y+1][x] = val
    end
  end
end

return F