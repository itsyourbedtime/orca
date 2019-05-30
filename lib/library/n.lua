local N = function(self, x, y, glyph)

  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'north'
  self.info = 'Moves northward, or bangs.'

  self.ports = {}
  
  if not self.passive or self:banged() then
    self:move(0, -1)
  end
  
end

return N