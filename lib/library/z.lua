local Z = function (self, x, y, glyph)

  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'zoom'
  self.info = 'Transitions operand to input.'

  self.ports = {
    haste = {-1, 0 , 'in-rate' }, 
    input = {1, 0, 'in-target'}, 
    output = {0, 1, 'z-output'}
  }
  
  self.operation = function()
    local rate = self:listen(self.x - 1, self.y) or 1
    local target  = self:listen(self.x + 1, self.y) or 1
    rate = rate == 0 and 1 or rate
    local val = self:listen(x, y + 1) or 0
    local mod = val <= target - rate and rate or val >= target + rate and  -rate  or target - val
    
    return self.chars[val + mod]
  end
  
  if not self.passive then
    self:spawn(self.ports)
    self.write(self.x, self.y + 1, self.operation())
  else
    if self:banged() then
    self.write(self.x, self.y + 1, self.operation())
    end
  end

end

return Z