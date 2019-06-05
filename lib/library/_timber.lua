local timber = function ( self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'engine'
  self.ports = { {1, 0, 'in-sample', 'input'}, {2, 0, 'in-octave', 'input'}, {3, 0, 'in-note', 'input'}, {4, 0, 'in-level', 'input'}, {5, 0, 'in-position', 'input'} }
  self:spawn(self.ports)
  
  local sample = self:listen( self.x + 1, self.y ) or 0
  local octave = util.clamp( self:listen( self.x + 2, self.y ) or 3, 0, 8 )
  local level = self:listen( self.x + 4, self.y ) or 28
  local start = self:listen( self.x + 5, self.y ) or 0
  local l = self:glyph_at(self.x + 3, self.y) ~= '.' and self:glyph_at(self.x + 3, self.y) or 'C'
  local note_in = self:listen( self.x + 3, self.y ) or 0
  local note = self.chars[note_in]
  if l == string.upper(l) then note = string.upper(note) end
  local transposed = self:transpose( note, octave )
  local n, oct, lev = transposed[1], transposed[4], (( level / 35 ) * 100 ) - 84
  local length = params:get("end_frame_" .. sample)
  local start_pos = util.clamp((( start / 35 ) * 2 ) * length, 0, length )
  
  if self:neighbor(self.x, self.y, '*') then
    params:set("start_frame_" .. sample, start_pos )
    params:set('amp_' .. sample, lev)
    engine.noteOn( sample, sample, self:note_freq(n), 100 )
  end
  
end

return timber