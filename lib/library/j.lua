local J = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "jumper"
  self.ports = { {0, -1, "j-input"}, {0, 1, "j-output"} }
  self:spawn(self.ports)
  self:write(0, 1, self:glyph_at(self.x, self.y - 1))
end

return J