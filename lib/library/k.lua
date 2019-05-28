local K = function (self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'konkat'
  self.info = 'Otputs multiple variables.'
  
  self.ports = {
    {-1, 0, 'in-length', 'haste'}
  }
  

  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp(length, 0, self.XSIZE - self.bounds_x)
  local l_start = self.x + offset
  local l_end = self.x + length
  self.data.cell.params[self.y][self.x].spawned.seq = length

  if not self.passive then
    self.cleanup(self.x, self.y)
    for i = 1, length do
      self.ports[#self.ports + 1] = { i , 0, 'in-value',  pos == i and  'output' or 'input' }
      if self.inbounds((self.x  + i) , self.y) then
        local var = self:listen(x + i, y)
        if self.data.cell.vars[var] ~= nil then
          self.data.cell[self.y + 1][(self.x + i)] = self.data.cell.vars[var]
        end
      end
    end
    self:spawn(self.ports)
  end


end


return K