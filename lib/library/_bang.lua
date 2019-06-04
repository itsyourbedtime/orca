local bang = function( self, x, y )
  
  self.x = x 
  self.y = y 
  
  self.glyph = '*'
  self.passive = false
  self.name = 'bang'
  self.ports = {}
  
  self:erase(self.x, self.y)  

end

return bang