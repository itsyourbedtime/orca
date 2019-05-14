G = function(self, x, y, frame, grid)
  self.name = 'G'
  self.y = y
  self.x = x
  local a = self:input(x - 3, y) or 0 -- x
  local b = self:input(x - 2, y) or 1 -- y
  local length = self:input(x - 1, y, 0) or 0
  local offset = 1
  length = util.clamp(length,0,self.XSIZE - length)
  local offsety = util.clamp(b + y,1,self.YSIZE) 
  local offsetx = util.clamp(a + x,1,self.XSIZE)
  
  if self:active() then
    self:spawn(self.ports[self.name])
    
    if length == 0 then
      for i=1,length do
        grid.params[y][x + i].op = true
      end
    else
      for i = 1,length do
        grid.params[y][(x + i)].dot = true
        grid.params[y][(x + i)].op = false
        grid.params[y][(x + i)].act = false
        grid.params[y+1][(x + i)].lit_out = false
        grid.params[y][(x + i)].lit = false
      end
    end
    
    
    if length > 0 then
      self:clean_ports(self.ports[self.name], self.x, self.y)
      self.ports[self.name][4] = {a, b, 'output'}
      self:spawn(self.ports[self.name])
    end
    
    
    for i=1,length do
      local existing = grid[self.y][self.x + i] ~= nil and grid[self.y][self.x + i] or 'null'
      if existing == self.list[string.upper(existing)] then
        self:clean_ports(self.ports[string.upper(existing)],  (offsetx + i) - 1, offsety)
      end
      grid[util.clamp(offsety,1, #self.chars)][(offsetx + i) - 1] = grid[self.y][self.x + i]
      self:add_to_queue((offsetx + i) - 1,util.clamp(offsety,1, #self.chars))
    end
  end
  
  -- cleanups 
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
      grid.params[y][(x + i)].dot = false
      grid.params[y][(x + i)].op = true
    end
  end
end

return G