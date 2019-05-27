local U  = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'uclid'
  self.info = {'Bangs based on the Euclidean pattern', 'in-pulses', 'in-steps', 'uclid-out'}

  self.ports = {{-1, 0}, { 1, 0}, {0, 1}}

  local pulses = self:listen(self.x + 1, self.y) or 8
  local steps = self:listen(self.x - 1, self.y) or 1
  local pattern = self.euclid.gen(steps, pulses)
  local pos = (self.frame  % (pulses ~= 0 and pulses or 1) + 1)
  local out = pattern[pos] and '*' or 'null'
  
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = out
  elseif self:banged() then
    self.data.cell[self.y + 1][self.x] = out
  end
end

return U