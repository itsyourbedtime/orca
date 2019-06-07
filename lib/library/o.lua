local O = function(self, x, y )

  self.y = y
  self.x = x
  self.name = 'offset'
  self.ports = { {-1, 0, 'in-x' }, {-2, 0, 'in-y' }, {0, 1, 'o-output' } }
  
  local a = util.clamp(self:listen(self.x - 2, self.y) or 1, 1, 35)
  local b = self:listen(self.x - 1, self.y) or 0
  local offset_x = a + self.x
  local offset_y = b + self.y
  
  self:spawn(self.ports)
  self:lock(offset_x, offset_y, false, true, false, false)
  self:write(0, 1, self:glyph_at(offset_x, offset_y))

end

return O