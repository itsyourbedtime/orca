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
  local rec = tonumber( grid[self.y][self.x + 2] ) or 0 -- rec 0 - off 1 - 9 on + rec_level
  local play = tonumber( grid[self.y][self.x + 3] ) or 0 -- play 0 - stop  1 - 5 / fwd  6 - 9 rev
  local l =  util.clamp( self:listen( self.x + 4, self.y ) or 0, 0, #self.chars ) -- level 1-z
  local r =  util.clamp( self:listen( self.x + 5, self.y ) or 0, 0, #self.chars ) -- rate  1-z
  local p =  util.clamp( self:listen( self.x + 6, self.y ) or 0, 0, #self.chars ) -- pos  1-z 
  local pos = util.round((p / #self.chars) * #self.chars, 0.1)
  local level = util.round(( l / #self.chars) * 1, 0.1 )
  local rate = util.round(( r / #self.chars) * 2, 0.1 )
  if grid[self.y][self.x + 2] == '*' then
    grid[self.y][self.x + 2] = 'null'
    softcut.buffer_clear_region( 0, #self.chars )
  end
  if rec >= 1 then  
    if rec < 9 then softcut.pre_level( playhead, (rec) / 9) else softcut.pre_level( playhead, 1) end
    softcut.rec_level( playhead, rec / 9 ) 
    grid.params[self.y][self.x].lit_out = true 
  else 
    grid.params[self.y][self.x].lit_out = false 
    end
  if play > 5 then
    rate = -rate 
  end
  if play > 0 then
    softcut.play( playhead, play )
    softcut.rec( playhead, rec )
    softcut.rate( playhead, rate )
    softcut.level( playhead, level )
  else
    softcut.play(playhead,play)
  end
  if self.banged(self.x, self.y) then
    grid.params[self.y][self.x].lit_out = false
    if play ~= 0 then
      softcut.position( playhead, pos )
    end
  else 
    grid.params[self.y][self.x].lit_out = true
  end
end

return _softcut_op