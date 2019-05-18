grid_read = function ( self, x, y, frame, grid )
  self.name = '<'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local row = util.clamp( self:listen( self.x - 2, self.y ) or 0, 0, 16 )
  local col = util.clamp( self:listen( self.x - 1, self.y ) or 0, 1, #self.chars )
  local val = nil 
  
  if self.banged( self.x, self.y ) then
    grid.params[self.y][self.x].lit_out = false

  else
    grid.params[self.y][self.x].lit_out = true
  end
end

return grid_read