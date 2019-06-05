local Q = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'query'
  self.ports = { {-3, 0, 'in-y' }, {-2, 0, 'in-x' }, {-1, 0, 'in-length' } }
  self:spawn(self.ports)

  local b = self:listen(self.x - 3, self.y) or 0
  local a = self:listen(self.x - 2, self.y) or 1
  local length = self:listen(self.x - 1, self.y, 0) or 1
  a = a == 0 and 1 or a

  for i = 1, length do local val = self:glyph_at((a + self.x + i) - 1, b + self.y) 
    self:lock(self.x + (b + i), self.y, true, true  )
    self:write( i - length, 1, val) 
  end
  
    
end


return Q