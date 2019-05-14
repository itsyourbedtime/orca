Q = function (self, x, y, frame, grid)
  self.name = 'Q'
  self.y = y
  self.x = x
  self.listens = {{-3, 0, 'listen'}, {-2, 0, 'listen'},{-1, 0, 'listen'}, {0, 1 , 'output'}}
  local a = self:listen(x - 3, y) or 1 -- x
  local b = self:listen(x - 2, y) or 0 -- y
  local length = self:listen(x - 1, y, 0) or 0
  local offset = 1
  length = util.clamp(length,1, self.XSIZE - length)
  local offsety = util.clamp(b + y, 1, self.YSIZE)
  local offsetx = util.clamp(a + x, 1, self.XSIZE)
  if self:active() then
    self:spawn(self.listens)
    for i = 1, length do
      grid[y + 1][(offsetx  + i) - (length + 1)] = grid[offsety][(offsetx + i) -1]
      self:clean_ports(self.ports[self.name], self.x, self.y)
      self.ports[self.name] = self.listens
      self.ports[self.name][4 + i] = {(a+i)-1, b, 'listen'}
      self:spawn(self.ports[self.name])
    end
  end
end

return Q