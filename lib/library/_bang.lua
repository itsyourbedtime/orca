local bang = function( self, x, y, frame, grid )
  
  self.x = x 
  self.y = y 
  
  self.name = 'bang'
  self.info = 'Bangs neighboring operators.'
  
  self.ports = {}
  
  if self:active() then 
    self:replace('null')  
  end
  
end

return bang