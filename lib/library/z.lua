local Z = function (self, x, y )

  self.x = x
  self.y = y
  self.name = 'zoom'
  self.ports = { {-1, 0 , 'in-rate' , 'haste'},  {1, 0, 'in-target', 'input'},  {0, 1, 'z-output', 'output'} }
  
  local r = self:listen(self.x - 1, self.y) or 1
  local t  = self:listen(self.x + 1, self.y) or 0
  local val = self:listen(x, y + 1) or 0
  local mod = val <= t - r and r or val >= t + r and - r or t - val
  local out =  self.chars[val + mod]

  self:spawn(self.ports)
  self:write(0, 1, out )

end

return Z