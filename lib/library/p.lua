local P = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'push'
  self.info = 'Writes an eastward operator with offset.'
  self.ports = { {-1, 0, 'in-length', 'haste'}, {-2, 0, 'in-position', 'haste'}, {1, 0, 'in-value', 'input'} }
  
  local length = self:listen(self.x - 1, self.y, 1) or 1
  local position = self:listen(self.x - 2, self.y, 0) or 1
  local val = self:glyph_at(self.x + 1, self.y)
  local pos = util.clamp((position or 1 ) % ( length + 1 ), 1, 35)
  for i = 1, length do self.ports[#self.ports + 1] = { i - 1, 1, 'in-value',  pos == i and  'output' or 'input' } end
  
  if not self.passive or self:banged() then
    self:write((((pos or 1)  % (length + 1))) - 1, 1,  val)
    self:spawn(self.ports)
  end
end

  
  
return P