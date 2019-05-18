grid_read = function ( self, x, y, frame, grid )
  self.name = '>'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local col = util.clamp(self:listen( self.x + 1, self.y ) or 0 % g.cols, 0, g.cols)
  local row = util.clamp(self:listen( self.x + 2, self.y ) or 0 % g.rows, 0, g.rows)
  local val = util.clamp(self:listen( self.x + 3, self.y ) or 0 % 16, 0, 16)
  if self.banged( self.x, self.y ) then
    grid.params[self.y][self.x].lit_out = false
    if col == 0 and row == 0 then 
      g:all(val)
    elseif col == 0 and row ~= 0 then
      for i = 1, g.cols do 
        g:led(i, row, val)
      end
    elseif col ~= 0 and row == 0 then
      for i = 1, g.rows do 
        g:led(col, i, val)
      end
    else
      g:led(col, row, val)
    end
    g:refresh()
  else
    grid.params[self.y][self.x].lit_out = true
  end
end

return grid_read