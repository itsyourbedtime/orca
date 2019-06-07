local cc_in = function ( self, x, y )
  
  self.y = y
  self.x = x  
  self.name = 'cc in'
  self.ports = { { 1, 0, 'in-cc' },{ 0, 1, 'cc-out' } }
  self:spawn(self.ports)
  local cc = self:listen( self.x + 1, self.y ) or 1
  local note = self.vars.midi_cc[cc] or 1
  local out = self.chars[ (note % 35 ) + 1]
  self:write(0, 1, out )
  
end

return cc_in