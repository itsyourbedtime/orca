local comment = function ( self, x, y )
  
  self.x = x
  self.y = y
  self.name = 'comment'
  for x = self.x + 1, self.w do
    self:lock(  x, self.y, true, true)
    if self:glyph_at(x, y) == '#' then  
      break 
    end
  end
  
end

return comment
