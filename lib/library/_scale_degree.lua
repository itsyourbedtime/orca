local scale_degree = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "scale.degree"
  self.ports = { {-1, 0, "in-scale"}, {1, 0, "in-octave"}, {2, 0, "in-degree"}, {3, 0, "in-root"}, {0, 1, "^-octave-out"}, {1, 1, "^-note-out"} }

  local scale = self:listen(self.x - 1, self.y) or 1 scale = scale == 0 and 1 or scale
  local in_octave = self:listen(self.x + 1, self.y) or 1
  local in_degree = self:listen(self.x + 2, self.y) or 1
  local root = self:glyph_at(self.x + 3, self.y) or "C"

  local transposed = self:transpose(root, 0) or 1
  local get_scale = self:get_scale(scale, transposed[1] + 1)
  local scale_name = get_scale[1]
  local note_array = get_scale[2]
  local note_out = self.notes[note_array[(in_degree - 1) % (#note_array - 1) + 1]]
  local octave_out = in_octave + math.floor(in_degree / #note_array)

  self.ports[1][3] = scale_name
  self:spawn(self.ports)

  -- if self:neighbor(self.x, self.y, "*") then
    self:write(self.ports[5][1], self.ports[5][2], octave_out)
    self:write(self.ports[6][1], self.ports[6][2], note_out)
  -- end
end

return scale_degree

