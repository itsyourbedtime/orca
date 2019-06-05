local Y = function(self, x, y )

  self.y = y
  self.x = x
  self.name = 'jymper'
  self.ports = { {-1, 0, 'j-input', 'haste'}, {1, 0, 'j-output', 'output' } }
  
  local input = self:glyph_at(self.x - 1, self.y)
  
  self:spawn(self.ports)
  self:write(1, 0, input )

end

return Y