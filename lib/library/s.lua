local S = function(self, x, y, frame, grid)

  self.x = x
  self.y = y

  self.name = 'south'
  self.info = {'Moves southward, or bangs.'}

  self.ports = {}

  if self:active() then
    self:move(0,1)
  elseif self.banged( self.x, self.y ) then
    self:move(0,1)
  end
  
end

return S