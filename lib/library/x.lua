local X = function(self, x, y, frame, grid)
  
  self.y = y
  self.x = x
  
  self.name = 'write'
  self.info = 'Writes a distant operator with offset'

  self.ports = {{-1, 0, 'input'}, {-2, 0, 'input'}, {1, 0, 'input_op'}}
  self:spawn(self.ports)
  
  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  local input = grid[self.y][self.x + 1]
  
  if self:active() then
    grid[offsety][offsetx] = input
    if self.op(self.x + 1, self.y)  then 
      self:add_to_queue(offsetx, offsety)
    end
  elseif self.banged( self.x, self.y ) then
    grid[offsety][offsetx] = input
    if self.op(self.x + 1, self.y) then 
      self:add_to_queue(offsetx, offsety)
    end
  end
  
end

return X