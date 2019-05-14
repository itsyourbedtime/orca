P = function (self, x, y, frame, grid)
  self.name = 'P'
  self.y = y
  self.x = x
  local length = self:input(x - 1, y, 1) or 1
  local pos = util.clamp(self:input(x - 2, y, 0) or 1, 1, length)
  local val = grid[y][x + 1]
  length = util.clamp(length, 1, XSIZE - bounds_x)
  if self:active() then
    self:clean_ports(self.ports[self.name], self.x, self.y)
    for i = 1,length do
      grid.params[y + 1][(x + i) - 1 ].dot = true
      grid.params[y + 1][(x + i) - 1 ].op = false
    end
    self.ports[self.name][4] = {((pos or 1)  % (length+1)) - 1, 1, 'output_op'}
    self:spawn(self.ports[self.name])
    grid[y+1][(x + ((pos or 1)  % (length+1))) - 1] = val
  end
  -- cleanups
  for i= length, #self.chars do
    if grid.params[y + 1][(x + i)].dot then
      grid.params[y + 1][(x + i)].dot = false
      grid.params[y + 1][(x + i) ].op = true
    end
  end
end

return P