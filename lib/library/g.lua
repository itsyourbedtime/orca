local G = function(self, x, y, frame, grid)
  
  self.y = y
  self.x = x
  
  self.name = 'generator'
  self.info = 'Writes distant operators with offset.'
  
  self.ports = {{-3, 0, 'input'}, {-2, 0, 'input'}, {-1, 0, 'input'}}
  self.spawn(self.ports)
  
  local a = self:listen(self.x - 3, self.y) or 0 -- x
  local b = self:listen(self.x - 2, self.y) or 1 -- y
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local offsety = util.clamp( b + self.y, 1, self.YSIZE) 
  local offsetx = util.clamp( a + self.x, 1, self.XSIZE)
  
  if self:active() then
    for i = 1, #self.chars do
      if i <= length then
        self.lock( self.x + i, self.y, false, true )
        grid[offsety][offsetx + i] = grid[self.y][self.x + i]
        if self.op(self.x + i, self.y) then 
          self:add_to_queue(offsetx + i, offsety)
        end
      else
        if self.operate((self.x + i) + 1, self.y) and self:active((self.x + i) + 1, self.y) then 
          break
        else
          self.unlock(self.x + i, self.y, false)
        end
      end
    end
  elseif self.banged( self.x, self.y ) then
    for i=1,length do
      grid[util.clamp(offsety,1, #self.chars)][offsetx + i] = grid[self.y][self.x + i]
      if grid[self.y][self.x + i] == self.list[grid[self.y][self.x + i]] then 
        self:add_to_queue(offsetx + i, offsety)
      end
    end
  end
  
end

return G