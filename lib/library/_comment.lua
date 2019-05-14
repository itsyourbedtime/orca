comment = function (self, x, y, frame, grid )
  self.name = '#'
  self.x = x
  self.y = y
  
  for i = self.x + 1, self.XSIZE do
    print(grid[self.y][i])
    if grid[self.y][i] == self.name then break 
    end
    grid.params[self.y][i].act = false
  end
end

return comment