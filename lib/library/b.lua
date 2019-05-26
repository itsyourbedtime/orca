local B = function ( self, x, y, frame, grid )
  
  self.y = y
  self.x = x
  
  self.name = 'B'
  self.info = {'Bounces between two values based on the runtime frame.', 'in-rate', 'in-to', 'bounce-out'}

  self.ports = {{-1, 0, 'input'}, {1, 0, 'input_op'}, {0, 1, 'output'}}
  self:spawn(self.ports)
  
  local to = self:listen( self.x + 1, self.y ) or 1
  local rate = self:listen( self.x - 1, self.y ) or 1
  to = to == 0 and 1 or to
  rate = rate == 0 and 1 or rate
  local key = math.floor( frame / rate ) % ( to * 2 )
  local val = key <= to and key or to - ( key - to )
  
  if self:active() then
    grid[self.y + 1][self.x] = self.chars[val]
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = self.chars[val]
  end
  
end

return B