bang = function(self, x, y, frame, grid)
  self.x = x 
  self.y = y 
  if self:active() then 
    self:erase(self.x, self.y) 
  end
end

return bang