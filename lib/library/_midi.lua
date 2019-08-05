local midi_out = function ( self, x, y )

  self.y = y
  self.x = x
  self.name = 'midi'
  self.ports = { {1, 0, 'in-port' }, {2, 0, 'in-octave' }, {3, 0, 'in-note' }, {4, 0, 'in-velocity' }, {5, 0, 'in-length' } }
  self:spawn(self.ports)
  local channel = util.clamp( self:listen( self.x + 1, self.y ) or 0, 0, 16 )
  local octave = util.clamp( self:listen( self.x + 2, self.y ) or 4, 0, 8 )
  local vel = util.clamp( self:listen( self.x + 4, self.y ) or 10, 0, 16 )
  local length = self:listen( self.x + 5, self.y ) or 1
  local note = self:glyph_at(self.x + 3, self.y) or 'C'
  local transposed = self:transpose( note, octave )
  local n, oct, velocity = transposed[1], transposed[4], math.floor(( vel / 16 ) * 127 )
  self:notes_off(channel)
  if self:neighbor(self.x, self.y, '*') then
    self.midi_out_device:note_on( n, velocity, channel )
    self:add_note(channel, n, length, false)
  end

end

return midi_out
