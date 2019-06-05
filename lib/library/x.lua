local X = function(self, x, y)

  self.y = y
  self.x = x
  self.name = 'write'

  local a = self:listen(self.x - 2, self.y) or 0 -- x
  local b = self:listen(self.x - 1, self.y) or 1 -- y
  local input = self:glyph_at(self.x + 1, self.y)
  b = b == 0 and 1 or b
  
  self.ports = { {-1, 0, 'in-x' }, {-2, 0, 'in-y' }, {1, 0, 'x-val' }, {a or 0, b or 1, 'x-output' } }
  self:spawn(self.ports)
  
  if self:op(self.x + 1, self.y) then 
    self:unlock(self.x + a, self.y + b, false, true, false, true) 
  end
  
  self:write(a, b, input)

  
end

return X