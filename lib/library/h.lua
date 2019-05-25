local H = function(self, x, y, frame, grid)
  
  self.y = y
  self.x = x
  
  self.name = 'halt'
  self.info = 'Stops southward operator from operating.'

  self.ports = {{0, 1, 'output_op'}}
  self:spawn(self.ports)

  if self:active() then
    self.clean_ports(self.x, self.y + 1) 
  elseif self.banged( self.x, self.y) then
    self.lock(self.x, self.y + 1, false,  true)
  end
  
end

return H