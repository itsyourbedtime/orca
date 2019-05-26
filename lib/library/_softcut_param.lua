local param_ids = {
  "source",  --  1 - adc 2 - eng  3 - both
  "pan", 
  "rate_slew_time", 
  "level_slew_time", 
  "sc_clear_region"
} 

local softcut_param = function ( self, x, y, frame, grid )
  
  self.y = y
  self.x = x
  
  self.name = 'sc.param'
  self.info = {'Sets softcut param on bang', 'in-playhead', 'in-param', 'in-value' }
  
  self.ports = {{1, 0, 'input_op'}, {2, 0, 'input_op'}, {3, 0, 'input_op'}}
  self:spawn(self.ports)
  
  local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.max_sc_ops )
  local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
  local val = self:listen( self.x + 3, self.y ) or 0
  local value = val / 1
  
  if self.banged( self.x, self.y ) then
    if param == 1 then
      val = val % 4
      norns.audio.level_adc_cut(val == 0 and 0 or 1)
      norns.audio.level_eng_cut(val == 3 and 1 or 0)
    elseif param == #param_ids then
      self.sc_clear_region(playhead, value)
    elseif param == 2 then
      softcut[param_ids[param]](playhead, value % 3)
    else
      softcut[param_ids[param]](playhead, value)
    end
  end
  
end

return softcut_param

