local param_ids = {
  "level_dac",
  "level_eng",
  "level_cut",
  "level_adc",
  "level_eng_rev",
  "level_cut_rev",
  "level_rev_dac",
  "level_adc_cut",
  "level_eng_cut"
}

local param_names = {
  "level output",
  "level engine",
  "level softcut",
  "level ADC input",
  "reverb engine",
  "reverb softcut",
  "reverb DAC",
  "softcut ADC",
  "softcut engine"
}
local helper = false

local levels = function ( self, x, y )

  self.y = y
  self.x = x
  self.name = "levels"
  self.ports = { {1, 0, helper or "in-param"  }, {2, 0, helper or "in-value" } }

  local param = util.clamp( self:listen( self.x + 1, self.y ) or 1, 1, #param_ids )
  local val = self:listen( self.x + 2, self.y ) or 0
  local value = val / 35

  helper = param_names[param] .. " " .. util.round( value, 0.1 )

  self:spawn( self.ports )

  if self:neighbor( self.x, self.y, "*" ) then
    audio[ param_ids[param] ]( value )
  end
  
end

return levels
