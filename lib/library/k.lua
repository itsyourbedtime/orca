local K = function (self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'konkat'
  self.ports = { {-1, 0, 'in-length' } }
  self:spawn(self.ports)

  local length = self:listen(self.x - 1, self.y) or 0
  for i = 1, length do
    local var = self.vars[self:listen(x + i, y) or '']
    self:lock(self.x + i, self.y, true, true )
    if var then
      self:lock(self.x + i, self.y + 1, true, true)
      self:write(i,1, var)
    end
  end
  
end


return K