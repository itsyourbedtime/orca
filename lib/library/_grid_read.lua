local grid_read = function ( self, x, y )
  
  self.y = y
  self.x = x
  
  self.glyph = '<'
  self.name = 'g.read'
  self.info = 'Reads grid on bang.'
  self.passive = false
  self.ports = { {-2, 0, 'in-g.col', 'haste'}, {-1, 0, 'in-g.row', 'haste'}, {0, 1, 'out-g.read', 'output'} }
  
  self:spawn(self.ports)
  
  local col = self:listen( self.x - 2, self.y )
  local row = self:listen( self.x - 1, self.y ) 
  local mode = (row  and not col and 1 ) or (col and not row and 2) or 0
  col = col == 0 and 1 or col row = row == 0 and 1 or row
  
  if mode == 0 then
    local v = self.grid[ row or 1 ][ col or 1 ]
    local value = v and v < 6 and '.' or '*'
    self.grid[ row or 1 ][ col or 1 ] = 5
    self:write(0, 1, value)
  else 
    for i= 1,( mode == 1 and 16 or 8 ) do
      local y, x = mode == 1 and row or i, mode == 1 and i or col
      if self.grid[y][x] ~= nil and self.grid[y][x] > 6 then 
        self:write( self.ports[3][1], self.ports[3][2], self.chars[i])
      break
    else
      self.grid[y][x] = 5
      end
    end
  end
end

  

return grid_read