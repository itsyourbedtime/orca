local param_ids = { 
  "amp_env_attack",
  "amp_env_decay", 
  "original_freq", 
  "detune_cents", 
  "by_percentage",
  "filter_freq", 
  "filter_resonance", 
  "filter_type", 
  "quality" 
  
}

local timber_param = function ( self, x, y, frame, grid )
  self.name = '"'
  self.y = y
  self.x = x
  self:spawn(self.name)
  local sample = self:listen( self.x + 1, self.y ) or 0
  local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
  local val = self:listen( self.x + 3, self.y ) or 0
  local val_scaled = math.floor(( val / #self.chars ) * 100 )
  local value = (param == 1 or param == 2) and ( val / #self.chars ) * 5 -- attack / decay
              or param == 5 and val_scaled * 2 -- stretch
              or param == 6 and val_scaled * 200  -- filter freq
              or param == 7 and ( val / #self.chars )  -- res
              or param == 8 and (val % 2) + 1
              or param == 9 and (val % 4) + 1  
              or val_scaled
  if self.banged( self.x, self.y ) then
    params:set( param_ids[param] .. "_" .. sample, value )
  end
end

return timber_param

