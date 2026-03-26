obs = obslua

source_name = "Dashboard Feed"
base_url = "http://127.0.0.1:8080/obs"
device_index = 0
cycle_enabled = false
cycle_ms = 10000
source_width = 1280
source_height = 720

function build_url()
  local cycle_flag = cycle_enabled and "1" or "0"
  return string.format("%s?index=%d&cycle=%s&cycleMs=%d", base_url, device_index, cycle_flag, cycle_ms)
end

function script_description()
  return [[
Creates or updates an OBS Browser Source for Media_webcam OBS feed.

Supports:
- Device index selection (0 = first phone, 1 = second, ...)
- Optional auto-cycle through connected devices
]]
end

function script_properties()
  local props = obs.obs_properties_create()

  obs.obs_properties_add_text(props, "source_name", "Source name", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_text(props, "base_url", "OBS base URL", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_int(props, "device_index", "Device index", 0, 64, 1)
  obs.obs_properties_add_bool(props, "cycle_enabled", "Auto-cycle devices")
  obs.obs_properties_add_int(props, "cycle_ms", "Cycle interval (ms)", 1000, 60000, 500)
  obs.obs_properties_add_int(props, "source_width", "Width", 320, 3840, 1)
  obs.obs_properties_add_int(props, "source_height", "Height", 180, 2160, 1)
  obs.obs_properties_add_button(props, "create_source", "Create / Update Browser Source", create_or_update_source)

  return props
end

function script_defaults(settings)
  obs.obs_data_set_default_string(settings, "source_name", source_name)
  obs.obs_data_set_default_string(settings, "base_url", base_url)
  obs.obs_data_set_default_int(settings, "device_index", device_index)
  obs.obs_data_set_default_bool(settings, "cycle_enabled", cycle_enabled)
  obs.obs_data_set_default_int(settings, "cycle_ms", cycle_ms)
  obs.obs_data_set_default_int(settings, "source_width", source_width)
  obs.obs_data_set_default_int(settings, "source_height", source_height)
end

function script_update(settings)
  source_name = obs.obs_data_get_string(settings, "source_name")
  base_url = obs.obs_data_get_string(settings, "base_url")
  device_index = obs.obs_data_get_int(settings, "device_index")
  cycle_enabled = obs.obs_data_get_bool(settings, "cycle_enabled")
  cycle_ms = obs.obs_data_get_int(settings, "cycle_ms")
  source_width = obs.obs_data_get_int(settings, "source_width")
  source_height = obs.obs_data_get_int(settings, "source_height")
end

function create_or_update_source(props, property)
  local source = obs.obs_get_source_by_name(source_name)

  local settings = obs.obs_data_create()
  obs.obs_data_set_string(settings, "url", build_url())
  obs.obs_data_set_int(settings, "width", source_width)
  obs.obs_data_set_int(settings, "height", source_height)
  obs.obs_data_set_bool(settings, "reroute_audio", false)
  obs.obs_data_set_bool(settings, "shutdown", true)
  obs.obs_data_set_int(settings, "fps", 30)

  if source == nil then
    source = obs.obs_source_create("browser_source", source_name, settings, nil)
    if source ~= nil then
      local scene_source = obs.obs_frontend_get_current_scene()
      if scene_source ~= nil then
        local scene = obs.obs_scene_from_source(scene_source)
        obs.obs_scene_add(scene, source)
        obs.obs_source_release(scene_source)
      end
    end
  else
    obs.obs_source_update(source, settings)
  end

  if source ~= nil then
    obs.obs_source_release(source)
  end

  obs.obs_data_release(settings)

  return true
end
