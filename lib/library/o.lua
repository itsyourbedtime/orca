local O = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'offset'
  self.info = 'Reads a distant operator with offset.'
  self.ports = { {-1, 0, 'in-x', 'haste'}, {-2, 0, 'in-y', 'haste'}, {1, 0, 'o-read', 'haste'}, {0, 1, 'o-output', 'output'} }
  
  local a = util.clamp(self:listen(self.x - 2, self.y) or 1, 1, 35)
  local b = self:listen(self.x - 1, self.y) or 0
  local offset_x = a + self.x
  local offset_y = b + self.y
  
  self.ports[3][1] = a
  self.ports[3][2] = b
  
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(self.ports[4][1], self.ports[4][2], self:glyph_at(offset_x, offset_y))
  end
  
end

return O