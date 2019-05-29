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
    {offsetx or 0, offsety or 1, 'x-output', 'haste'}
  }

  a = self:listen(self.x - 2, self.y) or 0 -- x
  b = self:listen(self.x - 1, self.y) or 1 -- y
  offsety = util.clamp(b + self.y, 1, self.YSIZE)
  offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  input = self.data.cell[self.y][self.x + 1]


  if not self.passive then
    self.ports[4][1] = a
    self.ports[4][2] = b
    self:spawn(self.ports)
    self.data.cell[offsety][offsetx] = input

  elseif self:banged() then
    self.data.cell[offsety][offsetx] = input
  end
  
end

return X