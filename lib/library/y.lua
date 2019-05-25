local Y = function(self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'jymper'
  self.info = 'Outputs the westward operator'

  self.ports = {{-1, 0, 'input'}, {1, 0, 'output'}}
  self:spawn(self.ports)

  if self:active() then
    grid[self.y][self.x + 1] = grid[self.y][self.x - 1]
  elseif self.banged( self.x, self.y ) then
    grid[self.y][self.x + 1] = grid[self.y][self.x - 1]
  end

end

return Y