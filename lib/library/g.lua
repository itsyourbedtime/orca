local G = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'generator'
  self.info = {'Writes distant operators with offset.', 'in-y', 'in-x'}
  
  self.ports = {
   {-3, 0 , 'in-y', 'haste'}, {-2, 0, 'in-x', 'haste'}, {-1, 0, 'in-length', 'haste'}
  }
  
  
  local a = self:listen(self.x - 3, self.y) or 0 -- x
  local b = self:listen(self.x - 2, self.y) or 1 -- y
  local length = self:listen(self.x - 1, self.y, 0) or 0
  local offset = 1
  length = util.clamp( length, 0, self.XSIZE - length)
  local offsety = util.clamp( b + self.y, 1, self.YSIZE) 
  local offsetx = util.clamp( a + self.x, 1, self.XSIZE)
  
  self.data.cell.params[self.y][self.x].spawned.seq = length
  self.data.cell.params[self.y][self.x].spawned.offsets = {offsetx, offsety}

  if not self.passive then
    self:spawn(self.ports)
  
    for i = 1, #self.chars do
      if i <= length then
        self.lock( self.x + i, self.y, false,  false, true )
        self.data.cell[offsety][offsetx + i] = self.data.cell[self.y][self.x + i]
        self.unlock( offsetx + i, offsety ,false, false, false)
      else
        if not self.locked((self.x + i), self.y) then 
          break
        else
          self.unlock(self.x + i, self.y, false, false, false)
        end
      end
    end
  elseif self:banged() then
    for i=1,length do
      self.data.cell[util.clamp(offsety,1, #self.chars)][offsetx + i] = self.data.cell[self.y][self.x + i]
      self.unlock( offsetx + i, offsety , false, false, false )
    end
  end
  
end

return G