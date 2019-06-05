local F = function( self, x, y )

  self.y = y
  self.x = x
  self.name = 'if'
  self.ports = { {-1, 0, 'in-a', 'haste'}, {1, 0, 'in-b', 'input'}, {0, 1, 'f-output', 'output'} }
  
  local b = self:listen( self.x + 1, self.y)
  local a = self:listen( self.x - 1, self.y)
  local val = a == b and '*' or '.'
  val = a == false and b == false and '.' or val

  self:spawn(self.ports)
  self:write(0, 1, val)
  
end

return F