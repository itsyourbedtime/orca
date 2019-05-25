 local controls = {}
 
function controls.get_key(code, val, shift)
  if keycodes.keys[code] ~= nil and val == 1 then
    if shift then
      if keycodes.shifts[code] ~= nil then
        return keycodes.shifts[code]
      else
        return keycodes.keys[code]
      end
    else
      return string.lower(keycodes.keys[code])
    end
  end
end
 
function controls:event(typ, code, val)
  local menu = norns.menu.status()
   --print("hid.event ", typ, code, val)
  if ((code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 1 or val == 2)) then
    shift  = true;
  elseif (code == hid.codes.KEY_LEFTSHIFT or code == hid.codes.KEY_RIGHTSHIFT) and (val == 0) then
    shift = false;
    elseif ((code == hid.codes.KEY_LEFTCTRL or code == hid.codes.KEY_RIGHTCTRL) and (val == 1 or val == 2)) then
    ctrl = true
  elseif ((code == hid.codes.KEY_LEFTCTRL or code == hid.codes.KEY_RIGHTCTRL) and val == 0) then
    ctrl = false
  elseif ((code == hid.codes.KEY_LEFTMETA or code == hid.codes.KEY_RIGHTMETA ) and (val == 1 or val == 2)) then
    ctrl = true
  elseif ((code == hid.codes.KEY_LEFTMETA or code == hid.codes.KEY_RIGHTMETA ) and val == 0) then
    ctrl = false
  elseif (code == hid.codes.KEY_BACKSPACE or code == hid.codes.KEY_DELETE) then
    self:erase(self.x_index,self.y_index)
  elseif (code == hid.codes.KEY_LEFT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x -  (ctrl and 9 or 1) ,1,self.XSIZE) else
        self.x_index = util.clamp(self.x_index - (ctrl and 9 or 1), 1,self.XSIZE)
      end
      update_offset()
    elseif menu then
      norns.enc(3, shift and -20 or -2)
    end
  elseif (code == hid.codes.KEY_RIGHT) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_x = util.clamp(selected_area_x + (ctrl and 9 or 1), 1,self.XSIZE) else
        self.x_index = util.clamp(self.x_index + (ctrl and 9 or 1), 1,self.XSIZE)
      end
      update_offset()
    elseif menu then
      norns.enc(3, shift and 20 or 2)
    end
  elseif (code == hid.codes.KEY_DOWN) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y + (ctrl and 9 or 1), 1,self.YSIZE) else
        self.y_index = util.clamp(self.y_index + (ctrl and 9 or 1), 1,self.YSIZE)
      end
      update_offset()
    elseif menu then
      norns.enc(2, shift and 104 or 2)
    end
  elseif (code == hid.codes.KEY_UP) and (val == 1 or val == 2) then
    if not menu then
      if shift then selected_area_y = util.clamp(selected_area_y - (ctrl and 9 or 1), 1,self.YSIZE) else
        self.y_index = util.clamp(self.y_index - (ctrl and 9 or 1) ,1,self.YSIZE)
      end
      update_offset()
    elseif menu then
     norns.enc(2, shift and -104 or -2)
    end
  elseif (code == hid.codes.KEY_TAB and val == 1) then
    bar = not bar
  elseif (code == 41 and val == 1) then
    help = not help
  -- bypass crashes  -- 2do F1-F12 (59-68, 87,88)
  elseif (code == 26 and val == 1) then
    dot_density = util.clamp(dot_density - 1, 1, 8)
  elseif (code == 27 and val == 1) then
    dot_density = util.clamp(dot_density + 1, 1, 8)
  elseif (code == hid.codes.KEY_102ND and val == 1) then
  elseif (code == hid.codes.KEY_ESC and (val == 1 or val == 2)) then
        selected_area_y, selected_area_x = 1, 1
      if menu and shift then
        norns.key(1, 1)
      elseif menu and not shift then
        norns.key(2, 1)
      end
  elseif (code == hid.codes.KEY_ENTER and val == 1) then
    if menu then
      norns.key(3, 1)
    end
  elseif (code == hid.codes.KEY_LEFTALT and val == 1) then
  elseif (code == hid.codes.KEY_RIGHTALT and val == 1) then
  elseif (code == hid.codes.KEY_DELETE and val == 1) then
  elseif (code == hid.codes.KEY_CAPSLOCK and val == 1) then
     map = not map
  elseif (code == hid.codes.KEY_NUMLOCK and val == 1) then
  elseif (code == hid.codes.KEY_SCROLLLOCK and val == 1) then
  elseif (code == hid.codes.KEY_SYSRQ and val == 1) then
  elseif (code == hid.codes.KEY_HOME and val == 1) then
  elseif (code == hid.codes.KEY_PAGEUP and val == 1) then
  elseif (code == hid.codes.KEY_DELETE and val == 1) then
  elseif (code == hid.codes.KEY_END and val == 1) then
  elseif (code == hid.codes.KEY_PAGEUP and val == 1) then
  elseif (code == hid.codes.KEY_PAGEDOWN and val == 1) then
  elseif (code == hid.codes.KEY_INSERT and val == 1) then
  elseif (code == hid.codes.KEY_END and val == 1) then
  elseif (code == hid.codes.KEY_RIGHTMETA and val == 1) then
  elseif (code == hid.codes.KEY_COMPOSE and val == 1) then
  elseif (code == 119 and val == 1) then
  elseif ((code == 88 or code == 87) and val == 1) then
  elseif (code == hid.codes.KEY_SPACE) and (val == 1) then
    if self.clock.playing then
      self.clock:stop()
      engine.noteKillAll()
      for i=1, self.max_sc_ops do
        softcut.play(i,0)
      end
    else
      frame = 0
      self.clock:start()
    end
  else
    if val == 1 then
      keyinput = controls.get_key(code, val, shift)
      if not ctrl then
        if self.operate(self.x_index,self.y_index) and keyinput ~= field.cell[self.y_index][self.x_index] then
          self:erase(self.x_index,self.y_index)
          if field.cell[self.y_index][self.x_index] == '/' then
            self.sc_ops = util.clamp(self.sc_ops - 1, 1, self.max_sc_ops)
          end
        elseif keyinput == 'H' then
        end
        field.cell[self.y_index][self.x_index] = keyinput
        self:add_to_queue(self.x_index, self.y_index)
      end
      if ctrl then
        if code == 45 then -- cut
          self.cut_area()
        elseif code == 46 then -- copy
          self.copy_area()
        elseif code == 47 then -- paste
          self.paste_area()
        end
      end
    end
  end
end

return controls