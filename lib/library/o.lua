local O = function(self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'offset'
  self.info = {'Reads a distant operator with offset.', 'in-x', 'in-y', 'offset-out', 'o-read'}
  
  self.ports = {{-1, 0, 'input'}, {-2, 0, 'input'}, {0, 1, 'output'}, {1, 0 , 'input_op'}}
  self:spawn(self.ports)

  local a = self:listen(self.x - 2, self.y) or 1 
  local b = self:listen(self.x - 1, self.y) or 0
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  grid.params[self.y][self.x].offsets = {offsetx, offsety}

  if self:active() then
    grid[self.y + 1][self.x] = grid[offsety][offsetx]
    self.clean_ports(self.x, self.y)
    self.ports[4] = {a, b , 'input_op'}
    self:spawn(self.ports)
  end
  
end

return O