local M  = function ( self, x, y )

  self.y = y
  self.x = x
  self.name = 'multiply'
  self.ports = { {-1, 0 , 'in-a' }, {1, 0, 'in-b' }, {0, 1, 'm-output' } }
  self:spawn(self.ports)

  local l = self:listen( self.x - 1, self.y, 1 ) or 0
  local m = self:listen( self.x + 1, self.y, 1 ) or 0
  if m < l then l,m = m,l end

  self:write( self.ports[3][1], self.ports[3][2], self.chars[( l * m ) % 36])

end

return M