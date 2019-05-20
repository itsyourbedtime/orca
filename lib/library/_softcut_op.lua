_softcut_op = function ( self, x, y, frame, grid)
  self.name = '/'
  self.y = y
  self.x = x
  -- default buffer vals
  if grid.sc_ops[self:id(self.x,self.y)] == nil then 
    self.sc_ops = util.clamp(self.sc_ops + 1, 1, self.max_sc_ops)
    grid.sc_ops[self:id(self.x,self.y)] = self.sc_ops
    grid[self.y][self.x + 1] = grid.sc_ops[self:id(self.x,self.y)]
  end
  
  self:spawn( self.ports[self.name] )
  local playhead = util.clamp( self:listen(self.x + 1, self.y) or 1, 1, self.max_sc_ops )
  local rec = util.clamp( self:listen( self.x + 2, self.y ) or 0, 0, #self.chars ) -- rec 0 - off 1 - z on + rec_level
  local play = util.clamp( self:listen( self.x + 3, self.y ) or 0, 0, #self.chars ) -- play 0 - off 1 - fwd 2 - rev
  local l =  util.clamp( self:listen( self.x + 4, self.y ) or 18, 0, #self.chars ) -- level 1-z
  local r =  util.clamp( self:listen( self.x + 5, self.y ) or 18, 0, #self.chars ) -- rate  1-z
  local p =  util.clamp( self:listen( self.x + 6, self.y ) or 18, 0, #self.chars ) -- pos  1-z 
  local pos = util.round((p / #self.chars) * #self.chars, 0.1)
  local level = util.round( l / #self.chars, 0.1 )
  local rate = util.round(( r / #self.chars) * 2, 0.1 )
  local pl = play % 3 
  grid.sc_ops_pos[playhead] = pos
  if grid[self.y][self.x + 2] == '*' then
    grid[self.y][self.x + 2] = 'null'
    softcut.buffer_clear_region( 0, #self.chars )
  end
  if rec > 0 then  
    if rec < #self.chars then 
      softcut.pre_level( playhead, rec / #self.chars) 
    else 
      softcut.pre_level( playhead, 1) 
    end
    softcut.rec_level( playhead, rec / #self.chars ) 
  end
  if play > 0 then
    softcut.play( playhead, 1)
    softcut.rec( playhead, rec > 0 and 1 or 0 )
    softcut.rate( playhead, pl == 2 and -rate or rate )
    softcut.level( playhead, level )
  else
    softcut.play(playhead, 0)
  end
  if self.banged(self.x, self.y) then
    if play ~= 0 then
      softcut.position( playhead, pos )
    end
  end
end

return _softcut_op