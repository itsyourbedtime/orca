local J = function(self, x, y, frame, grid)
  self.name = 'J'
  self.y = y
  self.x = x
  local a = grid[self.y - 1][self.x] ~= nil and grid[self.y - 1][self.x] or 'null'
  if self:active() then
    self:spawn(self.name)
    grid[self.y + 1][self.x] = a
  elseif self.banged(self.x, self.y) then
    grid[self.y + 1][self.x] = a
    if a == self.list[a] then 
      self:add_to_queue(self.x, self.y + 1)
    end
  end
end

return J