obs = obslua

source_name = "Dashboard Feed"
source_url = "http://127.0.0.1:8080/dashboard"
source_width = 1280
source_height = 720

function script_description()
  return [[
Creates or updates an OBS Browser Source that points to the Media_webcam dashboard.
This is a lightweight OBS script alternative to a compiled plugin.

How to use:
1) Start your Media_webcam server.
2) In OBS: Tools -> Scripts -> + -> select this file.
3) Click "Create / Update Browser Source".
4) The source appears in the current scene as a browser source with audio enabled.
]]
end

function script_properties()
  local props = obs.obs_properties_create()

  obs.obs_properties_add_text(props, "source_name", "Source name", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_text(props, "source_url", "Dashboard URL", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_int(props, "source_width", "Width", 320, 3840, 1)
  obs.obs_properties_add_int(props, "source_height", "Height", 180, 2160, 1)
  obs.obs_properties_add_button(props, "create_source", "Create / Update Browser Source", create_or_update_source)

  return props
end

function script_defaults(settings)
  obs.obs_data_set_default_string(settings, "source_name", source_name)
  obs.obs_data_set_default_string(settings, "source_url", source_url)
  obs.obs_data_set_default_int(settings, "source_width", source_width)
  obs.obs_data_set_default_int(settings, "source_height", source_height)
end

function script_update(settings)
  source_name = obs.obs_data_get_string(settings, "source_name")
  source_url = obs.obs_data_get_string(settings, "source_url")
  source_width = obs.obs_data_get_int(settings, "source_width")
  source_height = obs.obs_data_get_int(settings, "source_height")
end

function create_or_update_source(props, property)
  local source = obs.obs_get_source_by_name(source_name)

  local settings = obs.obs_data_create()
  obs.obs_data_set_string(settings, "url", source_url)
  obs.obs_data_set_int(settings, "width", source_width)
  obs.obs_data_set_int(settings, "height", source_height)
  obs.obs_data_set_bool(settings, "reroute_audio", true)
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
