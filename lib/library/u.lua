local U  = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'uclid'
  self.info = 'Bangs based on the Euclidean pattern'

  self.ports = {
    haste = {-1, 0, 'in-pulses', 'haste'}, 
    input = { 1, 0, 'in-steps', 'input'},
    output = {0, 1, 'u-output', 'output'}
  }

  local pulses = self:listen(self.x + 1, self.y) or 8
  local steps = self:listen(self.x - 1, self.y) or 1
  local pattern = self.euclid.gen(steps, pulses)
  local pos = (self.frame  % (pulses ~= 0 and pulses or 1) + 1)
  local val = pattern[pos] and '*' or '.'
  
  if not self.passive then
    self:spawn(self.ports)
    self.write( self.x, self.y + 1, val)
  elseif self:banged() then
    self.write( self.x, self.y + 1, val)
  end
end

return U