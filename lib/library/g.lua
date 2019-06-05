local G = function(self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'generator'
  self.ports = { {-3, 0 , 'in-y' }, {-2, 0, 'in-x' }, {-1, 0, 'in-length' } }
  self:spawn(self.ports)

  local a = util.clamp(self:listen(self.x - 2, self.y) or 1, 1, 35)
  local b = util.clamp(self:listen(self.x - 3, self.y) or 1, 1, 35)
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local op = self:listen(self.x + 1, self.y, 0)
  local offset_x, offset_y = b + self.x, a + self.y 
  
  for i = 1, length do
    self:lock( self.x + i, self.y, true, true )
    self:lock( offset_x, offset_y, false, true, false, true)
    self:write( (b + i) - 1, a, self:glyph_at(self.x + i, self.y))
  end

end


return G