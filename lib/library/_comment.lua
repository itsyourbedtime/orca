comment = function ( self, x, y, frame, grid )
  self.name = '#'
  self.x = x
  self.y = y
  
  for x = self.x + 1, self.XSIZE do
    grid.params[self.y][x].dot = false
    grid.params[self.y][x].act = true
    grid.params[self.y][x].op = true
    
    if grid[self.y][x] == self.name then
      local l = x
      for c = self.x + 1, l do
        grid.params[self.y][c].dot = true
        grid.params[self.y][c].act = false
        grid.params[self.y][c].op = false
        grid.params[self.y][c].lit = false
      end
      break
    end
  end
end

return comment
