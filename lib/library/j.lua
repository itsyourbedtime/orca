local J = function(self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'jumper'
  self.name = {'Outputs the northward operator.', 'jymper-in', 'jymper-out'}

  self.ports = {{0, -1, 'input'}, {0, 1, 'output_op'}}
  self:spawn(self.ports)

  if self:active() then
    grid[self.y + 1][self.x] = grid[self.y - 1][self.x]
  elseif self.banged(self.x, self.y) then
    grid[self.y + 1][self.x] = grid[self.y - 1][self.x]
    if self.op(self.x, self.y + 1) then 
      self:add_to_queue(self.x, self.y + 1)
    end
  end
  
end

return J