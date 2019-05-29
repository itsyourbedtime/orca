local H = function(self, x, y, glyph)
  
  self.y = y
  self.x = x
  
  self.glyph = glyph
  self.passive = glyph == string.lower(glyph) and true 
  self.name = 'halt'
  self.info = 'Stops southward operator from operating.'

  self.ports = {
    {0, 1, 'h-output', 'output'}
  }

  if not self.passive then
    self:spawn(self.ports)
    self.lock(self.x, self.y + 1, false, false,  true)
  elseif self:banged() then
    self.lock(self.x, self.y + 1, false,  true, true)
  else
    self.unlock(self.x, self.y + 1,false, false, false)
  end
  
end

return H