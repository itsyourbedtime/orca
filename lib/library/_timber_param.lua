local param_ids = { 
  "amp_env_attack",
  "amp_env_decay",
  "amp_env_sustain", 
  "amp_env_release",
  "detune_cents", 
  "by_percentage",
  "filter_freq", 
  "filter_resonance", 
  "filter_type", 
  "quality",
  "freq_mod_lfo_1", 
  "freq_mod_lfo_2",
  "filter_freq_mod_lfo_1", 
  "filter_freq_mod_lfo_2", 
  "pan_mod_lfo_1", 
  "pan_mod_lfo_2", 
  "amp_mod_lfo_1", 
  "amp_mod_lfo_2",
  "freq_mod_env",
  "filter_freq_mod_env", 
  "filter_freq_mod_vel", 
  "filter_freq_mod_pressure", 
  "filter_tracking",
  "pan_mod_env",
  "mod_env_attack", 
  "mod_env_decay", 
  "mod_env_sustain", 
  "mod_env_release"
}


local param_names = { 
  "attack",
  "decay",
  "sustain", 
  "release",
  "detune", 
  "stretch",
  "cutoff", 
  "resonance", 
  "type", 
  "quality",
  "1 freq mod", 
  "2 freq mod",
  "1 cutff.mod", 
  "2 cutff mod", 
  "1 pan mod", 
  "2 pan mod", 
  "1 amp mod", 
  "2 amp mod",
  "env f.mod",
  "c.env mod", 
  "c.mod vel", 
  "pressure", 
  "tracking",
  "pan e.mod",
  "attack e.mod", 
  "decay e.od", 
  "sust e.mod", 
  "rel e.mod"
  
}

local helper = false
local timber_param = function ( self, x, y )
  
  self.y = y
  self.x = x
  self.name = 'param'
  self.ports = { {1, 0, 'in-sample', 'input'}, {2, 0, helper or 'in-param', 'input'}, {3, 0, helper or 'in-value', 'input'} }
  self:spawn(self.ports)
  
  local sample = self:listen( self.x + 1, self.y ) or 0
  local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
  local val = self:listen( self.x + 3, self.y ) or 0
  local val_scaled = math.floor(( val / 35 ) * 100 )
  local value = (param == 1 or param == 2 or param == 3 or param == 4) and ( val / 35 ) * 5 -- attack / decay
              or param == 6 and val_scaled * 2 -- stretch
              or param == 7 and val_scaled * 200  -- filter freq
              or param == 8 and ( val / 35 )  -- res
              or param == 9 and (val % 2) + 1
              or param == 10 and (val % 4) + 1  
              or param > 10 and ( val / 35 ) -- other
              or val_scaled
              
  helper = param_names[param] .. ' ' .. string.lower(params:string(param_ids[param] .. '_' .. sample))

  if self:neighbor(self.x, self.y, '*') then
    params:set( param_ids[param] .. "_" .. sample, value )
  end
  
end

return timber_param

