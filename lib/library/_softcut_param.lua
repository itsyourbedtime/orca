local param_ids = {
  "",  -- audio.level_adc_cut  1 - adc 2 - eng  3 - both
  "pan", 
  "rate_slew_time", 
  "level_slew_time", 
  "filter_fc_mod", 
  "filter_fc", 
  "filter_rq", 
  "loop_end", 
  "sc_clear_region"
  
} 

softcut_param = function ( self, x, y, frame, grid )
  self.name = '\\'
  self.y = y
  self.x = x
  self:spawn( self.ports[self.name] )
  local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.max_sc_ops )
  local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
  local val = self:listen( self.x + 3, self.y ) or 0
  local value = val / 1
  if self.banged( self.x, self.y ) then
    if param == 1 then
      val = (val % 3) + 1
      if val == 0 then 
        norns.audio.level_adc_cut(0)
        norns.audio.level_eng_cut(0)
      elseif val == 1 then
        norns.audio.level_adc_cut(1)
        norns.audio.level_eng_cut(0)
      elseif val == 2 then
        norns.audio.level_eng_cut(1)
        norns.audio.level_adc_cut(0)
      elseif val == 3 then
        norns.audio.level_eng_cut(1)
        norns.audio.level_adc_cut(1)
      end
    elseif param == 9 then
      self.sc_clear_region(playhead, value)
    else
      softcut[param_ids[param]](playhead, value)
    end
  end
end

return softcut_param

