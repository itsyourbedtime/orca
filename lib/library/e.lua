local E = function( self, x, y, frame, grid )
  
  self.x = x
  self.y = y
  
  self.name = 'east'
  self.info = 'Moves eastward, or bangs.'
  
  self.ports = {}

  if self:active() then
    self:move(1, 0)
  elseif self.banged( self.x, self.y ) then
    self:move(1, 0)
  end
  
end

return E