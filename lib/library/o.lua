O = function(self, x, y, frame, grid)
  self.name = 'O'
  self.y = y
  self.x = x
  self.listens = {{-1, 0, 'listen'}, {-2, 0, 'listen'}, {0, 1, 'output'}, {1, 0 , 'listen_op'}}
  local a = self:listen(self.x - 2, self.y) or 1 
  local b = self:listen(self.x - 1, self.y) or 0
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  if self:active() then
    grid[self.y + 1][self.x] = grid[offsety][offsetx]
    self:clean_ports(self.ports[self.name], self.x, self.y)
    self.ports[self.name] = self.listens
    self.ports[self.name][4] = {a, b, 'listen'}
    self:spawn(self.ports[self.name])
  end
end

return O