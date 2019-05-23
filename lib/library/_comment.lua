local comment = function ( self, x, y, frame, grid )
  self.name = '#'
  self.x = x
  self.y = y
        local value = grid[y][x]
    for x = x + 1, self.XSIZE do
      self.lock(x, y, false, true)
      if grid[y][x] == self.name then
        for c = x + 1, self.XSIZE do
          if grid[y][c] == self.name then 
            break 
          else
            self.lock(c, y, false, false)
          end
        end
        break
      else
      end
    end
end

return comment
