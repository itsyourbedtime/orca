local midi_in = function ( self, x, y )
  
  self.y = y
  self.x = x  
  self.name = 'midi in'
  self.ports = { {0, 1, 'midi-in' } }
  self:spawn(self.ports)
  
  local note = self.vars['midi'] or 1
  local out =  self.chars[ note % 35] 

  self:write(0, 1, out )
  
end

return midi_in