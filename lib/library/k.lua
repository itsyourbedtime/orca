K = function (self, x, y, frame, grid)
  self.name = 'K'
  self.y = y
  self.x = x
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp(length, 0, self.XSIZE - self.bounds_x)
  local l_start = self.x + offset
  local l_end = self.x + length
  if self:active() then
    self:spawn(self.ports[self.name])
    if length - offset  == 0 then
      for i=2,length do
        grid.params[self.y][self.x + i].op = true
      end
    else
      for i = 1,length do
        local var = self:listen(x+i,y)
        grid.params[self.y][(self.x + i)].dot = true
        grid.params[self.y + 1][(self.x + i)].dot_port = false
        grid.params[self.y][(self.x + i)].lock = true
        grid.params[self.y + 1][(self.x + i)].lit_out = false
        grid.params[self.y][(self.x + i)].lit = false
        if grid.vars[var] ~= nil then
          grid.params[self.y + 1][(self.x + i)].lock = true
          grid.params[self.y + 1][(self.x + i)].lit_out = false
          grid.params[self.y + 2][(self.x + i)].lit_out = false
          grid.params[self.y + 1][(self.x + i)].lit = false
          grid[self.y + 1][(self.x + i)] = grid.vars[var]
        end
      end
      grid.params[self.y + 1][self.x].dot_port = false
      grid.params[self.y + 1][length + 1].dot_port = false
    end
  end
  -- cleanups
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
      grid.params[self.y][util.clamp((self.x + i), 1, self.XSIZE)].dot = false
      grid.params[self.y][util.clamp((self.x + i), 1, self.XSIZE)].lock = false
    end
  end
end

return K