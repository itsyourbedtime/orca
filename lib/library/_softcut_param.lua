local param_ids = {
  "source",
  "pan",
  "rate_slew_time",
  "level_slew_time",
  -- TODO(frederickk): sc_clear_region is not a valid param, if this is a
  -- desired feature, I'll need to adjust param structure to accommodate start
  -- and duration. buffer_clear_region (start, dur)
  -- https://monome.org/docs/norns/api/modules/softcut.html#buffer_clear_region
  -- "sc_clear_region"
}
local param_names = {
  "source",
  "pan",
  "rate slew time",
  "level slew time",
  -- "clear region"
}

local softcut_param = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "sc.param"

  local playhead = util.clamp(self:listen(self.x + 1, self.y) or 1, 1, self.sc_ops.max)
  local param = util.clamp(self:listen( self.x + 2, self.y) or 1, 1, #param_ids)
  local val = self:listen(self.x + 3, self.y) or 0
  val = (param == 1 and (val % 4)) or val
  local value = val or 0
  local source = (val == 1 and "in ext" or val == 2 and "in engine" or val == 3 and "both" or val == 0 and "off") or "off"
  local helper = param_names[param] .. " " .. (param == 1 and source or value)

  self.ports = { {1, 0, "in-playhead", "input"}, {2, 0, helper or "in-param", "input"}, {3, 0, helper or "in-value", "input"} }

  self:spawn(self.ports)

  if self:neighbor(self.x, self.y, "*") then
    if param == 1 then
      if val == 0 then
        audio.level_adc_cut(0)
        audio.level_eng_cut(0)
      elseif val == 1 then
        audio.level_adc_cut(1)
        audio.level_eng_cut(0)
      elseif val == 2 then
        audio.level_adc_cut(0)
        audio.level_eng_cut(1)
      elseif val == 3 then
        audio.level_adc_cut(1)
        audio.level_eng_cut(1)
      end
    elseif param == 2 then -- Pan
      softcut[param_ids[param]](playhead, value % 3)
    elseif param == #param_ids then
      self.sc_clear_region(playhead, value)
    else
      softcut[param_ids[param]](playhead, value)
    end
  end
end

return softcut_param
