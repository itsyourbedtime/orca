local B = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "subtract"
  self.ports = { {-1, 0, "in-a"}, {1, 0, "in-b"}, {0, 1, "subtract-out"} }
  self:spawn(self.ports)

  local b = self:listen(self.x - 1, self.y) or 0
  local a = self:listen(self.x + 1, self.y) or 0
  local l = self:glyph_at(self.x + 1, self.y)
  local cap = l ~= "." and l == self.up(l) and true
  local diff  = self.chars[math.abs(b - a) % 36]

  diff = diff == "0" and "." or (cap and self.up(diff) or diff)

  self:write(0, 1, diff)
end

return B