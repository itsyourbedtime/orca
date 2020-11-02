local crow_wsyn = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "crow-w/syn"
  self.ports = { {1, 0, "in-octave"}, {2, 0, "in-note"}, {3, 0, "in-level"} }
  --self.ports = { {1, 0, "in-octave"}, {2, 0, "in-note"}, {3, 0, "in-level"}, {4, 0, "in-lpgTime"}, {5, 0, "in-lpgShape"} }
  self:spawn(self.ports)

  local transpose_tab = {
    ["A"] = 9,
    ["a"] = 10,
    ["B"] = 11,
    ["C"] = 0,
    ["c"] = 1,
    ["D"] = 2,
    ["d"] = 3,
    ["E"] = 4,
    ["F"] = 5,
    ["f"] = 6,
    ["G"] = 7,
    ["g"] = 8,
    ["H"] = 9,
    ["h"] = 10,
    ["I"] = 11,
    ["J"] = 12,
    ["j"] = 13,
    ["K"] = 14,
    ["k"] = 15,
    ["L"] = 16,
    ["M"] = 17,
    ["m"] = 18,
    ["N"] = 19,
    ["n"] = 20,
    ["O"] = 21,
    ["o"] = 22,
    ["P"] = 23,
    ["Q"] = 24,
    ["q"] = 25,
    ["R"] = 26,
    ["r"] = 27,
    ["S"] = 28,
    ["T"] = 29,
    ["t"] = 30,
    ["U"] = 31,
    ["u"] = 32,
    ["V"] = 33,
    ["v"] = 34,
    ["W"] = 35,
    ["X"] = 36,
    ["x"] = 37,
    ["Y"] = 38,
    ["y"] = 39,
    ["Z"] = 40,
    ["e"] = 4,
    ["l"] = 5,
    ["s"] = 5,
    ["z"] = 5,
    ["b"] = 12,
    ["i"] = 12,
    ["p"] = 12,
    ["w"] = 12,
    ["0"] = 0,
    ["1"] = 2,
    ["2"] = 4,
    ["3"] = 5,
    ["4"] = 7,
    ["5"] = 9,
    ["6"] = 11,
    ["7"] = 12,
    ["8"] = 14,
    ["9"] = 16,
  }

  local octave = (util.clamp(self:listen(self.x + 1, self.y) or 3, 0, 7) * 12) - 36
  local note = "C"

  if self:glyph_at(self.x + 2, self.y) == "." then
    note = "C"
  else
    note = self:glyph_at(self.x + 2, self.y)
  end

  local level = util.clamp(self:listen(self.x + 3, self.y) or 3, 0, 5)
  local tot_note = transpose_tab[note] + octave
  local time = util.linlin(0, 35, -5, 5, self:listen(self.x + 4, self.y) or 17)
  local shape = util.linlin(0, 35, -5, 5, self:listen(self.x + 5, self.y) or 17)

  if self:neighbor(self.x, self.y, "*") then
    --tot_note = tot_note / 12
    --crow.send("ii.wsyn.lpg_time(" .. time .. ")")
    --crow.send("ii.wsyn.lpg_symetry(" .. shape .. ")")
    crow.send("ii.wsyn.play_note( " .. (tot_note / 12) .. ", " .. (level / 1) .. ")")
  end
end

return crow_wsyn