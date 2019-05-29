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
        self.ports[#self.ports + 1] = { i , 0, 'in-var', 'input' }
        local var = self.vars[self:listen(x + i, y) or '']
        if var then
          self:write(i,1, var)
          self.ports[#self.ports + 1] = { i , 1, 'out-var', 'input' }
        end
      
    end
    self:spawn(self.ports)
  end


end


return K