local M  = function ( self, x, y, glyph )

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'multiply'
  self.info = 'Outputs product of inputs.'
  self.ports = { {-1, 0 , 'in-a', 'haste'}, {1, 0, 'in-b', 'input'}, {0, 1, 'm-output', 'output'} }

  local l = self:listen( self.x - 1, self.y, 1 ) or 0
  local m = self:listen( self.x + 1, self.y, 1 ) or 0
  if m < l then l,m = m,l end

  self:spawn(self.ports)
  self:write( self.ports[3][1], self.ports[3][2], self.chars[( l * m ) % 36])

end

return M