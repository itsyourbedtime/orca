Q = function (self, x, y, frame, grid)
  self.name = 'Q'
  self.y = y
  self.x = x
  self.inputs = {{-3, 0, 'input'}, {-2, 0, 'input'},{-1, 0, 'input'}, {0, 1 , 'output'}}
  local a = self:input(x - 3, y) or 1 -- x
  local b = self:input(x - 2, y) or 0 -- y
  local length = self:input(x - 1, y, 0) or 0
  local offset = 1
  length = util.clamp(length,1,XSIZE - length)
  local offsety = util.clamp(b + y,1,YSIZE)
  local offsetx = util.clamp(a + x,1,XSIZE)
  if self:active() then
    self:spawn(self.inputs)
    for i = 1, length do
      grid[y + 1][(offsetx  + i) - (length + 1)] = grid[offsety][(offsetx + i) -1]
      self:clean_ports(self.ports[self.name], self.x, self.y)
      self.ports[self.name] = self.inputs
      self.ports[self.name][4 + i] = {(a+i)-1, b, 'input'}
      self:spawn(self.ports[self.name])
    end
  end
end

return Q