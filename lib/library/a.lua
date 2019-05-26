local A = function ( self, x, y, frame, grid )
  
  self.y = y
  self.x = x
  
  self.name = 'add'
  self.info = 'Outputs the sum of inputs.'
  
  self.ports = {{-1, 0, 'input'}, {1, 0, 'input_op'}, {0, 1, 'output_op'}}
  self:spawn( self.ports )
  
  local b = self:listen( self.x + 1, self.y, 0 ) or 0
  local a = self:listen( self.x - 1, self.y, 0 ) or 0
  local sum  = a ~= 0 or b ~= 0 and self.chars[ ( a + b )  % ( #self.chars + 1 ) ] or 0
  sum = 0 and 'null' or sum
  if self:active() then
    grid[self.y + 1][self.x] = sum 
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = sum
  end
  
end

return A