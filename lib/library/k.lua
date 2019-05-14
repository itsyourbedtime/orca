K = function (self, x, y, frame, grid)
  self.name = 'K'
  self.y = y
  self.x = x
  local length = self:listen(x - 1, y, 0) or 0
  local offset = 1
  length = util.clamp(length,0,self.XSIZE - self.bounds_x)
  local l_start = x + offset
  local l_end = x + length
  if self:active() then
    self:spawn(self.ports[self.name])
    if length - offset  == 0 then
      for i=2,length do
        grid.params[y][x + i].op = true
      end
    else
      for i = 1,length do
        local var = self:listen(x+i,y)
        grid.params[y][(x + i)].dot = true
        grid.params[y + 1][(x + i)].dot_port = false
        grid.params[y][(x + i)].op = false
        grid.params[y][(x + i)].act = false
        grid.params[y + 1][(x + i)].lit_out = false
        grid.params[y][(x + i)].lit = false
        if grid.vars[var] ~= nil then
          grid.params[y + 1][(x + i)].op = false
          grid.params[y + 1][(x + i)].act = false
          grid.params[y + 1][(x + i)].lit_out = false
          grid.params[y + 2][(x + i)].lit_out = false
          grid.params[y + 1][(x + i)].lit = false
          grid[y + 1][(x + i)] = grid.vars[var]
        end
      end
      grid.params[y + 1][x].dot_port = false
      grid.params[y + 1][length + 1].dot_port = false
    end
  end
  -- cleanups
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
      grid.params[y][util.clamp((x + i), 1, self.XSIZE)].dot = false
      grid.params[y][util.clamp((x + i), 1, self.XSIZE)].op = true
      grid.params[y + 1][util.clamp((x + i), 1, self.XSIZE)].act = true
    end
  end
end

return K