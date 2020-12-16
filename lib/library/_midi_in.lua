local midi_in = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "midi in"
  self.ports = { {1, 0, "in-ch"}, {0, 1, "key-out"} }

  self:spawn(self.ports)

  local ch = self:listen(self.x + 1, self.y) or 1
  local out = self.notes[((self.vars.midi[ch] or 1) % 12) + 1]

  self:write(0, 1, out)
end

return midi_in