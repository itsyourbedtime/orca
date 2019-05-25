local Q = function (self, x, y, frame, grid)

  self.y = y
  self.x = x

  self.name = 'query'
  self.info = 'Reads distant operators with offset.'

  self.ports = {{-3, 0, 'input'}, {-2, 0, 'input'},{-1, 0, 'input'}, {0, 1 , 'output'}}
  self:spawn(self.ports)
  
  local a = self:listen(self.x - 3, self.y) or 1 -- x
  local b = self:listen(self.x - 2, self.y) or 0 -- y
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp(length,1, self.XSIZE - length)
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  
  if self:active() then
    for y = 1, #self.chars do
      for x = 1, #self.chars do
        if (x <= length and y <= length) then
          self.lock((offsetx + x) - 1, offsety, false, true)
        else
          if self.operate((offsetx + x) - 1, offsety) and self:active((offsetx + x) - 1, offsety) then 
            break
          else
            self.unlock((offsetx + x) - 1, offsety, false)
          end
        end
      end
    end
  end
  
end
    
    --[[for i = 1, #self.chars do
      if i <= length then
        self.lock((offsetx + i) -1, offsety, false, true)
        grid[self.y + 1][(offsetx  + i) - (length + 1)] = grid[offsety][(offsetx + i) -1]
        self.unlock((offsetx  + i) - (length + 1), self.y + 1 , false)
      else
        --if self.operate((self.x + i) + 1, self.y + 1) and self:active((self.x + i) + 1, self.y + 1) then 
          --break
        --selse
        self.unlock((offsetx + i) -1, offsety, false) 
        --end
      end
    end]]

--[[    for i = 1, length do
      grid[self.y + 1][(offsetx  + i) - (length + 1)] = grid[offsety][(offsetx + i) -1]
      --self:clean_ports(self.x, self.y)
      self.ports[self.name] = self.inputs
      self.ports[self.name][4 + i] = {(a+i)-1, b, 'input'}
      self:spawn(self.name)
    end
  end
]]
--end


return Q