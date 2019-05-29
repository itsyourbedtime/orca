local X = function(self, x, y, glyph)
  local a, b, offsetx, offsety

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'write'
  self.info = 'Writes a distant operator with offset'
  
  self.ports = {
    {-1, 0, 'in-x', 'haste'}, {-2, 0, 'in-y', 'haste'}, 
    {1, 0, 'x-val', 'input'},
    {a or 0, b or 1, 'x-output', 'haste'}
  }

  a = self:listen(self.x - 2, self.y) or 0 -- x
  b = self:listen(self.x - 1, self.y) or 1 -- y
  offsety = util.clamp(b + self.y, 1, self.YSIZE)
  offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  local input = self:glyph_at(self.x + 1, self.y)


  if not self.passive then
    self:spawn(self.ports)
    self:write(a, b, input)

  elseif self:banged() then
    self:write(a, b, input)
  end
  
end

return X