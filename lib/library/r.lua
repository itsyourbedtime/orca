local R = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "random"
  self.ports = { {-1, 0, "in-min"}, { 1, 0, "in-max"}, {0, 1, "r-out"} }
  self:spawn(self.ports)

  local min = self:listen(self.x - 1, self.y) or 0
  local max = self:listen(self.x + 1, self.y) or 35
  local l = self:glyph_at(self.x + 1, self.y)
  local cap = l ~= "." and l == self.up(l) and true

  if max < min then min, max = max, min end

  local val = self.chars[math.random(min, max)]
  local value = cap and self.up(val) or val

  self:write(0, 1, value)
end

return R