O = function(self, x, y, frame, grid)
  self.name = 'O'
  self.y = y
  self.x = x
  self.inputs = {{-1, 0, 'input'}, {-2, 0, 'input'}, {0, 1, 'output'}, {1, 0 , 'input_op'}}
  local a = self:input(x - 2, y) or 1 
  local b = self:input(x - 1, y) or 0
  local offsety = util.clamp(b + y, 1, self.YSIZE)
  local offsetx = util.clamp(a + x, 1, self.XSIZE)
  if self:active() then
    grid[y + 1][x] = grid[offsety][offsetx]
    self:clean_ports(self.ports[self.name], self.x, self.y)
    self.ports[self.name] = self.inputs
    self.ports[self.name][4] = {a, b, 'input'}
    self:spawn(self.ports[self.name])
  end
end

return O