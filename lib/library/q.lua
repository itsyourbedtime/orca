local Q = function (self, x, y, glyph)

  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'query'
  self.info = 'Reads distant operators with offset.'
  
  self.ports = {
    {-3, 0, 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'}, 
    {0, 1, 'output'} 
  }

  local a = self:listen(self.x - 3, self.y) or 1 -- x
  local b = self:listen(self.x - 2, self.y) or 0 -- y
  local length = self:listen(self.x - 1, self.y, 0) or 1
  local offset = 1
  length = util.clamp(length,1, self.XSIZE - length)
  local offsety = util.clamp(b + self.y, 1, self.YSIZE)
  local offsetx = util.clamp(a + self.x, 1, self.XSIZE)
  self.data.cell.params[self.y][self.x].spawned.seq = length
    
    for i = 1, length do
        table.insert(self.ports, { (b + i) - 1 , a , 'in-q',  'haste' })
    end
  
  if not self.passive then
    self.cleanup(self.x, self.y)
    self:spawn(self.ports)
  end
end
--[[  if not self.passive then
    self:spawn(self.ports)
    for y = 1, #self.chars do
      for x = 1, #self.chars do
        if (x <= length and y <= length) then
          self.lock((offsetx + x) - 1, offsety, false, false, true)
        else
          if not self.locked((offsetx + x) - 1, offsety) and self:active((offsetx + x) - 1, offsety) then 
            break
          else
            self.unlock((offsetx + x) - 1, offsety, false, false, false)
          end
        end
      end
    end
  end
  
end]]
    
    --[[for i = 1, #self.chars do
      if i <= length then
        self.lock((offsetx + i) -1, offsety, false, true)
        self.data.cell[self.y + 1][(offsetx  + i) - (length + 1)] = self.data.cell[offsety][(offsetx + i) -1]
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
      self.data.cell[self.y + 1][(offsetx  + i) - (length + 1)] = self.data.cell[offsety][(offsetx + i) -1]
      --self:clean_ports(self.x, self.y)
      self.ports[self.name] = self.inputs
      self.ports[self.name][4 + i] = {(a+i)-1, b, 'input'}
      self:spawn(self.name)
    end
  end
]]
--end


return Q