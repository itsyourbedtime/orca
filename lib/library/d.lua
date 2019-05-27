local D = function ( self, x, y, glyph )
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'delay'
  self.info = 'Bangs on a fraction of the runtime frame.'
  
  self.ports = {
    haste = {-1, 0 , 'in-rate' }, 
    input = {1, 0, 'in-mod'}, 
    output = {0, 1, 'd-output'}
  }
  
  local mod = self:listen( self.x + 1, self.y ) or 9
  local rate = self:listen( self.x - 1, self.y ) or 1
  mod = mod == 0 and 1 or mod 
  rate = rate == 0 and 1 or rate 
  local val = ( self.frame % ( mod * rate ))
  local out = ( val == 0 or mod == 1 ) and '*' or 'null'
  
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = out
  elseif self:banged( ) then
    self.data.cell[self.y + 1][self.x] = out
  end
  
end

return D