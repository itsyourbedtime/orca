local grid_write = function ( self, x, y )
  
  self.y = y
  self.x = x
  
  self.glyph = '>'
  self.name = 'g.write'
  self.info = 'Writes grid x / y.'
  self.passive = false
  self.ports = { {1, 0, 'in-g.col', 'input'}, {2, 0, 'in-g.row', 'input'}, {3, 0, 'in-brightness', 'input'} }
  
  self:spawn(self.ports)
  
  local col = self:listen( self.x + 1, self.y ) or 0
  local row = self:listen( self.x + 2, self.y ) or 0 
  local val = self:listen( self.x + 3, self.y ) or 0 
  row, col, val = row % self.g.rows, col % self.g.cols, val % 16
  val = self.cell[self.y][self.x + 3]  == '*' and 15 or val
  
  if self:banged( ) then
    for y = 1, self.g.rows do 
      for x = 1, self.g.cols do
        self.grid[row == 0 and y or row][col == 0 and x or col] = val
      end
    end
  end
  
end

return grid_write