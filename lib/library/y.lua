local Y = function(self, x, y )

  self.y = y
  self.x = x
  self.name = 'jymper'
  self.ports = { {-1, 0, 'j-input' }, {1, 0, 'j-output' } }
  self:spawn(self.ports)

  local input = self:glyph_at(self.x - 1, self.y)
  
  self:write(1, 0, input )

end

return Y