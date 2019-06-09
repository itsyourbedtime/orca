local Y = function(self, x, y )

  self.y = y
  self.x = x
  self.name = 'jymper'
  self.ports = { {-1, 0, 'j-input' }, {1, 0, 'j-output' } }
  self:spawn(self.ports)
  self:write(1, 0, self:glyph_at(self.x - 1, self.y) )

end

return Y