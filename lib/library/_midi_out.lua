local notes_off_metro = metro.init()

midi_out = function ( self, x, y, frame, grid )
  self.name = ':'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local note = 'C'
  local channel = util.clamp( self:listen( x + 1, y ) or 0, 0, 16 )
  local octave = util.clamp( self:listen( x + 2, y ) or 3, 0, 8 )
  local vel = util.clamp( self:listen( x + 4, y ) or 0, 0, 16 )
  local length = util.clamp( self:listen( x + 5, y ) or 0, 0, 16 )
  local transposed = self.transpose( self.chars[self:listen( x + 3, y )], octave )
  local oct = transposed[4]
  local n = math.floor( transposed[1] )
  local velocity = math.floor(( vel / 16 ) * 127 )
  if self.banged( x, y ) then
    self.all_notes_off( channel )
    grid.params[y][x].lit_out = false
    self.midi_out_device:note_on( n, velocity, channel )
    table.insert(grid.active_notes, n)
    notes_off_metro:start(( 60 / self.clk.bpm / self.clk.steps_per_beat / 4 ) * length, 1 )
  else
    grid.params[y][x].lit_out = true
  end
end

return midi_out