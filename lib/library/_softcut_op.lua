local _softcut_op = function ( self, x, y)
  
  self.y = y
  self.x = x
  
  self.glyph = '/'
  self.name = 'softcut'
  self.passive = false
  self.ports = { {1, 0, 'in-playhead', 'input'}, {2, 0, 'in-rec', 'input'}, {3, 0, 'in-play', 'input'}, 
      {4, 0, 'in-level', 'input'},  {5, 0, 'in-rate', 'input'}, {6, 0, 'in-position', 'input'} }
  
  self:spawn(self.ports)
  
  local playhead = util.clamp(self:listen(self.x + 1, self.y) or 1, 1, self.sc_ops.max )
  local rec = self:listen( self.x + 2, self.y ) or 0
  local play = self:listen( self.x + 3, self.y ) or 0
  local l =  self:listen( self.x + 4, self.y ) or 18
  local r =  self:listen( self.x + 5, self.y ) or 18
  local pos =  self:listen( self.x + 6, self.y ) or 18
  local level = util.round( l / 35, 0.1 )
  local rate = util.round(( r / 35) * 2, 0.1 )
  local pl = play % 3 
  
  self.operation = function ()
    
    
    softcut.pre_level( playhead, rec / 35) 
    softcut.rec_level( playhead, rec / 35 ) 
    softcut.play( playhead, play > 0 and 1 or 0 )
    softcut.rec( playhead, rec > 0 and 1 or 0 )
    softcut.rate( playhead, pl == 2 and -rate or rate )
    softcut.level( playhead, level )
    
    if self:glyph_at(self.x + 2, self.x)  == '*' then
      self:write(self.x + 2, self.y, '.')
      softcut.buffer_clear_region( 0, 35 )
    end
    
    
  end

  self.operation()
  
  if self:neighbor(self.x, self.y, '*') then
    if play ~= 0 then
      self.sc_ops.pos[playhead] = pos
      softcut.position( playhead, pos )
    end
  end
  
end

return _softcut_op