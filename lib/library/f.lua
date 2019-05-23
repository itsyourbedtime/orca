local F = function( self, x, y, frame, grid )
  self.name = 'F'
  self.y = y
  self.x = x
  local b = self:listen( self.x + 1, self.y)
  local a = self:listen( self.x - 1, self.y)
  local val = a == b and '*' or 'null'
  if self:active() then
    self:spawn(self.name)
    grid[self.y + 1][self.x] = val
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = val
  end
end

return F