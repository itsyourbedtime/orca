local E = function(self, x, y)
  self.x = x
  self.y = y
  self.name = "east"
  self:move(1, 0)
end

return E