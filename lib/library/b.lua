local B = function ( self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'bounce'
  self.ports = { {-1, 0, 'in-rate' }, {1, 0, 'in-to' },  {0, 1, 'b-out' } }
  self:spawn(self.ports)

  local to = self:listen( self.x + 1, self.y ) or 1
  local rate = self:listen( self.x - 1, self.y ) or 1
  to, rate = to == 0 and 1 or to, rate == 0 and 1 or rate
  local key = math.floor( self.frame / rate ) % ( to * 2 )
  local val = key <= to and key or to - ( key - to )
  
  self:write(0, 1, self.chars[val])
  
end

return B