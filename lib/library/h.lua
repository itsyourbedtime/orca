H = function(self, x, y, frame, grid)
  self.name = 'H'
  self.y = y
  self.x = x
  local ports = {{0, 1 , 'output'}}
  local a = grid[y - 1][x]
  local existing = grid[y + 1][x] == self.list[grid[y + 1][x]] and grid[y + 1][x] or 'null'
  if self:active() then
    self:spawn(self.ports[self.name])
  elseif self.banged(x,y) then
    self:spawn(self.ports[self.name])
  end
end

return H