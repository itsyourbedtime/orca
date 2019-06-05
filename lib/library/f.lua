local F = function( self, x, y )

  self.y = y
  self.x = x
  self.name = 'if'
  self.ports = { {-1, 0, 'in-a' }, {1, 0, 'in-b' }, {0, 1, 'f-output' } }
  self:spawn(self.ports)

  local b = self:listen( self.x + 1, self.y)
  local a = self:listen( self.x - 1, self.y)
  local val = a == b and '*' or '.'
  val = a == false and b == false and '.' or val

  self:write(0, 1, val)
  
end

return F