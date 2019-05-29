local G = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'generator'
  self.info = 'Writes distant operators with offset.'
  
  self.ports = {
   {-3, 0 , 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'}
  }
  
  local a = util.clamp(self:listen(self.x - 2, self.y) or 1, 1, 35)
  local b = util.clamp(self:listen(self.x - 3, self.y) or 1, 1, 35)
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local op = self:listen(self.x + 1, self.y, 0)
  local offset_x, offset_y = a + self.x - 1, b + self.y 

    
  for i = 1, length do
    self.ports[#self.ports + 1] = { i , 0 , 'g-value ' .. i,  'input' }
    self.ports[#self.ports + 1] = { a + i - 1, b , 'g-value ' .. i, (not op and i == 1 ) and 'output' or 'haste' }
  end
    
    
  local function operate()
    for i = 1, length do
      local input = self:glyph_at(self.x + i, self.y)
      self:write( (a + i) - 1 , b, input)
    end
  end
    

  if not self.passive then
    self.cleanup(self.x, self.y)
    self:spawn(self.ports)
    operate()
  elseif self:banged() then
    operate()
  end
end


return G