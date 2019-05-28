local Q = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'query'
  self.info = 'Reads distant operators with offset.'
  
  self.ports = {
    {-3, 0, 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'}, 
  }

  local a = self:listen(self.x - 3, self.y) or 1 
  local b = self:listen(self.x - 2, self.y) or 0
  local length = self:listen(self.x - 1, self.y, 0) or 1
  local y_port = b + self.y
  local x_port = a + self.x
  
  if not self.passive then
    self.cleanup(self.x, self.y)
    for i = 1, length do
      self.ports[#self.ports + 1] = { (b + i) , a - 1 , 'in-q',  'input' }
      if self.inbounds((self.x  + i) - length , self.y + 1) then
        self.cleanup((self.x  + i) - length , self.y + 1)
        self.data.cell[self.y + 1][(self.x  + i) - length] = self.data.cell[y_port][ (x_port + i) - 1]
      end
    end
    self:spawn(self.ports)
  end
end


return Q