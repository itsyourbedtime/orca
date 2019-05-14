timber = function (self, x, y, frame, grid)
  self.name = "'"
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local sample = self:input(x + 1, y) or 0
  local octave = util.clamp(self:input(x + 2, y) or 0,0,8)
  local vel = self:input(x + 4, y) or 5
  local start = self:input(x + 5, y) or 0
  if octave == nil or octave == 'null' then octave = 0 end
  local transposed = self.transpose(self.chars[self:input(x + 3, y)], octave )
  local oct = transposed[4]
  local n = math.floor(transposed[1])
  local velocity = math.floor((vel / #self.chars) * 100)
  local length = params:get("end_frame_" .. sample)
  local start_pos = util.clamp(((start / #self.chars)*2) * length, 0, length)
  params:set("start_frame_" .. sample,start_pos )
  if self.banged(x,y) then
    grid.params[y][x].lit_out = false
    engine.noteOff(sample)
    engine.amp(sample, (-velocity) + 5 )
    engine.noteOn(sample, sample, self.music.note_num_to_freq(n), 100)
  else
    grid.params[y][x].lit_out = true
    if frame % ( #self.chars  * 4 )== 0 then engine.noteOff(sample) end
  end
end

return timber