J = function(self, x, y, frame, grid)
  self.name = 'J'
  self.y = y
  self.x = x
  local a = grid[y - 1][x]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y + 1][x] = a
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y + 1][x] = a
    end
  end
end

return J