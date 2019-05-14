local euclid = require 'er'


U  = function (self, x, y, frame, grid)
  self.name = 'U'
  self.y = y
  self.x = x
  local pulses = self:input(x + 1, y) or 1
  local steps = self:input(x - 1, y) or 1
  local pattern = euclid.gen(steps, pulses)
  local pos = (frame  % (pulses ~= 0 and pulses or 1) + 1)
  local out = pattern[pos] and '*' or 'null'
  
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = out
  elseif not self:active() then
    if self.banged(x,y) then
      self:spawn(self.ports[self.name])
      grid[y+1][x] = out
    end
  end
end

return U