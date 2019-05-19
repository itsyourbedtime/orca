Y = function(self, x, y, frame, grid)
  self.name = 'Y'
  self.y = y
  self.x = x
  local a = grid[self.y][self.x - 1]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y][self.x + 1] = a
    self:add_to_queue(self.y, self.x + 1)
  elseif self.banged( self.x, self.y ) then
    grid[self.y][self.x + 1] = a
    self:add_to_queue(self.y, self.x + 1)
  end
end

return Y