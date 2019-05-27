local B = function ( self, x, y, glyph )
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'bounce'
  self.info = 'Bounces between two values based on the runtime frame.'

  self.ports = {
    haste = {-1, 0 , 'in-rate' }, 
    input = {1, 0, 'in-to' }, 
    output = {0, 1, 'b-out' }
  }
  
  local to = self:listen( self.x + 1, self.y ) or 1
  local rate = self:listen( self.x - 1, self.y ) or 1
  to, rate = to == 0 and 1 or to, rate == 0 and 1 or rate
  local key = math.floor( self.frame / rate ) % ( to * 2 )
  local val = key <= to and key or to - ( key - to )
  
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] = self.chars[val]
  elseif self:banged() then
    self.data.cell[self.y + 1][self.x] = self.chars[val]
  end
  
end

return B