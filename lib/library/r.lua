local R = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'random'
  self.info = 'Outputs a random value.'

  self.ports = {
    {-1, 0, 'in-a', 'haste'}, 
    { 1, 0, 'in-b', 'input'}, 
    {0, 1, 'r-output', 'output'}
  }
  
  self.operation = function()
    local a = util.clamp(self:listen(self.x - 1, self.y) or 0, 0, #self.chars)
    local b = util.clamp(self:listen(self.x + 1, self.y) or #self.chars, 1, #self.chars)
    l = tostring(self.data.cell[self.y][self.x + 1])
    local cap = (l and l == self.up(l)) and true or false
    if b < a then a,b = b,a end
    local val = self.chars[math.random(a,b)]
    local value = cap and self.up(val) or val
    return value
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

return R