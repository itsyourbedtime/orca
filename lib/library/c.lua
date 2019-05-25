local C = function ( self, x, y, frame, grid )

  self.y = y
  self.x = x
  
  self.name = 'clock'
  self.info = 'Outputs a constant value based on the runtime frame.'
  
  self.ports = {{-1, 0, 'input'}, {1, 0, 'input_op'}, {0, 1, 'output'}}
  self:spawn(self.ports)

  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  mod = mod == 0 and 1 or mod
  rate = rate == 0 and 1 or rate
  local val = ( math.floor( frame / rate ) % mod ) + 1
	
	if self:active() then
    grid[self.y + 1][self.x] = self.chars[val]
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = self.chars[val]
  end
  
end

return C