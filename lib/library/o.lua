local O = function(self, x, y )

  self.y = y
  self.x = x
  self.name = 'offset'
  self.ports = { {-1, 0, 'in-x' }, {-2, 0, 'in-y' }, {1, 0, 'o-read' }, {0, 1, 'o-output' } }
  
  local a = util.clamp(self:listen(self.x - 2, self.y) or 1, 1, 35)
  local b = self:listen(self.x - 1, self.y) or 0
  local offset_x = a + self.x
  local offset_y = b + self.y
  
  self.ports[3][1] = a
  self.ports[3][2] = b
  
  self:spawn(self.ports)
  self:write(self.ports[4][1], self.ports[4][2], self:glyph_at(offset_x, offset_y))

end

return O