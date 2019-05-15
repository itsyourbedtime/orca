comment = function ( self, x, y, frame, grid )
  self.name = '#'
  self.x = x
  self.y = y
  --local l = nil
  for x = x + 1, self.XSIZE do
    grid.params[y][x].dot = true
    grid.params[y][x].act = false
    grid.params[y][x].op = false
    grid.params[y][x].lit = false
    if grid[y][x] == self.name then
      for c = x + 1, self.XSIZE do
        grid.params[y][c].dot = false
        grid.params[y][c].act = true
        grid.params[y][c].op = true
      end
      break
    else
    end
  end
end

return comment
