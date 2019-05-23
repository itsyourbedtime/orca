local B = function ( self, x, y, frame, grid )
  self.name = 'B'
  self.y = y
  self.x = x
  local to = self:listen( self.x + 1, self.y ) or 1
  local rate = self:listen( self.x - 1, self.y ) or 1
  if to == 0 or to == nil then 
    to = 1 
  end
  if rate == 0 or rate == nil then 
    rate = 1 
  end
  local key = math.floor( frame / rate ) % ( to * 2 )
  local val = key <= to and key or to - ( key - to )
  if self:active() then
    self:spawn(self.name)
    grid[self.y + 1][self.x] = self.chars[val]
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = self.chars[val]
  end
end

return B