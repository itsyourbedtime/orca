local R = function (self, x, y, frame, grid)
  self.name = 'R'
  self.y = y
  self.x = x
  local a = util.clamp(self:listen(self.x - 1, self.y) or 0, 0, #self.chars)
  local b = util.clamp(self:listen(self.x + 1, self.y) or #self.chars, 1, #self.chars)
  local cap = (grid[self.y][self.x + 1]~= nil and grid[self.y][self.x + 1] == string.upper(grid[self.y][self.x + 1])) and true or false
  if b < a then a,b = b,a end
  local val = self.chars[math.random(a,b)]
  local value = cap and string.upper(val) or val
  if self:active() then
    self:spawn(self.name)
    grid[self.y + 1][self.x] = value
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = value
    --if value == self.list[value] then 
      --self:add_to_queue(self.x, self.y + 1)
    ---end
  end
end

return R