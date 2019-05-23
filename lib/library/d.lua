local D = function ( self, x, y, frame, grid )
  self.name = 'D'
  self.y = y
  self.x = x
  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  if mod == 0 then 
    mod = 1 
  end
  if rate == 0 then 
    rate = 1 
  end
  local val = ( frame % ( mod * rate ))
  local out = ( val == 0 or mod == 1 ) and '*' or 'null'
  if self:active() then
    self:spawn(self.name)
    grid[self.y + 1][self.x] = out
  elseif self.banged( self.x , self.y ) then
    grid[self.y + 1][self.x] = out
  end
end

return D