local G = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'generator'
  self.info = {'Writes distant operators with offset.', 'in-y', 'in-x'}
  
  self.ports = {
   {-3, 0 , 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'}
  }
  
  
  local a = self:listen(self.x - 3, self.y) or 0 -- x
  local b = self:listen(self.x - 2, self.y) or 1 -- y
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local offsety = util.clamp( b + self.y, 1, self.YSIZE) 
  local offsetx = util.clamp( a + self.x, 1, self.XSIZE)
  

  if not self.passive then
    self.cleanup(self.x, self.y)
    for i = 1, length do
      self.ports[#self.ports + 1] = { (b + i)  - 1, a , 'g-output',  'input' }
      if self.inbounds(offsetx + i, offsety) then
        self.unspawn(offsetx + i , offsety)
        self.data.cell[offsety][offsetx + i] = self.data.cell[self.y][ (self.x + i)]
      end
    end
    self:spawn(self.ports)
  end
end


return G