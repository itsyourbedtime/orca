local P = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'push'
  self.info = 'Writes an eastward operator with offset.'

  self.ports = {
    {-1, 0, 'in-length', 'haste'}, {-2, 0, 'in-position', 'haste'}, 
    {1, 0, 'in-value', 'input'}, 
  }
  
  local length = self:listen(self.x - 1, self.y, 1) or 1
  local pos = self:listen(self.x - 2, self.y, 0) or 1
  local val = self.data.cell[self.y][self.x + 1]
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  
  self.data.cell.params[self.y][self.x].spawned.seq = length
  self.data.cell.params[self.y][self.x].spawned.offsets = {0, 1}
  
  
   if not self.passive then
    self.cleanup(self.x, self.y)
    for i = 1, length do
      self.ports[#self.ports + 1] = { i - 1, 1, 'in-value',  pos == i and  'output' or 'input' }
      if self.inbounds((self.x  + i) , self.y) then
        self.cleanup((self.x  + i) , self.y)
      end
    end
    self:spawn(self.ports)
    self.data.cell[self.y + 1][(self.x + ((pos or 1)  % (length + 1))) - 1] = val or '.'
  end
end

  
  
return P