local Q = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "query"
  self.ports = { {-3, 0, "in-x"}, {-2, 0, "in-y"}, {-1, 0, "in-length"} }
  self:spawn(self.ports)

  local a = self:listen(self.x - 3, self.y) or 1
  local b = self:listen(self.x - 2, self.y) or 1
  local length = self:listen(self.x - 1, self.y, 0) or 1

  b = b == 0 and 1 or b
  a = a == 0 and 1 or a

  for offset = 1, length do
    local val = self:glyph_at((a + self.x + offset) - 1, (b + self.y) - 1)
    self:lock(self.x + (a + offset) - 1, (self.y + b) -1 , true, true)
    self:write(offset - length, 1, val)
  end
end

return Q