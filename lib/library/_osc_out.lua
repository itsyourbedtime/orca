local osc_out = function ( self, x, y, frame, grid )
  self.x = x
  self.y = y
  
  self.glyph = '='
  self.name = 'osc'
  self.info = "Sends OSC message."
  self.passive = false

  self.ports = {{1,0, 'osc-path', 'input'}}

  if not self.passive then 
    
    self:spawn(self.ports)
  end
end

return osc_out