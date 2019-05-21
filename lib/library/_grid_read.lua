grid_read = function ( self, x, y, frame, _grid )
  self.name = '<'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local v
  local col = self:listen( self.x - 2, self.y ) 
  local row = self:listen( self.x - 1, self.y )
  local mode = (row ~= false and col == false and 1 ) or (row == false and col ~= false and 2) or 0
  if mode == 0 then v = _grid.grid[row or 1][col or 1] end
  local value = (v ~= nil and v < 6 and 'null') or v == nil and 'null' or '*'
  print(mode, row, col)
  if self:active() then
    if mode == 0 then
      _grid[self.y + 1][self.x] = value
      end
    elseif mode == 1 then
    for i = 1, g.cols do 
        _grid.grid[row][i] = 15
      end
    elseif mode == 2 then
    for i = 1, g.rows do 
        _grid.grid[i][col] = 15
      end
    
  end
end

return grid_read