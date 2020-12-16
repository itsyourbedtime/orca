local Y = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "jymper"
  self.ports = { {-1, 0, "in-j"}, {1, 0, "j-out"} }
  self:spawn(self.ports)
  self:write(1, 0, self:glyph_at(self.x - 1, self.y))
end

return Y