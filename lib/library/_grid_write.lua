local grid_write = function ( self, x, y, frame, _grid )
  self.name = '>'
  self.y = y
  self.x = x
  self:spawn(self.name)
  local GRID_ROWS = self.g.rows
  local GRID_COLS = self.g.cols
  local col = util.clamp(self:listen( self.x + 1, self.y ) or 0 % GRID_COLS, 0, GRID_COLS)
  local row = util.clamp(self:listen( self.x + 2, self.y ) or 0 % GRID_ROWS, 0, GRID_ROWS)
  local val = util.clamp(self:listen( self.x + 3, self.y ) or 0 % 16, 0, 16)
  val = _grid[self.y][self.x + 3]  == '*' and 15 or val
  if self.banged( self.x, self.y ) then
    for y = 1, GRID_ROWS do 
      for x = 1, GRID_COLS do
        _grid.grid[row == 0 and y or row][col == 0 and x or col] = val
      end
    end
  end
end

return grid_write