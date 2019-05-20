timber = function ( self, x, y, frame, grid )
  self.name = "'"
  self.y = y
  self.x = x
  self:spawn( self.ports[self.name] )
  local sample = self:listen( self.x + 1, self.y ) or 0
  local octave = util.clamp( self:listen( self.x + 2, self.y ) or 3, 0, 8 )
  local vel = self:listen( self.x + 4, self.y ) or 0
  local start = self:listen( self.x + 5, self.y ) or 0
  local l = grid[self.y][self.x + 3] ~= 'null' and grid[self.y][self.x + 3] or 'C'
  local note_in = self:listen( self.x + 3, self.y ) or 0
  local note = self.chars[note_in]
  if l == string.upper(l) then note = string.upper(note) end
  local transposed = self.transpose( note, octave )
  local oct = transposed[4]
  local n = transposed[1]
  local velocity = math.floor(( vel / #self.chars ) * 100 )
  local length = params:get("end_frame_" .. sample)
  local start_pos = util.clamp((( start / #self.chars ) * 2 ) * length, 0, length )
  params:set("start_frame_" .. sample,start_pos )
  if self.banged( self.x, self.y ) then
    engine.noteOff( sample )
    engine.amp( sample, ( - velocity ) + 5 )
    engine.noteOn( sample, sample, self.music.note_num_to_freq(n), 100 )
  end
end

return timber