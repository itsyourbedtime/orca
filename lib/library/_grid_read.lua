grid_read = function ( self, x, y, frame, _grid )
  self.name = '<'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local col = util.clamp(self:listen( self.x - 2, self.y ) or 1 % g.cols, 1, g.cols)
  local row = util.clamp(self:listen( self.x - 1, self.y ) or 1 % g.rows, 1, g.rows)
  local v = _grid.grid[row][col]
  local value = (v ~= nil and v < 6 and 'null') or v == nil and 'null' or '*'
  if self:active() then
    if col ~= 0 and row ~=0 then
      _grid[self.y + 1][self.x] = value
    elseif row == 0 and col ~= 0 then
      for i = 1, g.rows do 
        _grid.grid[i][col] = 15
      end
    end
  end
end

return grid_read