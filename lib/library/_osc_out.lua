local osc_out = function ( self, x, y, frame, grid )
  self.x = x
  self.y = y
  
  self.glyph = '='
  self.name = 'osc'
  self.info = "Sends OSC message."
  self.passive = false

  self.ports = {{1,0, 'osc-path', 'input'}}
  local osc_path = {}
  for x = x + 1, 35 do
    self.ports[#self.ports + 1] = { x - self.x  , 0, 'osc-path',  'input' }
    if self.data.cell[self.y][x] == '.' or not self.op(x, self.y) then 
      self.ports[#self.ports] = nil  
      break
    end
  end
  
  self:spawn(self.ports)
    for i = 1, #self.ports - 2  do
      osc_path[i] = self.data.cell[self.y][self.x + i]
    end
    
    
  if self:banged() then
    print(table.concat(osc_path))
  end
end

return osc_out