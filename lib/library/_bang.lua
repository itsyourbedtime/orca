local bang = function(self, x, y)
  self.x = x
  self.y = y
  self.name = "bang"
  self:replace(".")
end

return bang