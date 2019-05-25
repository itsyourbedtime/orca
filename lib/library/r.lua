local R = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'random'
  self.info = 'Outputs a random value.'

  self.ports = {{-1, 0, 'input'}, { 1, 0, 'input_op'}, {0, 1 , 'output'}}
  self:spawn(self.ports)

  local a = util.clamp(self:listen(self.x - 1, self.y) or 0, 0, #self.chars)
  local b = util.clamp(self:listen(self.x + 1, self.y) or #self.chars, 1, #self.chars)
  local cap = tostring(grid[self.y][self.x + 1]) and (grid[self.y][self.x + 1] == string.upper(grid[self.y][self.x + 1]) and true) or false
  if b < a then a,b = b,a end
  local val = self.chars[math.random(a,b)]
  local value = cap and string.upper(val) or val
  
  if self:active() then
    grid[self.y + 1][self.x] = value
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = value
  end
  
end

return R