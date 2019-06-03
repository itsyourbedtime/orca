local W = function(self, x, y, glyph)

  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'west'
  self.info = 'Moves westward, or bangs.'

  self.ports = {}
  
  self:move( -1, 0 )
  
  
end

return W