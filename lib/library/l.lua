local L = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'loop'
  self.info = 'Loops a number of eastward operators.'
    
  self.ports = { 
    {-1, 0, 'in-length', 'haste'}, {-2, 0, 'in-rate', 'haste'}
  }

  local length = util.clamp(self:listen( self.x - 1, self.y, 0 ) or 0, 1, self.XSIZE - self.x)
  local rate = util.clamp(self:listen( self.x - 2, self.y, 0 ) or 1, 1, #self.chars)
  local offset = 1
  local l_start = self.x + offset
  local l_end =  self.x + length

  if not self.passive then
    for i = 1, length do
      self.ports[#self.ports + 1] = { i , 0, 'in-value',  'input' }
    end
    self:spawn(self.ports)
  
    if (self.frame % rate == 0 and length ~= 0) then
      if self.inbounds(self.x + length + 1, self.y) then
        self:shift(offset, length)
      end
    end
  end

end


return L

