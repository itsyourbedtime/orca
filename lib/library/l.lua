L = function (self, x, y, frame, grid)
  self.name = 'L'
  self.y = y
  self.x = x
  local length = self:listen( self.x - 1, self.y, 0 ) or 0
  local rate = self:listen( self.x - 2, self.y, 0 ) or 1 
  rate = rate == 0 and 1 or rate
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - self.bounds_x )
  local l_start = util.clamp(self.x + offset, 1, self.XSIZE - self.bounds_x )
  local l_end = util.clamp(self.x + length, 1, self.XSIZE - self.bounds_x )
  if self:active() then
    self:spawn(self.ports[self.name])
    if length - offset  == 0 then
      for i= 2, length do
        grid.params[self.y][self.x + i].op = true
      end
    else
      for i = 1,length do
        grid.params[self.y][(self.x + i)].dot = true
        grid.params[self.y][(self.x + i)].lock = true
        grid.params[self.y + 1][(self.x + i)].lit_out = false
        grid.params[self.y][(self.x + i)].lit_out = false
        grid.params[self.y][(self.x + i)].lit = false
        if self.is_op(self.x + i, self.y) then 
          self:remove_from_queue(self.x + i, self.y) 
          self:clean_ports(orca.ports[string.upper(grid[self.y][self.x + i])], self.x + i, self.y) 
        end
      end
    end
  end
  if frame % rate == 0 and length ~= 0 then
    self:shift(offset, length)
  end
  -- cleanups
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
      grid.params[self.y][(self.x + i)].dot = false
      grid.params[self.y][(self.x + i)].lock = false
      if self.is_op(self.x + i, self.y) then self:add_to_queue(self.x + i, self.y) end
    end
  end
end

return L