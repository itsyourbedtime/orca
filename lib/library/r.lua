local R = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'random'
  self.info = {'Outputs a random value.', 'in-a', 'in-b', 'rand-out'}

  self.ports = {{-1, 0, 'input'}, { 1, 0, 'input_op'}, {0, 1 , 'output_op'}}
  self:spawn(self.ports)

  local a = util.clamp(self:listen(self.x - 1, self.y) or 0, 0, #self.chars)
  local b = util.clamp(self:listen(self.x + 1, self.y) or #self.chars, 1, #self.chars)
  l = tostring(grid[self.y][self.x + 1])
  local cap = (l and l == self.up(l)) and true or false
  if b < a then a,b = b,a end
  local val = self.chars[math.random(a,b)]
  local value = cap and self.up(val) or val
  
  if self:active() then
    grid[self.y + 1][self.x] = value
  elseif self.banged( self.x, self.y ) then
    grid[self.y + 1][self.x] = value
  end
  
end

return R