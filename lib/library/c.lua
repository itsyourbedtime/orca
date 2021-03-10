local C = function(self, x, y)
  self.y = y
  self.x = x
  self.name = "clock"
  self.ports = { {-1, 0 , "in-rate"},  {1, 0, "in-mod"}, {0, 1, "c-out"} }
  self:spawn(self.ports)

  local mod = self:listen(self.x + 1, self.y) or 9
  local rate = self:listen(self.x - 1, self.y) or 1

  mod = mod == 0 and 1 or mod
  rate = rate == 0 and 1 or rate

  local val = (math.floor(self.frame / rate) % mod) + 1

  self:write(0, 1, self.chars[val])
end

return C