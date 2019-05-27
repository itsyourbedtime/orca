local O = function(self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'offset'
  self.info = 'Reads a distant operator with offset.'
  
  self.ports = {
    haste = {-1, 0, 'in-x'}, {-2, 0, 'in-y'}, 
    input = {0, 1, 'o-read'}, 
    output = {1, 0, 'o-output'}
  }
  

  local a = self:listen(self.x - 2, self.y) or 1 
  local b = self:listen(self.x - 1, self.y) or 0
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  self.data.cell.params[self.y][self.x].spawned.seq = 1
  self.data.cell.params[self.y][self.x].spawned.offsets = {offsetx, offsety}
  
  if not self.passive then
    self:spawn(self.ports)
    self.lock(offsetx, offsety, false, false)
    
    self.data.cell.params[self.y][self.x].spawned.offsets = {offsetx, offsety}
    self.data.cell[self.y + 1][self.x] = self.data.cell[offsety][offsetx]
    
  end
  
end

return O