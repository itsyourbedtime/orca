local P = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'push'
  self.info = 'Writes an eastward operator with offset.'

  self.ports = {
    haste = {-1, 0, 'in-length'}, {-2, 0, 'in-position'}, 
    input = {1, 0, 'in-value'}, 
    output = {0, 1, 'p-output'}
  }
  
  local length = self:listen(self.x - 1, self.y, 1) or 1
  local pos = util.clamp(self:listen(self.x - 2, self.y, 0) or 1, 1, length)
  local val = self.data.cell[self.y][self.x + 1]
  length = util.clamp(length, 1, self.XSIZE - self.bounds_x)
  
  self.data.cell.params[self.y][self.x].spawned.seq = length
  self.data.cell.params[self.y][self.x].spawned.offsets = {0, 1}
  
  if not self.passive then
    self:spawn(self.ports)
    for i = 1, #self.chars do
      if i <= length then
        self.lock((self.x + i) -1, self.y + 1, false,  i == pos and true, true)
      else
        if not self.locked((self.x + i) + 1, self.y) and self:active((self.x + i) + 1, self.y) then 
          break
        else
          self.unlock((self.x + i) -1, self.y + 1, false, false, false)
        end
      end
    end
    self.data.cell[self.y + 1][(self.x + ((pos or 1)  % (length + 1))) - 1] = val
  elseif self:banged( ) then
    self.data.cell[self.y + 1][(self.x + ((pos or 1)  % (length + 1))) - 1] = val
  end
  
end

return P