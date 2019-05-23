local L = function (self, x, y, frame, grid)
  self.name = 'L'
  self.y = y
  self.x = x
  local length = self:listen( self.x - 1, self.y, 0 ) or 0
  local rate = util.clamp(self:listen( self.x - 2, self.y, 0 ) or 1, 1, #self.chars)
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local l_start = util.clamp( self.x + offset, 1, self.XSIZE)
  local l_end = util.clamp( self.x + length, 1, self.YSIZE)
  if self:active() then
    self:spawn(self.name)
    for i = 1, #self.chars do
      local is_op = self.operate(self.x + i, self.y)
      if i <= length then
        self.lock(self.x + i, self.y, false, true)
        grid.params[self.y + 1][self.x + i].lit_out = false
        self:clean_ports(self.x + i, self.y) 
      else
        break
      end
      if self.operate(self.x + i, self.y) then 
        self:add_to_queue(self.x + i, self.y) 
      end
    end
    if frame % rate == 0 and length ~= 0 then
      self:shift(offset, length)
    end
  elseif self.banged(self.x, self.y) then
  end
end

return L