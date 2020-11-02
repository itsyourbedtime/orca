local W = function(self, x, y)
  self.x = x
  self.y = y
  self.name = "west"
  self:move(-1, 0)
end

return W