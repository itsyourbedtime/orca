local timber = function ( self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'engine'
  self.ports = { {1, 0, 'in-sample'}, {2, 0, 'in-octave'}, {3, 0, 'in-note'}, {4, 0, 'in-level'}, {5, 0, 'in-position'} }
  self:spawn(self.ports)
  
  local sample = self:listen( self.x + 1, self.y ) or 0
  local octave = util.clamp( self:listen( self.x + 2, self.y ) or 3, 0, 8 )
  local level = self:listen( self.x + 4, self.y ) or 28
  local start = self:listen( self.x + 5, self.y ) or 0
  local note = self:glyph_at(self.x + 3, self.y) or 'C'
  local transposed = self:transpose( note, octave )
  local n, oct, lev = transposed[1], transposed[4], (( level / 35 ) * 100 ) - 84
  local length = params:get("end_frame_" .. sample)
  local start_pos = util.clamp((( start / 35 ) * 2 ) * length, 0, length )
  
  if self:neighbor(self.x, self.y, '*') then
    params:set("start_frame_" .. sample, start_pos )
    params:set('amp_' .. sample, lev)
    engine.noteOn( sample, self:note_freq(n), 1, sample )
  end
  
end

return timber
