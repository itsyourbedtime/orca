local A = function(self, x, y )
  self.y = y
  self.x = x
  self.name = "add"
  self.ports = { {-1, 0, "in-a" }, {1, 0, "in-b"}, {0, 1, "add-out"} }
  self:spawn(self.ports)

  local b = self:listen(self.x - 1, self.y) or 0
  local a = self:listen(self.x + 1, self.y) or 0
  local l = self:glyph_at(self.x + 1, self.y)
  local cap = l ~= "." and l == self.up(l) and true
  local sum  = self.chars[(a + b ) % 36]

  sum = sum == "0" and "." or (cap and self.up(sum) or sum)

  self:write(0, 1, sum)
end

return A