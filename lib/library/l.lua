local L = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'loop'
  self.ports = { {-1, 0, 'in-length' }, {-2, 0, 'in-rate' } }
  self:spawn(self.ports)

  local length = util.clamp(self:listen( self.x - 1, self.y, 0 ) or 0, 1, self.w - self.x)
  local rate = util.clamp(self:listen( self.x - 2, self.y, 0 ) or 1, 1, 35)
  local l_start, l_end = self.x + 1, self.x + length
  for i = 1, length do self:lock( self.x + i, self.y, true, true) end
  if (self.frame % rate == 0 and length ~= 0) then self:shift(1, length) end

end


return L

