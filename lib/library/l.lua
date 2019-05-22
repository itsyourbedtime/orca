local L = function (self, x, y, frame, grid)
  self.name = 'L'
  self.y = y
  self.x = x
  local length = self:listen( self.x - 1, self.y, 0 ) or 0
  local rate = util.clamp(self:listen( self.x - 2, self.y, 0 ) or 1, 1, #self.chars)
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local l_start = util.clamp( self.x + offset, 1, self.XSIZE)
  local l_end = util.clamp( self.x + length, 1, self.YSIZE)
  if self:active() then
    self:spawn(self.ports[self.name])
    if frame % rate == 0 and length ~= 0 then
      self:shift(offset, length)
    end
    for i = 1, #self.chars do
      local is_op = self.is_op(self.x + i, self.y)
      if i <= length then
        grid.params[self.y][self.x + i] = {lit = false, lit_out = false, lock = true, cursor = false, dot = true}
        grid.params[self.y + 1][self.x + i].lit_out = false
        if is_op and  grid.params[self.y][self.x + i].lock == true then 
          self:clean_ports(self.ports[string.upper(grid[self.y][self.x + i])], self.x + i, self.y) 
          break
        end
      else
        if grid[self.y][(self.x + i) + 2] == self.name then 
          break
        else
          grid.params[self.y][(self.x + i)].lock = false
          grid.params[self.y][(self.x + i)].dot = false
        end
      end
      if grid.params[self.y][(self.x + i)].lock == false then 
        self:add_to_queue(self.x + i, self.y) 
      end
    end
  elseif self.banged(self.x, self.y) then
  end
end

return L