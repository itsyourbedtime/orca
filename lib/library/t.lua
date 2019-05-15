T = function (self, x, y, frame, grid)
  self.name = 'T'
  self.y = y
  self.x = x
  local length = self:listen(self.x - 1, self.y, 1) or 1
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)  
  local val = grid[self.y][self.x + util.clamp(pos,1,length)]
  if self:active() then
    grid.params[y+1][x].lit_out  = true
    self:spawn(self.ports[self.name])
    for i = 1,length do
      grid.params[self.y][(self.x + i)].dot = true
      grid.params[self.y][(self.x + i)].op = false
    end
    -- highliht pos
    
    for l= 1, length do
      if pos == l then
        grid.params[self.y][(self.x + l)].cursor = true
      else
        grid.params[self.y][(self.x + l)].cursor = false
      end
    end
    grid[self.y + 1][self.x] = val or '.'
  end
  -- cleanups
  for i= length+1, #self.chars do
    grid.params[self.y][(self.x + i)].dot = false
    grid.params[self.y][(self.x + i)].op = true
    grid.params[self.y][(self.x + i)].cursor = false
  end
end

return T