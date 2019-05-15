N = function(self, x, y, frame, grid)
  self.name = 'N'
  self.x = x
  self.y = y
  if self:active() then
    self:move(0, -1)
  elseif self.banged(self.x, self.y) then
    self:move(0, -1)
  end
end

return N