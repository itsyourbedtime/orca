local euclid = require 'er'

local U  = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'uclid'
  self.info = 'Bangs based on the Euclidean pattern'

  self.ports = {{-1, 0, 'input'}, { 1, 0, 'input_op'}, {0, 1 , 'output'}}
  self:spawn(self.ports)

  local pulses = self:listen(self.x + 1, self.y) or 8
  local steps = self:listen(self.x - 1, self.y) or 1
  local pattern = euclid.gen(steps, pulses)
  local pos = (frame  % (pulses ~= 0 and pulses or 1) + 1)
  local out = pattern[pos] and '*' or 'null'
  
  if self:active() then
    grid[self.y + 1][self.x] = out
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = out
  end
end

return U