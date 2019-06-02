local midi_cc = function ( self, x, y )
  
  self.y = y
  self.x = x
  
  self.glyph = '!'
  self.name = 'cc'
  self.info = 'Sends MIDI control change.'
  self.passive = false
  self.ports = { {1, 0, 'in-channel','input' }, {2, 0, 'in-knob', 'input' }, {3, 0, 'in-value', 'input'} }
  
  self:spawn(self.ports)
  
  local channel = util.clamp( self:listen( self.x + 1, self.y ) or 0, 0, 16 )
  local knob = self:listen( self.x + 2, self.y ) or 0
  local val = self:listen( self.x + 3, self.y ) or 0
  local val = math.floor(( val / 35 ) * 127 )
  
  if self:banged( ) then
    self.midi_out_device:cc(knob, val, channel)
  end
  
end

return midi_cc