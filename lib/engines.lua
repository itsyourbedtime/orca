local fileselect = require "fileselect"

local fm7 = include("lib/engines/_fm7")
local passersby = include("lib/engines/_passersby")
local polyperc = include("lib/engines/_polyperc")
local timber = include("lib/engines/_timber")
local macroB = include("lib/engines/_macroB")
local macroP = include("lib/engines/_macroP")

engine.name = "Timber"

--- Softcut only supports max. 2 mono samples
local NUM_SAMPLES = 2

local engines = {
  change_init = false,
  engine_list = {"FM7", "Passersby", "PolyPerc", "Timber","MacroB","MacroP"},
  self = nil,
}

local function unrequire_(name)
  package.loaded[name] = nil
  _G[name] = nil
end

local function engine_loaded_()
  print(engine.is_loading)
  engines.change_init = false
  engines.get_synth().init(engines.self)
end

--- Check if engine is installed.
local function is_engine_installed_(name)
  if #engine.names == 0 or tab.contains(engine.names, name) == true then
    return true
  else
    -- norns.scripterror("missing " .. name)
    print(name .. "isn't loaded")
    return false
  end
end

--- Loads selected engine.
local function load_engine_(index)
  local name = engines.engine_list[index]

  engines.change_init = true

  if engine.is_loading then
    print("'" .. name .. "'" .. " engine is already loading...")
  else
    if is_engine_installed_(name) then
      engine.load(name, engine_loaded_)
      -- engine.name = name
    end
  end
end

function engines.load_folder(file, add)
  local sample_id = 0
  local split_at = string.match(file, "^.*()/")
  local folder = string.sub(file, 1, split_at)
  file = string.sub(file, split_at + 1)

  if add then
    for i = timber.num_samples - 1, 0, -1 do
      if timber.lib.samples_meta[i].num_frames > 0 then
        sample_id = i + 1
        break
      end
    end
  end

  timber.lib.clear_samples(sample_id, timber.num_samples - 1)
  -- softcut.buffer_clear()

  local found = false
  for k, v in ipairs (fileselect.list) do
    if v == file then found = true end
    if found then
      if sample_id > (timber.num_samples - 1) then
        print("Max files loaded")
        break
      end
      -- Check file type
      local lower_v = v:lower()
      if string.find(lower_v, ".wav") or string.find(lower_v, ".aif") or string.find(lower_v, ".aiff") then
        print("Loading samples", folder .. v, sample_id, audio.file_info(folder .. v))
        timber.lib.load_sample(sample_id, folder .. v)
        params:set("play_mode_" .. sample_id, 4)
        -- softcut.buffer_read_mono(folder .. v, 0, 1, -1, 1, sample_id)
        sample_id = sample_id + 1
      else
        print("Skipped", v)
      end
    end
  end
end

function engines.add_params()
  params:add_separator("ENGINE")

  params:add_number("engine_name_index", "engine_name_index", 1, #engines.engine_list, 4)
  params:set_action("engine_name_index", function(val)
      load_engine_(val)
    end)
  params:hide("engine_name_index")

  for index, name in ipairs(engines.engine_list) do
    if is_engine_installed_(name) then
      params:add_trigger("engine_name_" .. name, "Activate " .. name .. " engine")
      params:set_action("engine_name_" .. name, function()
        params:set("engine_name_index", index)
      end)
    end
  end

  params:add_trigger("load_t", "+ Load Timber samples")
  params:set_action("load_t", function()
    timber.lib.FileSelect.enter(_path.audio,  function(file)
      if file ~= "cancel" then
        engines.load_folder(file, add)
      end
    end)
  end)
  timber.lib.add_params()
  for i = 0, timber.num_samples - 1 do
    local extra_params = {
      {
        type = "option",
        id = "launch_mode_" .. i,
        name = "Launch Mode",
        options = {"Gate", "Toggle"},
        default = 1,
        action = function(val)
          timber.lib.setup_params_dirty = true
        end
      },
    }
    params:add_separator()
    timber.lib.add_sample_params(i, true, extra_params)
    --params:set('play_mode_' .. i, 4)
    --params:set('amp_env_sustain_' .. i, 0)
  end
end

function engines.get_synth()
  if string.lower(engine.name) == "fm7" then return fm7
  elseif string.lower(engine.name) == "passersby" then return passersby
  elseif string.lower(engine.name) == "polyperc" then return polyperc
  elseif string.lower(engine.name) == "timber" then return timber
  elseif string.lower(engine.name) == "macrob" then return macroB
  elseif string.lower(engine.name) == "macrop" then return macroP
  end
end

function engines.init(self)
  engines.self = self

  --- softcut
  softcut.reset()
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  audio.level_tape_cut(1)

  for i = 1, 6 do
    softcut.level(i,1)
    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
    softcut.pan(i, 0)
    softcut.play(i, 0)
    softcut.rate(i, 1)
    softcut.loop_start(i, 0)
    softcut.loop_end(i, 36)
    softcut.loop(i, 0)
    softcut.rec(i, 0)
    softcut.fade_time(i, 0.02)
    softcut.level_slew_time(i, 0.01)
    softcut.rate_slew_time(i, 0.01)
    softcut.rec_level(i, 1)
    softcut.pre_level(i, 1)
    softcut.position(i, 0)
    softcut.buffer(i,1)
    softcut.enable(i, 1)
    softcut.filter_dry(i, 1)
    softcut.filter_fc(i, 0)
    softcut.filter_lp(i, 0)
    softcut.filter_bp(i, 0)
    softcut.filter_rq(i, 0)
  end
end

return engines