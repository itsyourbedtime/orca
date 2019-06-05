local R = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'random'
  self.ports = { {-1, 0, 'in-a', 'haste'}, { 1, 0, 'in-b', 'input'}, {0, 1, 'r-output', 'output'} }
  
  local a = self:listen(self.x - 1, self.y) or 0
  local b = self:listen(self.x + 1, self.y) or 35
  local l = self:glyph_at(self.x + 1, self.y)
  local cap = l ~= '.' and l == self.up(l) and true
  if b < a then a,b = b,a end
  local val = self.chars[math.random(a, b)]
  local value = cap and self.up(val) or val

  self:spawn(self.ports)
  self:write(0, 1, value)
  
end

return R