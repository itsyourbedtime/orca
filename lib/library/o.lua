local O = function(self, x, y, glyph)
  local a, b, offsetx, offsety
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'offset'
  self.info = 'Reads a distant operator with offset.'
  
  self.ports = {
    {-1, 0, 'in-x', 'haste'}, {-2, 0, 'in-y', 'haste'}, 
    {offsetx or 1, offsety or 0, 'o-read', 'haste'}, 
    {0, 1, 'o-output', 'output'}
  }
  

  a = self:listen(self.x - 2, self.y) or 1 
  b = self:listen(self.x - 1, self.y) or 0
  offsety = util.clamp(b + self.y, 1, self.YSIZE)
  offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  --self.clean_len_inputs(x, y)
  self.ports[3][1] = b
  self.ports[3][2] = a
  if not self.passive then
    self.cleanup(self.x, self.y)
    self:spawn(self.ports)

  end
  
end

return O