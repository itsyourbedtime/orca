local engines = include("lib/engines")

local engine_synth = {}
local synth = function(self, x, y)
  engine_synth = engines.get_synth()

  if engine_synth ~= nil then
    self.y = y
    self.x = x
    self.name = engine.name
    self.ports = {}

    for i = 1, #engine_synth.input_ids do
      self.ports[i] = {i, 0, "in-" .. engine_synth.input_ids[i], "input"}
    end
    self:spawn(self.ports)

    local octave = util.clamp(self:listen(self.x + 1, self.y) or 4, 0, 8)
    local note = self:glyph_at(self.x + 2, self.y) or nil --"C"

    if note ~= "." and note ~= "" then
      engine_synth.run(octave, note, self)
    end
  end
end

return synth