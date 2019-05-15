J = function(self, x, y, frame, grid)
  self.name = 'J'
  self.y = y
  self.x = x
  local a = grid[self.y - 1][self.x]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y + 1][self.x] = a
  elseif self.banged(self.x, self.y) then
    grid[self.y + 1][self.x] = a
  end
end

return J