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
  local v
  local col = self:listen( self.x - 2, self.y ) 
  local row = self:listen( self.x - 1, self.y )
  local mode = (row ~= false and col == false and 1 ) or (row == false and col ~= false and 2) or 0
  if mode == 0 then v = self.data.grid[not row and 1 or row][not col and 1 or col] end
  local value = (v ~= nil and v < 6 and '.') or v == nil and '.' or '*'
  
  if self:banged( ) then
    if mode == 0 then
      if row ~= false and col ~= false then
        self.data.cell.grid[ row ][ col ] = 5
        self.data.cell[self.y + 1][self.x] = value
      end
    elseif mode == 1 then
    for i = 1, GRID_COLS do
      if self.data.cell.grid[row][i] ~= nil and self.data.cell.grid[row][i] > 6 then 
        self.data.cell[self.y + 1][self.x] = self.chars[i]
        break
      else
        self.data.cell.grid[row][i] = 5
        end
      end
    elseif mode == 2 then
      for i = 1, GRID_ROWS do 
        if self.data.cell.grid[i][col] ~= nil and self.data.cell.grid[i][col] > 6 then
          self.data.cell[self.y + 1][self.x] = self.chars[i]
          break
        else
          self.data.cell.grid[i][col] = 5
        end
      end
    end
  end
  
end

return grid_read