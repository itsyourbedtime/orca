local osc_out = function ( self, x, y, frame, grid )
  
  self.x = x
  self.y = y
  
  self.glyph = '='
  self.name = 'osc'
  self.info = "Sends OSC message."
  self.passive = false
  self.ports = {{1,0, 'osc-path', 'input'}}
  
  local osc_dest = { '127.0.0.1', 10111 } 
  local osc_path = { }
  
  for x = x + 2, 35 do self.ports[#self.ports + 1] = { x - self.x, 0, 'osc-path',  'input' }
  if self:glyph_at(x, self.y) == '.' then break end end
  for i = 1, #self.ports  do l = self:glyph_at(self.x + i, self.y) osc_path[i] = l  == '.' and '' or l end
  local concat_path = table.concat(osc_path) local values = tab.split(concat_path, ';')
  concat_path = values[1] values[1] = nil
  
  self:spawn(self.ports)
  if self:neighbor(self.x, self.y, '*') then
    osc.send(osc_dest, '/' .. concat_path, values)
  end
end

return osc_out