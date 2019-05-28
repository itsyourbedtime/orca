local M  = function ( self, x, y, glyph )

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'multiply'
  self.info = 'Outputs product of inputs.'

  self.ports = {
    {-1, 0 , 'in-a', 'haste'}, 
    {1, 0, 'in-b', 'input'}, 
    {0, 1, 'm-output', 'output'}
  }
  

  local l = self:listen( self.x - 1, self.y, 1 ) or 0
  local m = self:listen( self.x + 1, self.y, 1 ) or 0

  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = self.chars[( l * m ) % #self.chars]
  elseif self:banged() then
    self.data.cell[self.y + 1][self.x] = self.chars[( l * m ) % #self.chars]
  end
  
end

return M