local comment = function ( self, x, y )
  
  self.x = x
  self.y = y
  self.name = 'comment'
  self.ports = { }
  
  for x = x + 1, self.w do
    self.ports[#self.ports + 1] = { x - self.x  , 0, 'comment',  'input' }
    if self:glyph_at(x, y) == '#' then  break end
  end
  
  self:spawn(self.ports)
  
end

return comment
