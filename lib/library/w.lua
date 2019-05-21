local W = function(self, x, y, frame, grid)
  self.name = 'W'
  self.x = x
  self.y = y
  if self:active() then
    self:move( -1, 0 )
  elseif self.banged( self.x, self.y ) then
    self:move( -1, 0 )
  end
end

return W