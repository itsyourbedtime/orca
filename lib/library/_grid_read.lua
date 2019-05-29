local grid_read = function ( self, x, y )
  
  self.y = y
  self.x = x
  
  self.glyph = '<'
  self.name = 'g.read'
  self.info = 'Reads grid on bang.'
  self.passive = false

  self.ports = {
    {-2, 0, 'in-g.col', 'haste'}, {-1, 0, 'in-g.row', 'haste'}, 
    {0, 1, 'out-g.read', 'output'}
  }
  
  self:spawn(self.ports)
  
  local GRID_ROWS = self.g.rows
  local GRID_COLS = self.g.cols
  local col = self:listen( self.x - 2, self.y )
  local row = self:listen( self.x - 1, self.y ) 
  local mode = (row ~= false and col == false and 1 ) or (row == false and col ~= false and 2) or 0
  local v = self.grid[not row and 1 or row][not col and 1 or col] 
  local value = v and v < 6 and '.' or '*'


  if mode == 0 then
    self.grid[ row or 1 ][ col or 1 ] = 5
    self.data.cell[self.y + 1][self.x] = value
  else 
    for i= 1,( mode == 1 and GRID_COLS or GRID_ROWS ) do
      local y, x = mode == 1 and row or i, mode == 1 and i or col
      if self.grid[y][x] ~= nil and self.grid[y][x] > 6 then 
        self.data.cell[self.y + 1][self.x] = self.chars[i]
      break
    else
      self.grid[y][x] = 5
      end
    end
  end
end

  

return grid_read