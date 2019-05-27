local C = function ( self, x, y, glyph )

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'clock'
  self.info = 'Outputs a constant value based on the runtime frame.'
  
  self.ports = {
    haste = {-1, 0 , 'in-rate' }, 
    input = {1, 0, 'in-mod'}, 
    output = {0, 1, 'c-output'}
  }
  
  
  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  mod = mod == 0 and 1 or mod
  rate = rate == 0 and 1 or rate
  local val = ( math.floor( self.frame / rate ) % mod ) + 1
	
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = self.chars[val]
  elseif self:banged( ) then
    self.data.cell[self.y + 1][self.x] = self.chars[val]
  end
  
end

return C