local comment = function ( self, x, y )
  
  self.x = x
  self.y = y
  
  self.glyph = '#'
  self.name = 'comment'
  self.info = 'Halts a line.'
  self.passive = true
  self.ports = { }
  
  for x = x + 1, self.w do
    self.ports[#self.ports + 1] = { x - self.x  , 0, 'comment',  'input' }
    if self.cell[y][x] == '#' then for c = x + 1, self.w - x do
    if self:op(c , y) then break end end break end
  end
  
  self:spawn(self.ports)
  
end

return comment
