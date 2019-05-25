local M  = function ( self, x, y, frame, grid )

  self.y = y
  self.x = x

  self.name = 'M'
  self.info = 'Outputs product of inputs.'

  self.ports = {{-1, 0, 'input'}, {1, 0, 'input'}, {0, 1 , 'output'}}
  self:spawn(self.ports)

  local l = self:listen( self.x - 1, self.y, 1 ) or 0
  local m = self:listen( self.x + 1, self.y, 1 ) or 0

  if self:active() then
    grid[self.y + 1][self.x] = self.chars[( l * m ) % #self.chars]
  elseif self.banged(self.x, self.y) then
    grid[self.y + 1][self.x] = self.chars[( l * m ) % #self.chars]
  end
  
end

return M