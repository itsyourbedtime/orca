local C = function ( self, x, y, glyph )

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'clock'
  self.info = 'Outputs a constant value based on the runtime frame.'
  self.ports = { {-1, 0 , 'in-rate', 'haste'},  {1, 0, 'in-mod', 'input'}, {0, 1, 'c-output', 'output'} }
  
  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  mod = mod == 0 and 1 or mod
  rate = rate == 0 and 1 or rate
  local val = ( math.floor( self.frame / rate ) % mod ) + 1
	
  if not self.passive or self:banged() then
    self:spawn(self.ports)
    self:write(0, 1, self.chars[val])
  end
  
end

return C