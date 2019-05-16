local param_ids = { "quality", "amp_env_attack", "amp_env_decay","original_freq", "detune_cents", "by_percentage","filter_type","filter_freq", "filter_resonance"}

timber_param = function ( self, x, y, frame, grid )
  self.name = '"'
  self.y = y
  self.x = x
  self:spawn( self.ports[self.name] )
  local sample = self:listen( self.x + 1, self.y ) or 0
  local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
  local val = self:listen( self.x + 3, self.y ) or 0
  local val_scaled = math.floor(( val / #self.chars ) * 100 )
  local value = ( param == 1 or param == 7) and val 
  or param == 9 and ( val / #self.chars ) 
  or param == 8 and val_scaled * 200 
  or (param == 2 or param == 3) and ( val / #self.chars ) * 5
  or val_scaled
  if self.banged( self.x, self.y ) then
    grid.params[self.y][self.x].lit_out = false
    params:set( param_ids[param] .. "_" .. sample, value )
  else
    grid.params[self.y][self.x].lit_out = true
  end
end

return timber_param

