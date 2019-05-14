Y = function(self, x, y, frame, grid)
  self.name = 'Y'
  self.y = y
  self.x = x
  local a = grid[y][x - 1]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y][x + 1] = a
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y][x + 1] = a
    end
  end
end

return Y