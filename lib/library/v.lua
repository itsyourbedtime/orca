local V = function (self, x, y )

  self.y = y
  self.x = x
  self.name = 'variable'
  self.ports = { {-1, 0, 'in-write' }, {1, 0, 'in-read' } }
  
  local a = self:listen(self.x - 1, self.y, 0) 
  local b = self:listen(self.x + 1, self.y, 0)
  local var = self:glyph_at(self.x + 1, self.y)
  local var_a, var_b = self.vars[a], self.vars[b]
  
  if b and not a then 
    self:unlock(self.x - 1, self.y)
    self.ports[1] = { 0, 1, 'v-out', 'output'}
  end

  self:spawn(self.ports)
  
  if b and not a then 
    self:write(0, 1, self.vars[b])
  elseif a then 
    self.vars[a] = var 
  end

end

return V