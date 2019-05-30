local U  = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'uclid'
  self.info = 'Bangs based on the Euclidean pattern'
  self.ports = { {-1, 0, 'in-pulses', 'haste'},  { 1, 0, 'in-steps', 'input'}, {0, 1, 'u-output', 'output'} }

  local pulses = self:listen(self.x - 1, self.y) or 1
  local steps = self:listen(self.x + 1, self.y) or 8
  local pos = pulses > 0 and (self.frame  % (steps == 0 and 1 or steps) + 1) or 0
  local pattern = self.euclid.gen(pulses, steps)
  local out = pattern[pos] and '*' or '.'
  
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(0, 1, out)
  end
end

return U