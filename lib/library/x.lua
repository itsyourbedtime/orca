local X = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'write'
  self.info = 'Writes a distant operator with offset'
  
  self.ports = {
    {-1, 0, 'in-x', 'haste'}, {-2, 0, 'in-y', 'haste'}, 
    {1, 0, 'x-val', 'input'},
    {0, 1, 'x-output', 'output'}
  }

  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  local input = self.data.cell[self.y][self.x + 1]

  if not self.passive then
    self.ports[4][1] = a
    self.ports[4][2] = b
    self.cleanup(self.x, self.y)
    self:spawn(self.ports)
    self.data.cell[offsety][offsetx] = input
    self.unlock(offsetx, offsety, false, false, false)

  elseif self:banged() then
    self.data.cell[offsety][offsetx] = input
    self.unlock( offsetx, offsety, false )
  end
  
end

return X