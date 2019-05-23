local X = function(self, x, y, frame, grid)
  self.name = 'X'
  self.y = y
  self.x = x
  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  local input = grid[self.y][self.x + 1]
  if self:active() then
    --self:clean_ports(self.x, self.y)
    --self.ports[self.name][4] = {a, b, 'output'}
    self:spawn(self.name)
    grid[offsety][offsetx] = self.copy(input)
    if self.op(self.x + 1, self.y)  then 
      self:add_to_queue(offsetx, offsety)
    end
  elseif self.banged( self.x, self.y ) then
    grid[offsety][offsetx] = self.copy(input)
    if self.op(self.x + 1, self.y) then 
      self:add_to_queue(offsetx, offsety)
    end
  else
  end
end

return X