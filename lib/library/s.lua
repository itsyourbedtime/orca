S = function(self, x, y, frame, grid)
  self.name = 'S'
  self.x = x
  self.y = y
  if self:active() then
    self:move(0,1)
  elseif self.banged( self.x, self.y ) then
    self:move(0,1)
  end
end

return S