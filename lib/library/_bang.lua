local bang = function( self, x, y )
  
  self.x = x 
  self.y = y 
  
  self.glyph = '*'
  self.passive = false
  self.name = 'bang'
  self.info = 'Bangs neighboring operators.'
  
  self.ports = {}
  
  if self:active() then 
    self:erase(self.x, self.y)  
  end
  
end

return bang