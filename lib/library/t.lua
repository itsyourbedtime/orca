local T = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'track'
  self.info = 'Reads an eastward operator with offset'
  
  self.ports = { 
    {-1, 0, 'in-length', 'haste'}, {-2, 0, 'in-position', 'haste'}, 
    {1, 0, 'in-value', 'input'}, 
    {0, 1, 't-output', 'output'}
  }

  local length = self:listen(self.x - 1, self.y, 1) or 1
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)  
  local val = self.data.cell[self.y][self.x + util.clamp(pos, 1, length)]
  self.data.cell.params[self.y][self.x].seq = length

 
   if not self.passive then
    self.cleanup(self.x, self.y)
    for i = 1, length do
      self.ports[#self.ports + 1] = { i , 0, 'in-value',  pos == i and  'output' or 'input' }
      if self.inbounds((self.x  + i) , self.y) then
        self.unspawn((self.x  + i) , self.y)
      end
    end
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = val or '.'
  end
end

 
 
 
 
return T