local grid_write = function ( self, x, y )
  
  self.y = y
  self.x = x
  
  self.glyph = '>'
  self.name = 'g.write'
  self.info = 'Writes grid x / y.'
  self.passive = false

  self.ports = { 
    input = {1, 0, 'in-g.col'}, {2, 0, 'in-g.row'}, {3, 0, 'in-brightness'}
  }
  
  self:spawn(self.ports)
  
  local col = util.clamp(self:listen( self.x + 1, self.y ) or 0 % self.g.cols, 0, self.g.cols)
  local row = util.clamp(self:listen( self.x + 2, self.y ) or 0 % self.g.rows, 0, self.g.rows)
  local val = util.clamp(self:listen( self.x + 3, self.y ) or 0 % 16, 0, 16)
  val = self.data.cell[self.y][self.x + 3]  == '*' and 15 or val
  
  if self:banged( ) then
    for y = 1, self.g.rows do 
      for x = 1, self.g.cols do
        self.data.cell.grid[row == 0 and y or row][col == 0 and x or col] = val
      end
    end
  end
  
end

return grid_write