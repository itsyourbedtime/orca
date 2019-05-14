A = function (self,x,y,frame, grid)
  self.name = 'A'
  self.y = y
  self.x = x
  local b = self:input(x + 1, y, 0) or 0
  local a = self:input(x - 1, y, 0) or 0
  local sum
  if (a ~= 0 or b ~= 0) then sum  = self.chars[(a + b)  % (#self.chars+1) ]
  else sum = 0 end
  if self:active() then
    self:spawn(self.ports[self.name])
      grid[y+1][x] = sum
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y+1][x] = sum
    end
  end
end

return A