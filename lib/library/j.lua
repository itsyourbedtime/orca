local J = function(self, x, y, frame, grid)
  self.name = 'J'
  self.y = y
  self.x = x
  local a = grid[self.y - 1][self.x]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y + 1][self.x] = a
    self:add_to_queue(self.y + 1, self.x)
  elseif self.banged(self.x, self.y) then
    grid[self.y + 1][self.x] = a
    self:add_to_queue(self.y + 1, self.x)
  end
end

return J