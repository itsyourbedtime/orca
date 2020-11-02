local T = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "track"
  self.ports = { {-1, 0, "in-length"}, {-2, 0, "in-position"},  {1, 0, "in-value"}, {0, 1, "t-out"} }
  self:spawn(self.ports)

  local length = self:listen(self.x - 1, self.y, 1) or 1
  local position = self:listen(self.x - 2, self.y) or 1
  local pos = util.clamp((position or 1) % (length + 1), 1, 35)
  local val = self:glyph_at(self.x + util.clamp(pos, 1, length), self.y)

  for i = 1, length do
    self:lock(self.x + i, self.y, true, true, false, pos == i and true)
  end

  self:write(0, 1, val)
end

return T