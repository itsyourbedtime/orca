local grid_write = function ( self, x, y, frame, _grid )
  
  self.y = y
  self.x = x
  
  self.name = 'g.write'
  self.info = 'Reads grid x / y.'
  
  self.ports = {{1, 0, 'input_op'}, {2, 0, 'input_op'}, {3, 0, 'input_op'}}
  self:spawn(self.ports)
  
  local col = util.clamp(self:listen( self.x + 1, self.y ) or 0 % self.g.cols, 0, self.g.cols)
  local row = util.clamp(self:listen( self.x + 2, self.y ) or 0 % self.g.rows, 0, self.g.rows)
  local val = util.clamp(self:listen( self.x + 3, self.y ) or 0 % 16, 0, 16)
  val = _grid[self.y][self.x + 3]  == '*' and 15 or val
  
  if self.banged( self.x, self.y ) then
    for y = 1, self.g.rows do 
      for x = 1, self.g.cols do
        _grid.grid[row == 0 and y or row][col == 0 and x or col] = val
      end
    end
  end
  
end

return grid_write