local H = function(self, x, y, frame, grid)
  self.name = 'H'
  self.y = y
  self.x = x
  if self:active() then
    self:spawn(self.name)
    self:clean_ports(self.x, self.y + 1) 
  elseif self.banged( self.x, self.y) then
    self.lock(self.x, self.y + 1, false,  true)
  else
    self.unlock(self.x, self.y + 1,  false)
    ---self:clean_ports(self.x, self.y)
  end
end

return H