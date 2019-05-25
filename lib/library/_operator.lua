local operator = function( self, x, y, frame, grid )
  
  self.x = x 
  self.y = y 
  
  self.name = 'empty'
  self.info = '--'
  
  self.ports = {}
  
end

return operator