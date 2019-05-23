local midi_cc = function ( self, x, y, frame, grid )
  self.name = '!'
  self.y = y
  self.x = x
  self:spawn(self.name)
  self.notes_off_metro.event = self.all_notes_off(channel)
  local channel = util.clamp( self:listen( self.x + 1, self.y ) or 0, 0, 16 )
  local knob = util.clamp( self:listen( self.x + 2, self.y ) or 0, 1, #self.chars )
  local val = util.clamp( self:listen( self.x + 3, self.y ) or 0, 0, #self.chars )
  local val = math.floor(( val / #self.chars ) * 127 )
  if self.banged( self.x, self.y ) then
    self.midi_out_device:cc(knob, val, channel)
  end
end

return midi_cc