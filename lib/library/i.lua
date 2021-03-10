local I = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "increment"
  self.ports = { {-1, 0 , "in-step" }, {1, 0, "in-mod" }, {0, 1, "i-out"} }
  self:spawn(self.ports)

  local a = self:listen(self.x - 1, self.y) or 1
  local b = self:listen(self.x + 1, self.y) or 9
  local l = self:glyph_at(self.x + 1, self.y)

  b = b ~= a and b or a + 1 if b < a then a, b = b, a end
  val = (math.floor(a * self.frame) % b) + 1

  local cap = l ~= "." and l == self.up(l) and true
  local value = cap and self.up(self.chars[val]) or self.chars[val]

  self:write(0, 1, value)
end

return I