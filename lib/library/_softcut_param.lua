-- WIP.. have no mood to test sampling, copypasted timber param op

local param_ids = {
  "",  --  audio.level_adc_cut   -- 1 - adc 2 - eng  3 - both
  "pan",
  "rate_slew_time", -- 
  "level_slew_time", -- 
  "filter_fc_mod",
  "filter_fc", 
  "filter_rq", 
  "loop_end", -- 0 - off  -  clamp  to #self.chars - val 
  "buffer_clear_region" } -- 0 - off  1 - clamp  to #self.chars - val  --2do need to store pos of each playhead

-- 1 - audio.level_adc_cut
-- 2 - pan 
-- 3 - rate_slew_time (voice, value)
-- 4 - level_slew_time (voice, value)
-- 5 - filter_fc_mod (voice, value)
-- 6 - filter_fc (voice, value)
-- 7 - filter_rq (voice, value)
-- 8 - loop end 
-- 9 - clear region 

softcut_param = function ( self, x, y, frame, grid )
  self.name = '\\'
  self.y = y
  self.x = x
  self:spawn( self.ports[self.name] )
  local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.max_sc_ops )
  local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
  local val = self:listen( self.x + 3, self.y ) or 0
  local value = val / #self.chars
  if self.banged( self.x, self.y ) then
    grid.params[self.y][self.x].lit_out = false
    --[[    if param == 1 then
      --val = (val % 3) + 1
      if val == 1 then
        audio.level_adc_cut(1)
        audio.level_eng_cut(0)
      elseif val == 2 then
        audio.level_eng_cut(1)
        audio.level_adc_cut(0)
      elseif val == 3 then
        audio.level_eng_cut(1)
        audio.level_adc_cut(1)
      end
    elseif ( param == 8 or param == 9 ) then
      -- bypass for now
    else
     softcut[param_ids[param]] -- ( playhead, value )
    -- end
  else
    grid.params[self.y][self.x].lit_out = true
  end
end

return softcut_param

