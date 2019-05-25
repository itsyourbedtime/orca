local P = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'push'
  self.info = 'Writes an eastward operator with offset.'

  self.ports = {{-1, 0, 'input'}, {-2, 0, 'input'}, {1, 0, 'input_op'}, {0, 1, 'output_op'}}
  self:spawn(self.ports)

  local length = self:listen(self.x - 1, self.y, 1) or 1
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)
  local val = grid[self.y][self.x + 1]
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)

  if self:active() then
    for i = 1, #self.chars do
      if i <= length then
        self.lock((self.x + i) -1, self.y + 1, i == pos and true, true)
      else
        if self.operate((self.x + i) + 1, self.y) and self:active((self.x + i) + 1, self.y) then 
          break
        else
          self.unlock((self.x + i) -1, self.y + 1, false)
        end
      end
    end
    grid[self.y + 1][(self.x + ((pos or 1)  % (length + 1))) - 1] = val
  elseif self.banged( self.x, self.y) then
    grid[self.y + 1][(self.x + ((pos or 1)  % (length + 1))) - 1] = val
  end
  
end

return P