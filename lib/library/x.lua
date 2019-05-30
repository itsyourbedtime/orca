local X = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'write'
  self.info = 'Writes a distant operator with offset'
  
  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local offset_y = util.clamp(b + self.y, 1, self.YSIZE)
  local offset_x = util.clamp(a + self.x, 1, self.XSIZE)
  local input = self:glyph_at(self.x + 1, self.y)
  
  self.ports = { {-1, 0, 'in-x', 'haste'}, {-2, 0, 'in-y', 'haste'}, {1, 0, 'x-val', 'input'},
    {a or 0, b or 1, 'x-output', self.op(self.x + 1, self.y) and 'haste' or 'output'} }

  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self.unlock(offset_x, offset_y, false, false, false, true)
    self:write(a, b, input)
  end
  
end

return X