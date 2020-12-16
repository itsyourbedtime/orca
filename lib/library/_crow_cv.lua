local crow_cv = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "crow-cv"
  self.ports = { {1, 0, "in-channel"}, {2, 0, "in-octave"}, {3, 0, "in-note" }, {4, 0, "in-attack" }, {5, 0, "in-release"}, {6, 0, "in-level"} }
  self:spawn(self.ports)

  local cv_transpose_table = {
    ["A"] = 0.833,
    ["a"] = 0.916,
    ["B"] = 1.000,
    ["C"] = 0.083,
    ["c"] = 0.166,
    ["D"] = 0.250,
    ["d"] = 0.333,
    ["E"] = 0.416,
    ["F"] = 0.500,
    ["f"] = 0.583,
    ["G"] = 0.666,
    ["g"] = 0.750,
    ["H"] = 0.000,
    ["h"] = 0.083,
    ["I"] = 0.166,
    ["J"] = 1.083,
    ["j"] = 1.166,
    ["K"] = 1.250,
    ["k"] = 1.333,
    ["L"] = 1.416,
    ["M"] = 1.500,
    ["m"] = 1.583,
    ["N"] = 1.666,
    ["n"] = 1.750,
    ["O"] = 1.833,
    ["o"] = 1.916,
    ["P"] = 2.000,
    ["Q"] = 2.083,
    ["q"] = 2.166,
    ["R"] = 2.250,
    ["r"] = 2.333,
    ["S"] = 2.416,
    ["T"] = 2.500,
    ["t"] = 2.583,
    ["U"] = 2.666,
    ["u"] = 2.750,
    ["V"] = 2.833,
    ["v"] = 2.916,
    ["W"] = 3.000,
    ["X"] = 3.083,
    ["x"] = 3.166,
    ["Y"] = 3.250,
    ["y"] = 3.333,
    ["Z"] = 3.416,
    ["e"] = 3.500,
    ["l"] = 3.583,
    ["s"] = 3.666,
    ["z"] = 3.750,
    ["b"] = 3.833,
    ["i"] = 3.916,
    ["p"] = 4.000,
    ["w"] = 4.083,
    ["0"] = 4.166,
    ["1"] = 4.250,
    ["2"] = 4.333,
    ["3"] = 4.416,
    ["4"] = 4.500,
    ["5"] = 4.583,
    ["6"] = 4.666,
    ["7"] = 4.750,
    ["8"] = 4.833,
    ["9"] = 4.916,
  }

  local channel = 1
  local ar_channel = 2

  if (self:listen(self.x + 1, self.y) == 0 or nil) then
    channel = 1
    ar_channel = 2
  else
    channel = 3
    ar_channel = 4
  end

  local octave = self:listen(self.x + 2, self.y) or 1
  local n = tostring(self:glyph_at(self.x + 3, self.y)) or "C"
  local note = cv_transpose_table[n] or .08
  local attack = util.linlin(0, 35, 0.00, 1.50, self:listen(self.x + 4, self.y) or 0)
  local release = util.linlin(0, 35, 0.00, 3.00, self:listen(self.x + 5, self.y) or 1)
  local volts = octave + note
  local level = util.linlin(0, 35, 0.00, 10.00, self:listen(self.x + 6, self.y) or 25)

  if self:neighbor(self.x, self.y, "*") then
    crow.output[channel].volts = volts
    crow.output[ar_channel].action = "{to(" .. level .. "," .. attack .. "),to(0," .. release .. ")}"
    crow.output[ar_channel]()
  end
end

return crow_cv