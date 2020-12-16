local N = function(self, x, y)
  self.x = x
  self.y = y
  self.name = "north"
  self:move(0, -1)
end

return N