local D = function ( self, x, y, glyph )
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'delay'
  self.info = 'Bangs on a fraction of the runtime frame.'
  self.ports = { {-1, 0 , 'in-rate', 'haste'}, {1, 0, 'in-mod', 'input'}, {0, 1, 'd-output', 'output'} }
  
  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  mod = mod == 0 and 1 or mod rate = rate == 0 and 1 or rate 
  local val = ( self.frame % ( mod * rate ))
  local out = ( val == 0 or mod == 1 ) and '*' or '.'
  
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(0, 1, out)
  end
  
end

return D