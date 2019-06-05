local grid_write = function ( self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'g.write'
  self.ports = { {1, 0, 'in-g.col', 'input'}, {2, 0, 'in-g.row', 'input'}, {3, 0, 'in-brightness', 'input'} }
  self:spawn(self.ports)
  
  local row = self:listen( self.x + 1, self.y ) or 0
  local col = self:listen( self.x + 2, self.y ) or 0 
  local val = self:listen( self.x + 3, self.y ) or 0 
  
  row, col, val = row % 9, col % 17, val % 16
  val = self:glyph_at(self.x + 3, self.y)  == '*' and 15 or val
  
  if self:neighbor(self.x, self.y, '*') then
    for y = 1, 8 do 
      for x = 1, 16 do
        self.grid[row == 0 and y or row][col == 0 and x or col] = val
      end
    end
  end
  
end

return grid_write