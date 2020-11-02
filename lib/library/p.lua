local P = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "push"
  self.ports = { {-1, 0, "in-length"}, {-2, 0, "in-key"}, {1, 0, "in-value"} }
  self:spawn(self.ports)

  local length = self:listen(self.x - 1, self.y, 1) or 1
  local key = self:listen(self.x - 2, self.y, 0) or 1
  local val = self:glyph_at(self.x + 1, self.y)
  local pos = util.clamp((key or 1) % (length + 1), 1, 35)
  for i = 1, length do self:lock(self.x + i - 1, self.y + 1, true, true, false, pos == i and true) end

  self:write(pos - 1, 1,  val)
end

return P