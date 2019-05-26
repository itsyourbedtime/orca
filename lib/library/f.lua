local F = function( self, x, y, frame, grid )

  self.y = y
  self.x = x

  self.name = 'if'
  self.info = 'Bangs if both inputs are equal.'

  self.ports = {{-1, 0, 'input'}, {1, 0, 'input_op'}, {0, 1, 'output_op'}}
  self:spawn(self.ports)
  
  local b = self:listen( self.x + 1, self.y)
  local a = self:listen( self.x - 1, self.y)
  local val = a == b and '*' or 'null'
  val = a == false and b == false and 'null' or val

  if self:active() then
    grid[self.y + 1][self.x] = val
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = val
  end
  
end

return F