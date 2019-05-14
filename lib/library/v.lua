V = function (self,x,y,frame, grid)
  self.name = 'V'
  self.y = y
  self.x = x
  local a = self:listen(x - 1, y, 0) or 0
  local b = self:listen(x + 1, y, 0) or grid[self.y][self.x + 1]
  if self:active() then
    self:spawn(self.ports[self.name])
    if ((grid.vars[b] ~= nil and grid.vars[b] ~= 'null')  and a == 0) then
      if grid.vars[b] ~= nil then
       grid.params[y + 1][x].lit_out = true
       grid[y + 1][x] = grid.vars[b] 
      end 
    elseif self:active() and b ~= 0 and  a ~= 0  then
      grid.vars[a] = grid[y][x + 1]
    else 
      grid[self.y + 1][self.x] = 'null'
      grid.params[self.y + 1][self.x].lit_out = false
    end
  elseif not self:active() then
    if self.banged( self.x, self.y) then
    end
  end
end

return V