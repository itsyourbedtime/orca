local arc_read = function ( self, x, y )
  self.y = y
  self.x = x
  self.name = "arc.read"
  self.ports = { {-1, 0, "in-arc.enc"}, {0, 1, "out-arc.read" } }
  self:spawn(self.ports)

  local selected = self:listen(self.x - 1, self.y)
  local out = self.arc_delta(selected)

  self:write(0, 1, self.chars[out])
end

return arc_read