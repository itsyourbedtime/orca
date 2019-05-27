local comment = function ( self, x, y )
  
  self.x = x
  self.y = y
  
  self.glyph = '#'
  self.name = 'comment'
  self.info = 'Halts a line.'
  self.passive = false
  
  self.data.cell.params[self.y][self.x].spawned.info = { self.name, self.glyph }
  
  for x = x + 1, self.XSIZE do
    self.lock(x, y, false, false, true )
    self.data.cell.params[self.y][self.x].spawned.seq = x
    if self.data.cell[y][x] == '#' then
      for c = x + 1, self.XSIZE - x do
        if (self.op(c , y) ) then
          break 
        else
          self.unlock(c, y, false, false, false)
        end
      end
    break
    else
      
    end
  end
end

return comment
