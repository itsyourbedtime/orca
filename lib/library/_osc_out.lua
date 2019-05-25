local osc_out = function ( self, x, y, frame, grid )
  self.x = x
  self.y = y
  
  self.name = '='
  self.info = "Sends OSC message."
  
  self.ports = {}
  
end

return osc_out