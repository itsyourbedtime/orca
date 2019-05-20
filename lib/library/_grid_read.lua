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
    _grid[self.y + 1][self.x] = value
  end
end

return grid_read