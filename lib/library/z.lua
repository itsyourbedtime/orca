local Z = function (self, x, y, glyph)

  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'zoom'
  self.info = 'Transitions operand to input.'
  self.ports = { {-1, 0 , 'in-rate' , 'haste'},  {1, 0, 'in-target', 'input'},  {0, 1, 'z-output', 'output'} }
  
  local rate = self:listen(self.x - 1, self.y) or 1
  local target  = self:listen(self.x + 1, self.y) or 0
  
  local function operation(r, t)
    local val = self:listen(x, y + 1) or 0
    local mod = val <= t - r and r or val >= t + r and - r or t - val
    return self.chars[val + mod]
  end
  
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(0, 1, operation(rate, target) )
  end

end

return Z