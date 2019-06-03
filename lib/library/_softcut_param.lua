local param_ids = { "source", "pan", "rate_slew_time", "level_slew_time", "sc_clear_region" } 
local param_names = { "source", "pan","rate slew time", "level slew time", "clear region" } 
local helper = false

local softcut_param = function ( self, x, y )

  self.y = y
  self.x = x
  
  self.glyph = '\\'
  self.name = 'sc.param'
  self.info = 'Sets softcut param on bang'
  self.passive = false
  self.ports = { {1, 0, 'in-playhead', 'input'}, {2, 0, helper or 'in-param', 'input' }, {3, 0, helper or 'in-value', 'input'} }
  
    local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.sc_ops.max )
    local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
    local val = self:listen( self.x + 3, self.y ) or 0
    val = ( param == 1 and (val % 4) ) or val
    local value = val or 0
    local source = (val == 1 and 'in ext' or val == 2 and 'in engine' or val == 3 and 'both' or val == 0 and 'off')  or 'off'
    helper = param_names[param] .. ' ' .. (param == 1 and source or value )

  self:spawn(self.ports)

  if self:neighbor(self.x, self.y, '*') then
    if param == 1 then
      if val == 0 then
      norns.audio.level_adc_cut(0)
      norns.audio.level_eng_cut(0)
      elseif val == 1 then
        norns.audio.level_adc_cut(1)
        norns.audio.level_eng_cut(0)
      elseif val == 2 then
        norns.audio.level_adc_cut(0)
        norns.audio.level_eng_cut(1)
      elseif val == 3 then
        norns.audio.level_adc_cut(1)
        norns.audio.level_eng_cut(1)
      end
    elseif param == 2 then
      softcut[param_ids[param]](playhead, value % 3)
    elseif param == #param_ids then
      self.sc_clear_region(playhead, value)
    else
      softcut[param_ids[param]](playhead, value)
    end

  end
  
end

return softcut_param
