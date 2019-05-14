C = function ( self, x, y, frame, grid )
  self.name = 'C'
  self.y = y
  self.x = x
  local mod = self:listen( x + 1, y ) or 9
  local rate = self:listen( x - 1, y ) or 1
  if mod == 0 then 
    mod = 1 
  end
  if rate == 0 then 
    rate = 1 
  end
  local val = ( math.floor( frame / rate ) % mod ) + 1
  if self:active() then
    self:spawn( self.ports[self.name] )
    grid[y + 1][x] = self.chars[val]
  elseif not self:active() then
    if self.banged( x, y ) then
      self:spawn( self.ports[self.name] )
      grid[y + 1][x] = self.chars[val]
    end
  end
end

return C