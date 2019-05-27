local E = function( self, x, y, glyph )
  
  self.x = x
  self.y = y
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'east'
  self.info = 'Moves eastward, or bangs.'
  
  self.ports = {}

  if not self.passive then
    self:move(1, 0)
  elseif self:banged() then
    self:move(1, 0)
  end
  
end

return E