X = function(self, x, y, frame, grid)
  self.name = 'X'
  self.y = y
  self.x = x
  local a = self:listen(x - 2, y) or 0 -- x
  local b = self:listen(x - 1, y) or 1 -- y
  local offsety = util.clamp(b + y, 1, self.YSIZE)
  local offsetx = util.clamp(a + x, 1, self.XSIZE)
  if self:active() then
    self:clean_ports(self.ports[self.name], self.x, self.y)
    self.ports[self.name][4] = {a, b, 'output'}
    self:spawn(self.ports[self.name])
    grid[util.clamp(offsety,1, #self.chars)][offsetx] = grid[y][x+1]
    grid.params[util.clamp(offsety,1, #self.chars)][offsetx].placeholder = grid[y][x+1] ~= '*' and 
    self:add_to_queue(offsetx,util.clamp(offsety,1, #self.chars))
  end
end

return X