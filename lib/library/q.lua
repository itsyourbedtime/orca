local Q = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'query'
  self.ports = { {-3, 0, 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'} }

  local b = self:listen(self.x - 3, self.y) or 0
  local a = self:listen(self.x - 2, self.y) or 1
  local length = self:listen(self.x - 1, self.y, 0) or 1
  a = a == 0 and 1 or a

  for i = 1, length do local val = self:glyph_at((a + self.x + i) - 1, b + self.y) 
    self.ports[#self.ports + 1] = { (b + i) , a - 1 , 'in-q',  'input' }
    self:write( i - length, 1, val) 
  end
  
  self:spawn(self.ports)
    
end


return Q