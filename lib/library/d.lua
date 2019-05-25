local D = function ( self, x, y, frame, grid )
  
  self.y = y
  self.x = x
  
  self.name = 'delay'
  self.info = 'Bangs on a fraction of the runtime frame.'
  
  self.ports = {{-1, 0, 'input'}, {1, 0, 'input_op'}, {0, 1, 'output'}}
  self:spawn(self.ports)
  
  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  mod = mod == 0 and 1 or mod 
  rate = rate == 0 and 1 or rate 
  local val = ( frame % ( mod * rate ))
  local out = ( val == 0 or mod == 1 ) and '*' or 'null'
  
  if self:active() then
    grid[self.y + 1][self.x] = out
  elseif self.banged( self.x , self.y ) then
    grid[self.y + 1][self.x] = out
  end
  
end

return D