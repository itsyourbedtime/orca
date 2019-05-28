local param_ids = { "source", "pan", "rate_slew_time", "level_slew_time", "sc_clear_region" } 
local param_names = { "source", "pan","rate slew time", "level slew time", "clear region" } 

local softcut_param = function ( self, x, y )

  self.y = y
  self.x = x
  
  self.glyph = '\\'
  self.name = 'sc.param'
  self.info = 'Sets softcut param on bang'
  self.passive = false

  self.ports = { 
    {1, 0, 'in-playhead', 'input'}, 
    {2, 0, 'in-param', 'input' }, 
    {3, 0, 'in-value', 'input'}
  }

  
  
  self.operation = function ()
    local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.max_sc_ops )
    local param = util.clamp( self:listen( self.x + 2, self.y ) or 1, 1, #param_ids)
    local val = self:listen( self.x + 3, self.y ) or 0
    val = ( param == 1 and (val % 4) ) or val
    local value = val
    local source = (val == 1 and 'in 1' or val == 2 and 'in 2' or val == 3 and 'both' or val == 0 and 'off')  or 'off'
    local helper = param_names[param] .. ' ' .. param == 1 and source  or value 
  end

  self.operation()
  
  if not self.passive then
    self:spawn(self.ports)
  elseif self:banged( ) then
    if param == 1 then
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
