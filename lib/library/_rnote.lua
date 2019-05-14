rNote = function (self, x, y, frame, grid)
  self.name = '\\'
  self.y = y
  self.x = x
  local rate = self:input(x - 1, y) or 1
  local scale = self:input(x + 1, y) or 60
  local mode = util.clamp(scale, 1, #self.music.SCALES)
  local scales = self.music.generate_scale_of_length(60,self.music.SCALES[mode].name,12)
  if self:active() then
    self:spawn(self.ports[self.name])
    if frame % rate == 0 then
      grid[y+1][x] =  self.notes[util.clamp(scales[math.random(#scales)] - 60, 1, 12)]
    end
  end
end

return rNote