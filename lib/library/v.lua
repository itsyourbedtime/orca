local V = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'variable'
  self.info = 'Reads and writes globally available variable'
  
  self.ports = {
    {-1, 0, 'in-write', 'haste'}, 
    {1, 0, 'in-read', 'input'}
  }
  
  local a = self:listen(self.x - 1, self.y, 0) 
  local b = self:listen(self.x + 1, self.y, 0) 
  local var_a, var_b = self.vars[a], self.vars[b]
  
  if b and not a then 
    self.unlock(self.x - 1, self.y)
    self.ports[1] = { 0, 1, 'v-out', 'output'}
  end

  if not self.passive then
    self:spawn(self.ports)
    if b and not a then self.data.cell[self.y + 1][self.x] = self.vars[b] 
    elseif a then self.vars[a] = self.data.cell[self.y][self.x + 1] end
  elseif self:banged() then
    if b and not a then self.data.cell[self.y + 1][self.x] = self.vars[b] 
    elseif a then self.vars[a] = self.data.cell[self.y][self.x + 1] end
  end


end

return V