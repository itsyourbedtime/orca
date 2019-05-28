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
  
  self.mode = false 
  
  local rate = self:listen( self.x - 1, self.y ) or 1
  rate = rate == 0 and 1 or rate 
  local scale = self:listen( self.x + 1, self.y ) or 60
  local mode = util.clamp( scale, 1, #self.chars )
  local scales = self.music.generate_scale_of_length( 60, self.music.SCALES[mode].name, 12 )
  local name = string.lower(self.music.SCALES[mode].name)
  local val 
  self.ports[2][3] = name
  self.ports[3][3] = name
  
  if mode == true then 
    val = util.clamp( scales[math.random(#scales)] - 60, 1, 12 )
  elseif mode == false then
    val = scales[ self.frame % rate ]
  end
  
  if not self.passive then
    self:spawn(self.ports)
    self.data.cell[self.y + 1][self.x] =  self.notes[util.clamp( scales[math.random(#scales)] - 60, 1, 12 )]
  if self:banged() then
    self.mode = not self.mode
    print(self.name)
    end
  end
end

return rnote