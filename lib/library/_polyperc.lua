local polyperc = function ( self, x, y )

  self.y = y
  self.x = x
  self.name = 'polyperc'
  self.ports = { {1, 0, 'in-octave' }, {2, 0, 'in-note' }, {3, 0, 'in-release' }, {4, 0, 'in-cutoff' }, {5, 0, 'in-amp' }, {6, 0, 'in-pw' }, {7, 0, 'in-gain' } }
  self:spawn(self.ports)

  local octave = util.clamp( self:listen( self.x + 1, self.y ) or 4, 0, 8 )
  local note = self:glyph_at(self.x + 2, self.y) or 'C'
  local release = self:listen( self.x + 3, self.y ) or 18
  local cutoff = self:listen( self.x + 4, self.y ) or 18
  local amp = self:listen( self.x + 5, self.y ) or 18
  local pw = self:listen( self.x + 6, self.y ) or 18
  local gain = self:listen( self.x + 7, self.y ) or 9
  -- local pan = self:listen( self.x + 8, self.y ) or 0

  local transposed = self:transpose( note, octave )
  local hz = self:note_freq( transposed[1] )

  if self:neighbor(self.x, self.y, '*') then
    engine.amp(amp / 35)
    engine.pw(pw / 35)
    engine.release( util.clamp( ( release / 35 ) * 3.2 or 1.2, 0.1, 3.2 ) )
    engine.cutoff( util.clamp( ( cutoff / 35 ) * 5000 or 800, 50, 5000 ) )
    engine.gain( util.clamp( self:listen( self.x + 7, self.y ) or 1, 0, 4 ) )
  -- engine.pan(pan)
    engine.hz(hz)
  end
end



return polyperc