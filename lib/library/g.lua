local G = function(self, x, y, frame, grid)
  self.name = 'G'
  self.y = y
  self.x = x
  local a = self:listen(self.x - 3, self.y) or 0 -- x
  local b = self:listen(self.x - 2, self.y) or 1 -- y
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local offsety = util.clamp( b + self.y, 1, self.YSIZE) 
  local offsetx = util.clamp( a + self.x, 1, self.XSIZE)
  if self:active() then
    self:spawn( self.ports[self.name] )
    for i = 1, #self.chars do
      local new = grid[self.y][(self.x + i)]
      local is_op = self.is_op(self.x + i, self.y)
      local existing = grid[offsety][(offsetx + i)]
      local ex_is_op = self.is_op((offsetx + i), offsety ) 
      if i <= length then
        grid.params[self.y][(self.x + i)] = {lit = false, lit_out = false, lock = true, cursor = false, dot = true}
        grid.params[self.y + 1][(self.x + i)].lit_out = grid.params[self.y + 1][(self.x + i)].lit_out == true and false or false
        grid[offsety][offsetx + i] = grid[self.y][self.x + i]
        self:add_to_queue(offsetx + i, offsety)
      else
        if grid[self.y][(self.x + i) + 2] == self.name then 
          break
        else
          grid.params[self.y][(self.x + i)].lock = false
          grid.params[self.y][(self.x + i)].dot = false
        end
      end
    end
  elseif self.banged( self.x, self.y ) then
    for i=1,length do
      grid[util.clamp(offsety,1, #self.chars)][(offsetx + i) - 1] = grid[self.y][self.x + i]
      self:add_to_queue((offsetx + i) - 1, util.clamp( offsety, 1, #self.chars ))
    end
  end
end

return G