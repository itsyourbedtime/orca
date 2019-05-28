local K = function (self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'konkat'
  self.info = 'Otputs multiple variables.'
  
  self.ports = {
    {-1, 0, 'in-length', 'haste'}
  }
  

  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp(length, 0, self.XSIZE - self.bounds_x)
  local l_start = self.x + offset
  local l_end = self.x + length
  self.data.cell.params[self.y][self.x].spawned.seq = length

  if not self.passive then
    self:spawn(self.ports)
    
      for i = 1, #self.chars do
        if i <= length then
          local var = self:listen(x + i, y)
          self.lock(self.x + i, self.y, false, false, true)
          if self.data.cell.vars[var] ~= nil then
          self.lock(self.x + i, self.y + 1 , false, false, true)
            self.data.cell[self.y + 1][(self.x + i)] = self.data.cell.vars[var]
          end
        else
          if not self.locked((self.x + i), self.y) then 
            break
          else
            self.unlock(self.x + i, self.y, false, false, false)
          end
        end
      end

end
end

return K