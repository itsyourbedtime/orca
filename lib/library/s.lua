local S = function(self, x, y, glyph)

  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'south'
  self.info = 'Moves southward, or bangs.'

  self.ports = {}

  self:move(0,1)
  
end

return S