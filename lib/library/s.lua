S = function(self, x, y, frame, grid)
  self.name = 'S'
  self.x = x
  self.y = y
  if self:active() then
    self:move(0,1)
  elseif self.banged(x,y) then
    self:move(0,1)
  end
end

return S