local X = function(self, x, y, frame, grid)
  self.name = 'X'
  self.y = y
  self.x = x
  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  if self:active() then
    self:clean_ports(self.ports[self.name], self.x, self.y)
    self.ports[self.name][4] = {a, b, 'output'}
    self:spawn(self.ports[self.name])
    grid[offsety][offsetx] = grid[self.y][self.x + 1]
    if grid[self.y][self.x + 1] == self.list[grid[self.y][self.x + 1]] then 
      self:add_to_queue(offsetx, offsety)
    end
  elseif self.banged( self.x, self.y ) then
    grid[offsety][offsetx] = grid[self.y][self.x + 1]
    if self.op(self.x + 1, self.y) then 
      self:add_to_queue(offsetx, offsety)
    end
  end
end

return X