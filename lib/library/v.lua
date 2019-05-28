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

  local a = self:listen(self.x - 1, self.y, 0) or 0
  local b = self:listen(self.x + 1, self.y, 0) or self.data.cell[self.y][self.x + 1]
  
  if not self.passive then
    self:spawn(self.ports)
    
    if ((self.data.cell.vars[b] ~= nil and self.data.cell.vars[b] ~= '.')  and a == 0) then
      if self.data.cell.vars[b] ~= nil then
       self.data.cell.params[self.y + 1][self.x].lit_out = true
       self.data.cell[self.y + 1][self.x] = self.data.cell.vars[b] 
      end 
    elseif b ~= '.' and  a ~= 0 then
      self.data.cell.vars[a] = self.data.cell[self.y][self.x + 1]
    elseif b == '.' and a ~= 0 then 
      self.data.cell.vars[a] = '.'
    else 
      self.data.cell[self.y + 1][self.x] = '.'
      self.data.cell.params[self.y + 1][self.x].lit_out = false
    end
  elseif self:banged( ) then
    if ((self.data.cell.vars[b] ~= nil and self.data.cell.vars[b] ~= '.')  and a == 0) then
      if self.data.cell.vars[b] ~= nil then
       self.data.cell.params[self.y + 1][self.x].lit_out = true
       self.data.cell[self.y + 1][self.x] = self.data.cell.vars[b] 
      end 
    elseif self.active() and b ~= 0 and  a ~= 0  then
      self.data.cell.vars[a] = self.data.cell[self.y][self.x + 1]
    else 
      self.data.cell[self.y + 1][self.x] = '.'
      self.data.cell.params[self.y + 1][self.x].lit_out = false
    end
  end
  
end

return V