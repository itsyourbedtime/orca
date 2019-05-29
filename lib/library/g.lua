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
  local offset = 1
  local offset_y = b + self.y 
  local offset_x = a + self.x - 1
    
    
  for i = 1, length do
    self.ports[#self.ports + 1] = { i , 0 , 'g-value ' .. i,  'input' }
    self.ports[#self.ports + 1] = { a + i - 1, b , 'g-value ' .. i, (not op and i == 1 ) and 'output' or 'haste' }
  end
    
    
  local function operate()
    for i = 1, length do
      self.data.cell[offset_y][(offset_x + i)] = self.data.cell[self.y][ (self.x + i)]
    end
  end
    

  if not self.passive then
    self:spawn(self.ports)
    operate()
  elseif self:banged() then
    operate()
  end
end


return G