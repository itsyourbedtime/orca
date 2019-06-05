local G = function(self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'generator'
  self.ports = { {-3, 0 , 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'} }
  
  local a = util.clamp(self:listen(self.x - 2, self.y) or 1, 1, 35)
  local b = util.clamp(self:listen(self.x - 3, self.y) or 1, 1, 35)
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local op = self:listen(self.x + 1, self.y, 0)
  local offset_x, offset_y = b + self.x - 1, a + self.y 

  for i = 1, length do
    self.ports[#self.ports + 1] = { i , 0 , 'g-value ' .. i,  'input' }
    self.ports[#self.ports + 1] = { b + i - 1, a , 'g-value ' .. i, (not op and i == 1 ) and 'output' or 'haste' }
    local input = self:glyph_at(self.x + i, self.y)
    self:write( (b + i) - 1 , a, input)
  end

  self:spawn(self.ports)
  
end


return G