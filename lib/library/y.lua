Y = function(self, x, y, frame, grid)
  self.name = 'Y'
  self.y = y
  self.x = x
  local a = grid[y][x - 1]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y][self.x + 1] = a
  elseif self.banged( self.x, self.y ) then
    grid[self.y][self.x + 1] = a
  end
end

return Y