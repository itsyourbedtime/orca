local euclid = require 'er'

local U  = function (self, x, y, frame, grid)
  self.name = 'U'
  self.y = y
  self.x = x
  local pulses = self:listen(self.x + 1, self.y) or 1
  local steps = self:listen(self.x - 1, self.y) or 9
  local pattern = euclid.gen(steps, pulses)
  local pos = (frame  % (pulses ~= 0 and pulses or 1) + 1)
  local out = pattern[pos] and '*' or 'null'
  
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y + 1][self.x] = out
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = out
  end
end

return U