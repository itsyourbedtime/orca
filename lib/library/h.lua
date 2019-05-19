H = function(self, x, y, frame, grid)
  self.name = 'H'
  self.y = y
  self.x = x
  if self:active() then
    self:spawn(self.ports[self.name])
    if self.banged( self.x, self.y ) then
      self:clean_ports(self.ports[self.name])
    end
  elseif self.banged( self.x, self.y) then
    self:spawn(self.ports[self.name])
  else
    self:clean_ports(self.ports[self.name])
  end
end

return H