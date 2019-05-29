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
  
  local length = self:listen(self.x - 1, self.y) or 0

  if not self.passive then
    for i = 1, length do
      self.ports[#self.ports + 1] = { i , 0, 'in-value',  pos == i and  'output' or 'input' }
      if self.inbounds((self.x  + i) , self.y) then
        local var = self:listen(x + i, y)
        if self.vars[var] ~= nil then
          self.data.cell[self.y + 1][(self.x + i)] = self.vars[var]
        end
      end
    end
    self:spawn(self.ports)
  end


end


return K