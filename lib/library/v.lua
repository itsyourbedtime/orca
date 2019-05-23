local V = function (self,x,y,frame, grid)
  self.name = 'V'
  self.y = y
  self.x = x
  local a = self:listen(self.x - 1, self.y, 0) or 0
  local b = self:listen(self.x + 1, self.y, 0) or grid[self.y][self.x + 1]
  if self:active() then
    self:spawn(self.name)
    if ((grid.vars[b] ~= nil and grid.vars[b] ~= 'null')  and a == 0) then
      if grid.vars[b] ~= nil then
       grid.params[self.y + 1][self.x].lit_out = true
       grid[self.y + 1][self.x] = grid.vars[b] 
      end 
    elseif b ~= 'null' and  a ~= 0 then
      grid.vars[a] = grid[self.y][self.x + 1]
    elseif b == 'null' and a ~= 0 then 
      grid.vars[a] = 'null'
    else 
      grid[self.y + 1][self.x] = 'null'
      grid.params[self.y + 1][self.x].lit_out = false
    end
  elseif not self:active() then
    if self.banged( self.x, self.y) then
      if ((grid.vars[b] ~= nil and grid.vars[b] ~= 'null')  and a == 0) then
        if grid.vars[b] ~= nil then
         grid.params[self.y + 1][self.x].lit_out = true
         grid[self.y + 1][self.x] = grid.vars[b] 
        end 
      elseif self:active() and b ~= 0 and  a ~= 0  then
        grid.vars[a] = grid[self.y][self.x + 1]
      else 
        grid[self.y + 1][self.x] = 'null'
        grid.params[self.y + 1][self.x].lit_out = false
      end
    end
  else
  end
end

return V