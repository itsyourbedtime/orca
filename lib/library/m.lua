M  = function ( self, x, y, frame, grid )
  self.name = 'M'
  self.y = y
  self.x = x
  local l = self:listen( self.x - 1, self.y, 1 ) or 0
  local m = self:listen( self.x + 1, self.y, 1 ) or 0
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[self.y + 1][self.x] = self.chars[( l * m ) % #self.chars]
  elseif self.banged(self.x, self.y) then
    grid[self.y + 1][self.x] = self.chars[( l * m ) % #self.chars]
  end
end

return M