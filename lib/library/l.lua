local L = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "lesser"
  self.ports = { {-1, 0, "in-a" }, {1, 0, "in-b"}, {0, 1, "less-out"} }
  self:spawn(self.ports)

  local b = self:listen(self.x - 1, self.y) or "."
  local a = self:listen(self.x + 1, self.y) or "."
  local val = "."

  if a ~= "." and b ~= "." then
    val = self.chars[math.min(a, b) % 36]
  end

  self:write(0, 1, val)
end

return L