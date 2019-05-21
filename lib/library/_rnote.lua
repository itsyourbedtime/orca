local rnote = function ( self, x, y, frame, grid )
  self.name = '^'
  self.y = y
  self.x = x
  local rate = self:listen( self.x - 1, self.y ) or 1
  local scale = self:listen( self.x + 1, self.y ) or 60
  local mode = util.clamp( scale, 1, #self.music.SCALES )
  local scales = self.music.generate_scale_of_length( 60, self.music.SCALES[mode].name, 12 )
  if self:active() then
    self:spawn( self.ports[self.name] )
    if frame % rate == 0 then
      grid[self.y + 1][self.x] =  self.notes[util.clamp( scales[math.random(#scales)] - 60, 1, 12 )]
    end
  end
end

return rnote