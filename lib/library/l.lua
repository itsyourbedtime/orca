local L = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'loop'
  self.info = 'Loops a number of eastward operators.'
    
  self.ports = { 
    haste = {-1, 0, 'in-length'}, {-2, 0, 'in-rate'}
  }

  local length = self:listen( self.x - 1, self.y, 0 ) or 0
  local rate = util.clamp(self:listen( self.x - 2, self.y, 0 ) or 1, 1, #self.chars)
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local l_start = util.clamp( self.x + offset, 1, self.XSIZE)
  local l_end = util.clamp( self.x + length, 1, self.YSIZE)
  self.data.cell.params[self.y][self.x].spawned.seq = length

  if not self.passive then
    self:spawn(self.ports)
    for i = 1, #self.chars do
      if i <= length then
        self.lock(self.x + i, self.y, false, false, true)
      else
        if not self.locked((self.x + i) , self.y) and self:active((self.x + i), self.y) then 
          break
        else
          self.unlock(self.x + i, self.y, false, false, false)
        end
      end
    end
  if (self.frame % rate == 0 and length ~= 0) then
      self:shift(offset, length)
  end
  elseif self:banged() then
    --if frame % rate == 0 and length ~= 0 then
      --self:shift(offset, length)
    --end
  end
  
end

return L

