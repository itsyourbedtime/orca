local T = function (self, x, y, frame, grid)
  self.name = 'T'
  self.y = y
  self.x = x
  local length = self:listen(self.x - 1, self.y, 1) or 1
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)  
  local val = grid[self.y][self.x + util.clamp(pos, 1, length)]
  if self:active() then
    grid.params[y + 1][x].lit_out  = true
    self:spawn(self.name)
    for i = 1, #self.chars do
      if i <= length then
        self.lock( self.x + i, self.y, pos == i and true, true )
      else
        if self.op((self.x + i) + 2, self.y) then 
          break
        else
          self.unlock(self.x + i, self.y, false)
        end
      end
    end
    grid[self.y + 1][self.x] = val or '.'
  end
end

return T