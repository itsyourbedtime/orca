L = function (self, x, y, frame, grid)
  self.name = 'L'
  self.y = y
  self.x = x
  local length = self:listen( x - 1, y, 0 ) or 0
  local rate = self:listen( x - 2, y, 0 ) or 1 
  rate = rate == 0 and 1 or rate
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - self.bounds_x )
  local l_start = util.clamp(x + offset, 1, self.XSIZE - self.bounds_x )
  local l_end = util.clamp(x + length, 1, self.XSIZE - self.bounds_x )
  if self:active() then
    self:spawn(self.ports[self.name])
    if length - offset  == 0 then
      for i= 2, length do
        grid.params[y][x + i].op = true
      end
    else
      for i = 1,length do
        grid.params[y][(x + i)].dot = true
        grid.params[y][(x + i)].op = false
        grid.params[y + 1][(x + i)].lit_out = false
        grid.params[y][(x + i)].lit = false
      end
    end
  end
  if frame % rate == 0 and length ~= 0 then
    self:shift(offset, length)
  end
  -- cleanups
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
      grid.params[y][(x + i)].dot = false
      grid.params[y][(x + i)].op = true
    end
  end
end

return L