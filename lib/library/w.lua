local W = function(self, x, y, glyph)

  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'west'
  self.info = 'Moves westward, or bangs.'

  self.ports = {}
  
  if not self.passive then
    self:move( -1, 0 )
  elseif self:banged( ) then
    self:move( -1, 0 )
  end
  
end

return W