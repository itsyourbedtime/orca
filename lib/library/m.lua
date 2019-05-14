M  = function (self, x, y, frame, grid)
  self.name = 'M'
  self.y = y
  self.x = x
  local l = self:input(x - 1, y, 1) or 0
  local m = self:input(x + 1, y, 1) or 0
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y + 1][x] = self.chars[(l * m) % #self.chars]
  elseif self.banged(x,y) then
    grid[y + 1][x] = self.chars[(l * m) % #self.chars]
  end
end

return M