local T = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'track'
  self.info = {'Reads an eastward operator with offset', 'in-length', 'in-pos', 'in-val', 'track-out'}
  
  self.ports = {{-1, 0, 'input'},  {-2, 0, 'input'}, {1, 0, 'input_op'}, {0, 1 , 'output_op'}}
  self:spawn(self.ports)
  
  local length = self:listen(self.x - 1, self.y, 1) or 1
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)  
  local val = grid[self.y][self.x + util.clamp(pos, 1, length)]
  grid.params[self.y][self.x].seq = length

  if self:active() then
    for i = 1, #self.chars do
      if i <= length then
        self.lock( self.x + i, self.y, pos == i and true, true )
      else
        if self.operate((self.x + i) + 1, self.y) and self:active((self.x + i) + 1, self.y) then 
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