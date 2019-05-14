local max_sc_ops = 6

_softcut_op = function (self, x, y, frame, grid)
  self.name = '/'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  -- bang resets playhead to pos 
  local playhead = util.clamp(self:input(x + 1, y) or 1,1,max_sc_ops)
  local rec = tonumber(grid[y][x + 2]) or 0 -- rec 0 - off 1 - 9 on + rec_level
  local play = tonumber(grid[y][x + 3]) or 0 -- play 0 - stop  1 - 5 / fwd  6 - 9 rev
  local l =  util.clamp(self:input(x + 4, y) or 0,0,#self.chars) -- level 1-z
  local r =  util.clamp(self:input(x + 5, y) or 0,0,#self.chars) -- rate  1-z
  local p =  util.clamp(self:input(x + 6, y) or 0,0,#self.chars) -- pos  1-z 
  local pos = util.round((p / #self.chars) * #self.chars, 0.1)
  local level = util.round((l / #self.chars) * 1, 0.1)
  local rate = util.round((r / #self.chars) * 2, 0.1)
  if grid[y][x + 2] == '*' then
    grid[y][x + 2] = 'null'
    softcut.buffer_clear_region(0, #self.chars)
  end
  if rec >= 1 then 
    softcut.rec_level(playhead, rec/9) 
    grid.params[y][x].lit_out = true 
  else 
    grid.params[y][x].lit_out = false 
    end
  if play > 5 then
    rate = -rate 
  end
  if play > 0 then
    softcut.play(playhead,play)
    softcut.rec(playhead,rec)
    softcut.rate(playhead,rate)
    softcut.level(playhead, level)
  else
    softcut.play(playhead,play)
  end
  if self.banged(x,y) then
    grid.params[y][x].lit_out = false
    if play ~= 0 then
      softcut.position(playhead,pos)
    end
  else 
    grid.params[y][x].lit_out = true
  end
end

return _softcut_op