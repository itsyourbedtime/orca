local U = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "uclid"
  self.ports = { {-1, 0, "in-max"},  { 1, 0, "in-step"}, {0, 1, "u-out"} }
  self:spawn(self.ports)

  local max = self:listen(self.x - 1, self.y) or 1
  local steps = self:listen(self.x + 1, self.y) or 8
  local pos = max > 0 and (self.frame % (steps == 0 and 1 or steps) + 1) or 0
  local pattern = self:gen_pattern(max, steps)
  local out = pattern[pos] and "*" or "."

  self:write(0, 1, out)
end

return U