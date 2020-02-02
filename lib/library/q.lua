local Q = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'query'
  self.ports = { {-3, 0, 'in-y' }, {-2, 0, 'in-x' }, {-1, 0, 'in-length' } }
  self:spawn(self.ports)

  local b = self:listen(self.x - 3, self.y) or 1
  local a = self:listen(self.x - 2, self.y) or 1
  local length = self:listen(self.x - 1, self.y, 0) or 1
  a = a == 0 and 1 or a
  b = b == 0 and 1 or b

  for i = 1, length do local val = self:glyph_at((b + self.x + i) - 1, (a + self.y) - 1) 
    self:lock(self.x + (b + i) - 1, (self.y + a) -1 , true, true  )
    self:write( i - length, 1, val) 
  end
  
    
end


return Q