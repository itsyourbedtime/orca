N = function(self, x, y, frame, grid)
  self.name = 'N'
  self.x = x
  self.y = y
  if self:active() then
    self:move(0,-1)
  elseif self.banged(x,y) then
    self:move(0,-1)
  end
end

return N