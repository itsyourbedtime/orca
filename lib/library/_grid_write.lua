grid_write = function ( self, x, y, frame, _grid )
  self.name = '>'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local col = util.clamp(self:listen( self.x + 1, self.y ) or 0 % g.cols, 0, g.cols)
  local row = util.clamp(self:listen( self.x + 2, self.y ) or 0 % g.rows, 0, g.rows)
  local val = util.clamp(self:listen( self.x + 3, self.y ) or 0 % 16, 0, 16)
  if self.banged( self.x, self.y ) then
    _grid.params[self.y][self.x].lit_out = false
    for y = 1, g.rows do 
      for x = 1, g.cols do
        if (col == 0 and row == 0) then
          _grid.grid[y][x] = val
        elseif (col == 0 and row ~= 0) then
          _grid.grid[row][x] = val
        elseif (col ~= 0 and row == 0) then 
          _grid.grid[y][col] = val
        else
          _grid.grid[row][col] = val
        end
      end
    end
  else
    _grid.params[self.y][self.x].lit_out = true
  end
end

return grid_write