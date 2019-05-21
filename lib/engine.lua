local orca_engine = {}
local NUM_SAMPLES = 36

function unrequire(name)
  package.loaded[name] = nil
  _G[name] = nil
end

unrequire("timber/lib/timber_engine")

engine.name = "Timber"

local Timber = require "timber/lib/timber_engine"


function orca_engine.load_folder(file, add)
  local sample_id = 0
  if add then
    for i = NUM_SAMPLES - 1, 0, -1 do
      if Timber.samples_meta[i].num_frames > 0 then
        sample_id = i + 1
        break
      end
    end
  end
  local split_at = string.match(file, "^.*()/")
  local folder = string.sub(file, 1, split_at)
  file = string.sub(file, split_at + 1)
  local found = false
  for k, v in ipairs(Timber.FileSelect.list) do
    if v == file then found = true end
    if found then
      if sample_id > 35 then
        print("Max files loaded")
        break
      end
      -- Check file type
      local lower_v = v:lower()
      if string.find(lower_v, ".wav") or string.find(lower_v, ".aif") or string.find(lower_v, ".aiff") then
        params:set("sample_" .. sample_id, folder .. v)
        params:set('amp_env_sustain_' .. sample_id, 0)
        sample_id = sample_id + 1
      else
        print("Skipped", v)
      end
    end
  end
end



function orca_engine.init()
  params:add_trigger('load_f','Load Folder')
  params:set_action('load_f', function() Timber.FileSelect.enter(_path.audio, function(file)
  if file ~= "cancel" then orca_engine.load_folder(file, add) end end) end)
  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.options.PLAY_MODE_STREAMING_DEFAULT = 3
  params:add_separator()
  Timber.add_params()
  for i = 0, NUM_SAMPLES - 1 do
    local extra_params = {
      {type = "option", id = "launch_mode_" .. i, name = "Launch Mode", options = {"Gate", "Toggle"}, default = 1, action = function(value)
        Timber.setup_params_dirty = true
      end},
    }
    params:add_separator()
    Timber.add_sample_params(i, true, extra_params)
    params:set('play_mode_' .. i, 4)
    params:set('amp_env_sustain_' .. i, 0)
  end
end


return orca_engine