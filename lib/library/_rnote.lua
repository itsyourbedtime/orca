local rnote = function ( self, x, y )
  
  self.y = y
  self.x = x

  self.glyph = '^'
  self.name = 'r.note'
  self.info = 'Outputs random note within octave.'
  self.passive = false

  self.ports = { 
    {-1, 0, 'in-rate', 'haste'}, 
    {1, 0, 'in-scale', 'input'}, 
    {0, 1, 'r.note-output', 'output'}
  }
  
  self:spawn(self.ports)
  
  local rate = self:listen( self.x - 1, self.y ) or 1
  local scale = self:listen( self.x + 1, self.y ) or 60
  local mode = util.clamp( scale, 1, #self.chars )
  local scales = self.music.generate_scale_of_length( 60, self.music.SCALES[mode].name, 12 )
  self.data.cell.params[self.y][self.x + 1].info[1] = string.lower(self.music.SCALES[mode].name)

  if self:banged( ) then
    if frame % (rate == 0 and 1 or rate) == 0 then
      self.data.cell[self.y + 1][self.x] =  self.notes[util.clamp( scales[math.random(#scales)] - 60, 1, 12 )]
    end
  end

end

return rnote