local engines = include("lib/engines")

local engine_synth = {}
local synth_param = function(self, x, y)
  engine_synth = engines.get_synth()

  if engine_synth ~= nil then
    self.y = y
    self.x = x
    self.name = engine.name .. "-param"

    local param = util.clamp(self:listen(self.x + 1, self.y) or 1, 1, #engine_synth.param_ids)

    self.ports = { {1, 0, engine_synth.param_names[param] or "in-param", "input"}, {2, 0, "in-value", "input"} }
    if engine_synth.ports then
      for i = 1, #engine_synth.ports do
        self.ports[2 + i] = {2 + i, 0, "in-" .. engine_synth.ports[i], "input"}
      end
    end
    self:spawn(self.ports)

    if param ~= "." and param ~= "" then
      engine_synth.param(self)
    end
  end
end

return synth_param