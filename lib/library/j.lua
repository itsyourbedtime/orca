local J = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'jumper'
  self.ports = { {0, -1, 'j-input', 'haste'}, {0, 1, 'j-output', 'output'} }
  
  local input = self:glyph_at(self.x, self.y - 1)
  
  self:spawn(self.ports)
  self:write(0, 1, input)
  
  
end

return J