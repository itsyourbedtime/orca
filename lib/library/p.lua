local P = function (self, x, y, frame, grid)
  self.name = 'P'
  self.y = y
  self.x = x
  local length = self:listen(self.x - 1, self.y, 1) or 1
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)
  local val = grid[self.y][self.x + 1]
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  if self:active() then
    self:clean_ports(self.ports[self.name], self.x, self.y)
    for i = 1, #self.chars do
      if i <= length then
        grid.params[self.y + 1][(self.x + i) - 1 ].dot = true
        grid.params[self.y + 1][(self.x + i) - 1 ].lock = true
      else
        if grid[self.y][(self.x + i)] == self.name then 
          break
        else
          grid.params[self.y + 1][(self.x + i)].dot = false
          grid.params[self.y + 1][(self.x + i) ].lock = false
        end
      end
    end
    self.ports[self.name][4] = {((pos or 1)  % (length + 1)) - 1, 1, 'output_op'}
    self:spawn(self.ports[self.name])
    grid[self.y + 1][(self.x + ((pos or 1)  % (length + 1))) - 1] = val
  end
end

return P