local A = function ( self, x, y, frame, grid )
  self.name = 'A'
  self.y = y
  self.x = x
  local b = self:listen( self.x + 1, self.y, 0 ) or 0
  local a = self:listen( self.x - 1, self.y, 0 ) or 0
  local sum
  if ( a ~= 0 or b ~= 0 ) then 
    sum  = self.chars[ ( a + b )  % ( #self.chars + 1 ) ]
  else 
    sum = 0 
  end
  if self:active() then
    self:spawn( self.ports[self.name] )
      grid[self.y + 1][self.x] = sum
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = sum
  end
end

return A