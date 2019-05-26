local L = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'loop'
  self.info = {'Loops a number of eastward operators.', 'in-length', 'in-rate'}
    
  self.ports = {{-1, 0, 'input'}, {-2, 0, 'input'}}
  self:spawn(self.ports)

  local length = self:listen( self.x - 1, self.y, 0 ) or 0
  local rate = util.clamp(self:listen( self.x - 2, self.y, 0 ) or 1, 1, #self.chars)
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local l_start = util.clamp( self.x + offset, 1, self.XSIZE)
  local l_end = util.clamp( self.x + length, 1, self.YSIZE)
  grid.params[self.y][self.x].seq = length

  if self:active() then
    if frame % rate == 0 and length ~= 0 then
      self:shift(offset, length)
    end
    for i = 1, #self.chars do
      if i <= length then
        self.lock(self.x + i, self.y, false, true)
      else
        if self.operate((self.x + i) + 1, self.y) and self:active((self.x + i) + 1, self.y) then 
          break
        else
          self.unlock(self.x + i, self.y, false)
        end
      end
    end
  elseif self.banged(self.x, self.y) then
    --if frame % rate == 0 and length ~= 0 then
      --self:shift(offset, length)
    --end
  end
  
end

return L

