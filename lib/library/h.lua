local H = function(self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'halt'
  self.ports = { {0, 1, 'h-output' } }
  self:spawn(self.ports)
  
end

return H