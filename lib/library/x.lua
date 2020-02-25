local X = function(self, x, y)

  self.y = y
  self.x = x
  self.name = 'write'
  self.ports = { { -1, 0, 'in-x' }, { -2, 0, 'in-y' }, { 1, 0, 'x-val' } }
  self:spawn( self.ports )

  local a = self:listen( self.x - 2, self.y ) or 0
  local b = util.clamp( self:listen( self.x - 1, self.y ) or 1, 1, 35 )

  self:lock( self.x + a, self.y + b, false, true, false, true ) 
  self:write( a, b, self:glyph_at( self.x + 1, self.y ) )

end

return X