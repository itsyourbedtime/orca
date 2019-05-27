local _softcut_op = function ( self, x, y)
  
  self.y = y
  self.x = x
  
  self.glyph = '/'
  self.name = 'softcut'
  self.info = 'Softcut, resets position on bang'
  self.passive = false
  
  self.ports = {
    input = {1, 0, 'in-playhead'}, {2, 0, 'in-rec'}, {3, 0, 'in-play'}, {4, 0, 'in-level'}, {5, 0, 'in-rate'},  {5, 0, 'in-position'}
  }
  
  self:spawn(self.ports)
  
  local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.max_sc_ops )
  local rec = util.clamp( self:listen( self.x + 2, self.y ) or 0, 0, #self.chars )
  local play = util.clamp( self:listen( self.x + 3, self.y ) or 0, 0, #self.chars ) 
  local l =  util.clamp( self:listen( self.x + 4, self.y ) or 18, 0, #self.chars )
  local r =  util.clamp( self:listen( self.x + 5, self.y ) or 18, 0, #self.chars ) 
  local p =  util.clamp( self:listen( self.x + 6, self.y ) or 18, 0, #self.chars ) 
  local pos = util.round((p / #self.chars) * #self.chars, 0.1)
  local level = util.round( l / #self.chars, 0.1 )
  local rate = util.round(( r / #self.chars) * 2, 0.1 )
  local pl = play % 3 
  
  self.operation = function ()
    softcut.pre_level( playhead, rec / #self.chars) 
    softcut.rec_level( playhead, rec / #self.chars ) 
    softcut.play( playhead, play > 0 and 1 or 0 )
    softcut.rec( playhead, rec > 0 and 1 or 0 )
    softcut.rate( playhead, pl == 2 and -rate or rate )
    softcut.level( playhead, level )
    
    if self.data.cell[self.y][self.x + 2] == '*' then
      self.data.cell[self.y][self.x + 2] = 'null'
      softcut.buffer_clear_region( 0, #self.chars )
    end
  end

  self.operation()
  
  if self:banged( ) then
    if play ~= 0 then
      softcut.position( playhead, pos )
    end
  end
  
end

return _softcut_op