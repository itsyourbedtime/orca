local midi_cc = function ( self, x, y, frame, grid )
  
  self.y = y
  self.x = x
  
  self.name = 'cc'
  self.info = 'Sends MIDI control change.'
  
  self.ports = {{1, 0, 'input_op'}, {2, 0, 'input_op'}, {3, 0, 'input_op'}}
  self:spawn(self.ports)
  
  local channel = util.clamp( self:listen( self.x + 1, self.y ) or 0, 0, 16 )
  local knob = util.clamp( self:listen( self.x + 2, self.y ) or 0, 1, #self.chars )
  local val = util.clamp( self:listen( self.x + 3, self.y ) or 0, 0, #self.chars )
  local val = math.floor(( val / #self.chars ) * 127 )
  
  if self.banged( self.x, self.y ) then
    self.midi_out_device:cc(knob, val, channel)
  end
  
end

return midi_cc