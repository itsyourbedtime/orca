local X = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'write'
  self.info = 'Writes a distant operator with offset'
  
  self.ports = {
    input = {-1, 0, 'in-x'}, {-2, 0, 'in-y'}, 
    haste = {1, 0, 'x-val'}
  }

  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  local input = self.data.cell[self.y][self.x + 1]

  if not self.passive then
    self:spawn(self.ports)
    
    if input == 'null' then self:erase(offsetx, offsety)  end
    self.data.cell.params[self.y][self.x].spawned.offsets = {offsetx, offsety}
    self.write(offsetx, offsety, input)
    
  elseif self:banged() then
    self.data.cell.params[self.y][self.x].spawned.offsets = {offsetx, offsety}
    self.data.cell[offsety][offsetx] = input
    self.unlock( offsetx, offsety, false )
  end
  
end

return X