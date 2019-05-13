local ops = {}

local XSIZE = 101 
local YSIZE = 33  
local bounds_x = 25
local bounds_y = 8


ops._index = ops

ops["*"] = function(self, x, y, frame, grid)
  self.x = x 
  self.y = y 
  if self:active() then 
    self:erase(self.x, self.y) 
  end
end


ops.A = function (self,x,y,frame, grid)
  self.name = 'A'
  self.y = y
  self.x = x
  local b = tonumber(self:input(x + 1, y, 0)) ~= nil and tonumber(self:input(x + 1, y, 0)) or 0
  local a = tonumber(self:input(x - 1, y, 0))  ~= nil and tonumber(self:input(x - 1, y, 0))  or 0
  local sum
  if (a ~= 0 or b ~= 0) then sum  = self.chars[(a + b)  % (#self.chars+1) ]
  else sum = 0 end
  if self:active() then
    self:spawn(self.ports[self.name])
      grid[y+1][x] = sum
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y+1][x] = sum
    end
  end
end

ops.B = function (self, x,y, frame, grid)
  self.name = 'B'
  self.y = y
  self.x = x
  local to = tonumber(self:input(x + 1, y)) or 1
  local rate = tonumber(self:input(x - 1, y)) or 1
  if to == 0 or to == nil then to = 1 end
  if rate == 0 or rate == nil then rate = 1 end
  local key = math.floor(frame / rate) % (to * 2)
  local val = key <= to and key or to - (key - to)
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y + 1][x] = self.chars[val]
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y + 1][x] = self.chars[val]
    end
  end
end

ops.C  = function (self, x, y, frame, grid)
  self.name = 'C'
  self.y = y
  self.x = x
  local modulus = tonumber(self:input(x + 1, y)) or 9
  local rate = tonumber(self:input(x - 1, y)) or 1
  if modulus == 0 or modulus == nil then modulus = 1 end
  if rate == 0 or rate == nil then rate = 1 end
  local val = (math.floor(frame / rate) % modulus) + 1
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = self.chars[val]
  elseif not self:active() then
    if self.banged(x,y) then
      self:spawn(self.ports[self.name])
      grid[y+1][x] = self.chars[val]
    end
  end
end

ops.D  = function (self, x, y, frame, grid)
  self.name = 'D'
  self.y = y
  self.x = x
  local modulus = tonumber(self:input(x + 1, y)) or 9 -- only int
  local rate = tonumber(self:input(x - 1, y)) or 1 -- only int
  if modulus == 0 then modulus = 1 end
  local val = (frame % (modulus * rate))
  local out = (val == 0 or modulus == 1) and '*' or 'null'
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = out
  elseif not self:active() then
    if self.banged(x,y) then
      self:spawn(self.ports[self.name])
      grid[y+1][x] = out
    end
  end
end

ops.F = function(self, x, y, frame, grid)
  self.name = 'F'
  self.y = y
  self.x = x
  local b = tonumber(self:input(x + 1, y))
  local a = tonumber(self:input(x - 1, y))
  local val = a == b and '*' or 'null'
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = val
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y+1][x] = val
    end
  end
end

ops.H = function(self, x, y, frame, grid)
  self.name = 'H'
  self.y = y
  self.x = x
  local ports = {{0, 1 , 'output'}}
  local a = grid[y - 1][x]
  local existing = grid[y + 1][x] == self.list[grid[y + 1][x]] and grid[y + 1][x] or 'nu'
  if self:active() then
    self:spawn(self.ports[self.name])
  elseif self.banged(x,y) then
    self:spawn(self.ports[self.name])
  end
end

ops.J = function(self, x, y, frame, grid)
  self.name = 'J'
  self.y = y
  self.x = x
  local a = grid[y - 1][x]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y + 1][x] = a
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y + 1][x] = a
    end
  end
end

ops.I = function (self, x, y, frame, grid)
  self.name = 'I'
  self.y = y
  self.x = x
  local a, b
  a = self:input(x - 1, y, 0) 
  b = self:input(x + 1, y, 9)
  a = tonumber(a) or 0
  b = tonumber(b) ~= tonumber(a) and tonumber(b) or tonumber(a) + 1
  if b < a then a,b = b,a end
  val = util.clamp((frame  % math.ceil(b)) + 1,a,b)
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = self.chars[val]
  end
end

ops.W = function(self, x, y, frame, grid)
  self.name = 'W'
  self.x = x
  self.y = y
  if self:active() then
    self:move(-1,0)
  elseif self.banged(x,y) then
    self:move(-1,0)
  end
end

ops.E = function(self, x, y, frame, grid)
  self.name = 'E'
  self.x = x
  self.y = y
  if self:active() then
    self:move(1,0)
  elseif self.banged(x,y) then
    self:move(1,0)
  end
end

ops.N = function(self, x, y, frame, grid)
  self.name = 'N'
  self.x = x
  self.y = y
  if self:active() then
    self:move(0,-1)
  elseif self.banged(x,y) then
    self:move(0,-1)
  end
end

ops.S = function(self, x, y, frame, grid)
  self.name = 'S'
  self.x = x
  self.y = y
  if self:active() then
    self:move(0,1)
  elseif self.banged(x,y) then
    self:move(0,1)
  end
end

ops.O = function(self, x, y, frame, grid)
  self.name = 'O'
  self.y = y
  self.x = x
  self.inputs = {{-1, 0, 'input'}, {-2, 0, 'input'}, {0, 1, 'output'}, {1, 0 , 'input_op'}}
  local a = tonumber(self:input(x - 2, y))  or 1 ----(tonumber(self:input(x -2, y)) == 0 or tonumber(grid[y][x - 2]) == nil) and 1 or tonumber(grid[y][x - 2]) -- x
  local b = tonumber(self:input(x - 1, y))  or 0 -- y
  local offsety = util.clamp(b + y,1,YSIZE)
  local offsetx = util.clamp(a + x,1,XSIZE)
  if self:active() then
    grid[y + 1][x] = grid[offsety][offsetx]
    self:clean_ports(self.ports[self.name], self.x, self.y)
    self.ports[self.name] = self.inputs
    self.ports[self.name][4] = {a, b, 'input'}
    self:spawn(self.ports[self.name])
  end
end

ops.Q = function (self, x, y, frame, grid)
  self.name = 'Q'
  self.y = y
  self.x = x
  self.inputs = {{-3, 0, 'input'}, {-2, 0, 'input'},{-1, 0, 'input'}, {0, 1 , 'output'}}
  local a = tonumber(self:input(x - 3, y)) or 1 -- x
  local b = tonumber(self:input(x - 2, y)) or 0 -- y
  local length = tonumber(self:input(x - 1, y, 0) ) ~= nil and tonumber(self:input(x - 1, y, 0) ) or 0
  local offset = 1
  length = util.clamp(length,1,XSIZE - length)
  local offsety = util.clamp(b + y,1,YSIZE)
  local offsetx = util.clamp(a + x,1,XSIZE)
  if self:active() then
    self:spawn(self.inputs)
    for i = 1, length do
      grid[y + 1][(offsetx  + i) - (length + 1)] = grid[offsety][(offsetx + i) -1]
      self:clean_ports(self.ports[self.name], self.x, self.y)
      self.ports[self.name] = self.inputs
      self.ports[self.name][4 + i] = {(a+i)-1, b, 'input'}
      self:spawn(self.ports[self.name])
    end
  end
end

ops.M  = function (self, x, y, frame, grid)
  self.name = 'M'
  self.y = y
  self.x = x
  local l = tonumber(self:input(x - 1, y, 1)) or 0-- only int
  local m = tonumber(self:input(x + 1, y, 1)) or 0-- only int
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y + 1][x] = self.chars[(l * m) % #self.chars]
  elseif self.banged(x,y) then
    grid[y + 1][x] = self.chars[(l * m) % #self.chars]
  end
end

ops.P = function (self, x, y, frame, grid)
  self.name = 'P'
  self.y = y
  self.x = x
  local length = tonumber(self:input(x - 1, y, 0) ) ~= nil and tonumber(self:input(x - 1, y, 1) ) or 1
  local pos = util.clamp(tonumber(self:input(x - 2, y, 0)) ~= 0 and tonumber(self:input(x - 2, y, 0)) or 1, 1, length)
  local val = grid[y][x + 1]
  length = util.clamp(length, 1, XSIZE - bounds_x)
  if self:active() then
    self:clean_ports(self.ports[self.name], self.x, self.y)
    for i = 1,length do
      grid.params[y + 1][(x + i) - 1 ].dot = true
      grid.params[y + 1][(x + i) - 1 ].op = false
    end
    self.ports[self.name][4] = {((pos or 1)  % (length+1)) - 1, 1, 'output_op'}
    self:spawn(self.ports[self.name])
    grid[y+1][(x + ((pos or 1)  % (length+1))) - 1] = val
  end
  -- cleanups
  for i= length, #self.chars do
    if grid.params[y + 1][(x + i)].dot then
      grid.params[y + 1][(x + i)].dot = false
      grid.params[y + 1][(x + i) ].op = true
    end
  end
end

ops.T = function (self, x, y, frame, grid)
  self.name = 'T'
  self.y = y
  self.x = x
  local length = tonumber(self:input(x - 1, y, 0) ) ~= nil and tonumber(self:input(x - 1, y, 1) ) or 1
  length = util.clamp(length, 1, XSIZE - bounds_x)
  local pos = util.clamp(tonumber(self:input(x - 2, y, 0)) ~= 0 and tonumber(self:input(x - 2, y, 0)) or 1, 1, length)  
  local val = grid[self.y][self.x + util.clamp(pos,1,length)]
  if self:active() then
    grid.params[y+1][x].lit_out  = true
    self:spawn(self.ports[self.name])
    for i = 1,length do
      grid.params[y][(x + i)].dot = true
      grid.params[y][(x + i)].op = false
    end
    -- highliht pos
    
    for l= 1, length do
      if pos == l then
        grid.params[y][(x + l)].cursor = true
      else
        grid.params[y][(x + l)].cursor = false
      end
    end
    grid[y+1][x] = val or '.'
  end
  -- cleanups
  for i= length+1, #self.chars do
    grid.params[y][(x + i)].dot = false
    grid.params[y][(x + i)].op = true
    grid.params[y][(x + i)].cursor = false
  end
end

ops.U  = function (self, x, y, frame, grid)
  self.name = 'U'
  self.y = y
  self.x = x
  local pulses = tonumber(self:input(x + 1, y)) or 1
  local steps = tonumber(self:input(x - 1, y)) or 1
  local pattern = euclid.gen(steps, pulses)
  local pos = (frame  % (pulses ~= 0 and pulses or 1) + 1)
  local out = pattern[pos] and '*' or 'null'
  
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = out
  elseif not self:active() then
    if self.banged(x,y) then
      self:spawn(self.ports[self.name])
      grid[y+1][x] = out
    end
  end
end


ops.V = function (self,x,y,frame, grid)
  self.name = 'V'
  self.y = y
  self.x = x
  local a = tonumber(self:input(x - 1, y, 0))  ~= nil and tonumber(self:input(x - 1, y, 0)) or 0
  local b = tonumber(self:input(x + 1, y, 0)) ~= nil and tonumber(self:input(x + 1, y, 0)) or 0
  if self:active() then
    self:spawn(self.ports[self.name])
    if (b ~= 0 and vars[b] ~= nil and a == 0) then
      if vars[b] ~= nil then
       grid.params[y + 1][x].lit_out = true
       grid[y + 1][x] = vars[b] 
      end 
    elseif self:active() and b ~= 0 and  a ~= 0  then
      vars[a] = grid[y][x + 1]
    else 
      grid.params[y + 1][x].lit_out = false
    end
  elseif not self:active() then
    if self.banged(x,y) then
    end
  end
end

ops.K = function (self, x, y, frame, grid)
  self.name = 'K'
  self.y = y
  self.x = x
  local length = tonumber(self:input(x - 1, y, 0) ) ~= nil and tonumber(self:input(x - 1, y, 0) ) or 0
  local offset = 1
  length = util.clamp(length,0,XSIZE - bounds_x)
  local l_start = x + offset
  local l_end = x + length
  if self:active() then
    self:spawn(self.ports[self.name])
    if length - offset  == 0 then
      for i=2,length do
        grid.params[y][x + i].op = true
      end
    else
      for i = 1,length do
        local var = self:input(x+i,y)
        grid.params[y][(x + i)].dot = true
        grid.params[y+1][(x + i)].dot_port = false
        grid.params[y][(x + i)].op = false
        grid.params[y][(x + i)].act = false
        grid.params[y+1][(x + i)].lit_out = false
        grid.params[y][(x + i)].lit = false
        if vars[var] ~= nil then
          grid.params[y+1][(x + i)].op = false
          grid.params[y + 1][(x + i)].act = false
          grid.params[y+1][(x + i)].lit_out = false
          grid.params[y+2][(x + i)].lit_out = false
          grid.params[y+1][(x + i)].lit = false
          grid[y+1][(x + i)] = vars[var]
        end
      end
      grid.params[y+1][x].dot_port = false
      grid.params[y+1][length + 1].dot_port = false
    end
  end
  -- cleanups
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
        grid.params[y][util.clamp((x + i),1,XSIZE)].dot = false
        grid.params[y][util.clamp((x + i),1,XSIZE)].op = true
        grid.params[y+1][util.clamp((x + i),1,XSIZE)].act = true
    end
  end
end
ops.L = function (self, x, y, frame, grid)
  self.name = 'L'
  self.y = y
  self.x = x
  local length = tonumber(self:input(x - 1, y, 0) ) ~= nil and tonumber(self:input(x - 1, y, 0) ) or 0
  local rate = (tonumber(self:input(x - 2, y, 0) ) == nil or tonumber(self:input(x - 2, y, 0) ) == 0) and 1 or tonumber(self:input(x - 2, y, 0) )
  local offset = 1
  length = util.clamp(length,0,XSIZE - bounds_x)
  local l_start = util.clamp(x + offset, 1, XSIZE - bounds_x)
  local l_end = util.clamp(x + length, 1, XSIZE - bounds_x)
  if self:active() then
    self:spawn(self.ports[self.name])
    if length - offset  == 0 then
      for i=2,length do
        grid.params[y][x + i].op = true
      end
    else
      for i = 1,length do
        grid.params[y][(x + i)].dot = true
        grid.params[y][(x + i)].op = false
        grid.params[y+1][(x + i)].lit_out = false
        grid.params[y][(x + i)].lit = false
      end
    end
  end
  if frame % rate == 0 and length ~= 0 then
    self:shift(offset, length)
  end
  -- cleanups
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
        grid.params[y][(x + i)].dot = false
        grid.params[y][(x + i)].op = true
    end
  end
end

ops.R = function (self, x, y, frame, grid)
  self.name = 'R'
  self.y = y
  self.x = x
  local a, b
  a = self:input(x - 1, y, 1) 
  b = self:input(x + 1, y, 9)
  a = util.clamp(tonumber(a) or 1,0,#self.chars)
  b = util.clamp(tonumber(b) or 9,1,#self.chars)
  if b == 27 and a == 27 then a = math.random(#self.chars) b = math.random(#self.chars) end -- rand 
  if b < a then a,b = b,a end
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y+1][x] = self.chars[math.random((a or 1),(b or 9))]
  end
end

ops.G = function(self, x, y, frame, grid)
  self.name = 'G'
  self.y = y
  self.x = x
  local a = tonumber(self:input(x - 3, y)) or 0 -- x
  local b = util.clamp(self:input(x - 2, y) or 1, 1, #self.chars) -- y
  local length = tonumber(self:input(x - 1, y, 0) ) ~= nil and tonumber(self:input(x - 1, y, 0) ) or 0
  local offset = 1
  length = util.clamp(length,0,XSIZE - length)
  local offsety = util.clamp(b + y,1,YSIZE) 
  local offsetx = util.clamp(a + x,1,XSIZE)
  
  if self:active() then
    self:spawn(self.ports[self.name])
    
    if length == 0 then
      for i=1,length do
        grid.params[y][x + i].op = true
      end
    else
      for i = 1,length do
        grid.params[y][(x + i)].dot = true
        grid.params[y][(x + i)].op = false
        grid.params[y][(x + i)].act = false
        grid.params[y+1][(x + i)].lit_out = false
        grid.params[y][(x + i)].lit = false
      end
    end
    
    
    if length > 0 then
      self:clean_ports(self.ports[self.name], self.x, self.y)
      self.ports[self.name][4] = {a, b, 'output'}
      self:spawn(self.ports[self.name])
    end
    
    
    for i=1,length do
      local existing = grid[self.y][self.x + i] ~= nil and grid[self.y][self.x + i] or 'null'
      if existing == self.list[string.upper(existing)] then
        self:clean_ports(self.ports[string.upper(existing)],  (offsetx + i) - 1, offsety)
      end
      grid[util.clamp(offsety,1, #self.chars)][(offsetx + i) - 1] = grid[self.y][self.x + i]
      self:add_to_queue((offsetx + i) - 1,util.clamp(offsety,1, #self.chars))
    end
  end
  
  -- cleanups 
  if length < #self.chars then
    for i= length == 0 and length or length+1, #self.chars do
      grid.params[y][(x + i)].dot = false
      grid.params[y][(x + i)].op = true
    end
  end
end

ops.X = function(self, x, y, frame, grid)
  self.name = 'X'
  self.y = y
  self.x = x
  local a = tonumber(self:input(x - 2, y)) or 0 -- x
  local b = tonumber(self:input(x - 1, y)) or 1 -- y
  local offsety = util.clamp(b + y,1,YSIZE)
  local offsetx = util.clamp(a + x,1,XSIZE)
  if self:active() then
    self:clean_ports(self.ports[self.name], self.x, self.y)
    self.ports[self.name][4] = {a, b, 'output'}
    self:spawn(self.ports[self.name])
    grid[util.clamp(offsety,1, #self.chars)][offsetx] = grid[y][x+1]
    grid.params[util.clamp(offsety,1, #self.chars)][offsetx].placeholder = grid[y][x+1] ~= '*' and 
    self:add_to_queue(offsetx,util.clamp(offsety,1, #self.chars))
  end
end

ops.Y = function(self, x, y, frame, grid)
  self.name = 'Y'
  self.y = y
  self.x = x
  local a = grid[y][x - 1]
  if self:active() then
    self:spawn(self.ports[self.name])
    grid[y][x + 1] = a
  elseif not self:active() then
    if self.banged(x,y) then
      grid[y][x + 1] = a
    end
  end
end

ops.Z = function (self, x, y, frame, grid)
  self.name = 'Z'
  self.x = x
  self.y = y
  local rate = tonumber(self:input(x - 1, y)) or 1
  local target  = tonumber(self:input(x + 1, y)) or 1
  rate = rate == 0 and 1 or rate
  local val = tonumber(self:input(x, y + 1)) or 0
  local mod = val <= target - rate and rate or val >= target + rate and  -rate  or target - val
  out = self.chars[val + mod]
  if self:active() then
    self:spawn(self.ports[self.name])
      grid[y + 1][x] = out
  end
end

ops["'"] = function (self, x, y, frame, grid)
  self.name = "'"
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local sample = util.clamp(tonumber(self:input(x + 1, y)) ~= nil and tonumber(self:input(x + 1, y)) or 0,0,#self.chars)
  local octave =  util.clamp(tonumber(self:input(x + 2, y)) ~= nil and tonumber(self:input(x + 2, y)) or 0,0,8)
  local vel =  util.clamp(tonumber(self:input(x + 4, y)) ~= nil and tonumber(self:input(x + 4, y)) or 5,0,#self.chars)
  local start =  util.clamp(tonumber(self:input(x + 5, y)) ~= nil and tonumber(self:input(x + 5, y)) or 0,0,16)
  if octave == nil or octave == 'null' then octave = 0 end
  local transposed = self.transpose(self.chars[self:input(x + 3, y)], octave )
  local oct = transposed[4]
  local n = math.floor(transposed[1])
  local velocity = math.floor((vel / #self.chars) * 100)
  local length = params:get("end_frame_" .. sample)
  local start_pos = util.clamp(((start / #self.chars)*2) * length, 0, length)
  params:set("start_frame_" .. sample,start_pos )
  if self.banged(x,y) then
    grid.params[y][x].lit_out = false
    engine.noteOff(sample)
    engine.amp(sample, (-velocity) + 5 )
    engine.noteOn(sample, sample, music.note_num_to_freq(n), 100)
  else
    grid.params[y][x].lit_out = true
    if frame % ( #self.chars  * 4 )== 0 then engine.noteOff(sample) end
  end
end

ops['/'] = function (self, x, y, frame, grid)
  self.name = '/'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  -- bang resets playhead to pos 
  local playhead = util.clamp(tonumber(grid[y][x + 1]) ~= 0 and  tonumber(grid[y][x + 1])  or 1,1,max_sc_self)
  local rec = tonumber(grid[y][x + 2]) or 0 -- rec 0 - off 1 - 9 on + rec_level
  local play = tonumber(grid[y][x + 3]) or 0 -- play 0 - stop  1 - 5 / fwd  6 - 9 rev
  local l =  util.clamp(tonumber(self:input(x + 4, y)) ~= nil and tonumber(self:input(x + 4, y)) or 0,0,#self.chars) -- level 1-z
  local r =  util.clamp(tonumber(self:input(x + 5, y)) ~= nil and tonumber(self:input(x + 5, y)) or 0,0,#self.chars) -- rate  1-z
  local p =  util.clamp(tonumber(self:input(x + 6, y)) ~= nil and tonumber(self:input(x + 6, y)) or 0,0,#self.chars) -- pos  1-z 
  local pos = util.round((p / #self.chars) * #self.chars, 0.1)
  local level = util.round((l / #self.chars) * 1, 0.1)
  local rate = util.round((r / #self.chars) * 2, 0.1)
  if grid[y][x + 2] == '*' then
    grid[y][x + 2] = 'null'
    softcut.buffer_clear_region(0, #self.chars)
  end
  if rec >= 1 then 
    softcut.rec_level(playhead, rec/9) 
    grid.params[y][x].lit_out = true 
  else 
    grid.params[y][x].lit_out = false 
    end
  if play > 5 then
    rate = -rate 
  end
  if play > 0 then
    softcut.play(playhead,play)
    softcut.rec(playhead,rec)
    softcut.rate(playhead,rate)
    softcut.level(playhead, level)
  else
    softcut.play(playhead,play)
  end
  if self.banged(x,y) then
    grid.params[y][x].lit_out = false
    if play ~= 0 then
      softcut.position(playhead,pos)
    end
  else 
    grid.params[y][x].lit_out = true
  end
end

ops[':'] = function (self, x, y, frame, grid)
  self.name = ':'
  self.y = y
  self.x = x
  self:spawn(self.ports[self.name])
  local note = 'C'
  local channel = util.clamp(tonumber(self:input(x + 1, y)) ~= nil and tonumber(self:input(x + 1, y)) or 0,0,16)
  local octave =  util.clamp(tonumber(self:input(x + 2, y)) ~= nil and tonumber(self:input(x + 2, y)) or 0,0,8)
  local vel =  util.clamp(tonumber(self:input(x + 4, y)) ~= nil and tonumber(self:input(x + 4, y)) or 0,0,16)
  local length =  util.clamp(tonumber(self:input(x + 5, y)) ~= nil and tonumber(self:input(x + 5, y)) or 0,0,16)
  if octave == nil or octave == 'null' then octave = 0 end
  local transposed = self.transpose(self.chars[self:input(x + 3, y)], octave )
  local oct = transposed[4]
  local n = math.floor(transposed[1])
  local velocity = math.floor((vel / 16) * 127)
  if self.banged(x,y) then
    all_notes_off(channel)
    grid.params[y][x].lit_out = false
    midi_out_device:note_on(n, velocity, channel)
    table.insert(active_notes, n)
    notes_off_metro:start((60 / clk.bpm / clk.steps_per_beat / 4) * length, 1)
  else
    grid.params[y][x].lit_out = true
  end
end

ops['\\'] = function (self, x, y, frame, grid)
  self.name = '\\'
  self.y = y
  self.x = x
  local rate = tonumber(self:input(x - 1, y)) == 0 and 1 or tonumber(self:input(x - 1, y)) or 1
  local scale = tonumber(self:input(x + 1, y)) == 0 and 60 or tonumber(self:input(x + 1, y)) or 60
  local mode = util.clamp(scale, 1, #music.SCALES)
  local scales = music.generate_scale_of_length(60,music.SCALES[mode].name,12)
  if self:active() then
    self:spawn(self.ports[self.name])
    if frame % rate == 0 then
      grid[y+1][x] =  self.notes[util.clamp(scales[math.random(#scales)] - 60, 1, 12)]
    end
  end
end

return ops
