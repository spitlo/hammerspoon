local grid = require 'modules.grid'
-- local clipboard = require 'modules.clipboard'
local log = hs.logger.new('init', 'verbose')

local hyper = { 'shift', 'cmd', 'alt', 'ctrl' }
local speaker_device = 'Built-in Output'
local headphone_device = 'DisplayPort'


----------------------------------
--       __  __________    ____  __________  _____
--      / / / / ____/ /   / __ \/ ____/ __ \/ ___/
--     / /_/ / __/ / /   / /_/ / __/ / /_/ /\__ \
--    / __  / /___/ /___/ ____/ /___/ _, _/___/ /
--   /_/ /_/_____/_____/_/   /_____/_/ |_|/____/
--
-- Wrap code in "if running" block
function ifRunning(application, code)
  -- If code is not given, we should find a way to return a boolean
  if code then
    return 'if application "' .. application .. '" is running then ' .. code .. ' end if'
  end
end

function indexOf(table, value, valName)
    for k, v in ipairs(table) do
      if valName then
        if v[valName] == value[valName] then return k end
      else
        if v == value then return k end
      end
    end
end

function secondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end


----------------------------------
--    _       _______   ______  ____ _       _______
--   | |     / /  _/ | / / __ \/ __ \ |     / / ___/
--   | | /| / // //  |/ / / / / / / / | /| / /\__ \
--   | |/ |/ // // /|  / /_/ / /_/ /| |/ |/ /___/ /
--   |__/|__/___/_/ |_/_____/\____/ |__/|__//____/
--
-- Flip through current applications windows
function windowFlipper(direction)
  local win = hs.window.focusedWindow()
  local app = win:application()
  local windows = app:allWindows()
  local window
  local index = indexOf(windows, win)

  log.f('windows: %s, win: %s, index: %d', windows[3], win, index)

  if direction == 'next' then
    window = windows[#windows]
    log.f('next')
  else
    log.f('prev')
    -- This is not working at all
    window = windows[#windows - 2]
  end
  local title = window:title()
  window:focus()
  hs.alert.show( title )
end
hs.hotkey.bind( { 'alt' }, 'Tab', function()
  windowFlipper('next')
end )
hs.hotkey.bind( { 'shift', 'alt' }, 'Tab', function()
  windowFlipper('prev')
end )

-- Send window to different screens
hs.hotkey.bind(hyper, 'Left', function()
  hs.window.focusedWindow():moveOneScreenWest()
end )
hs.hotkey.bind(hyper, 'Right', function()
  hs.window.focusedWindow():moveOneScreenEast()
end )
hs.hotkey.bind(hyper, 'Up', function()
  hs.window.focusedWindow():toggleFullScreen()
end )
hs.hotkey.bind(hyper, 'Down', function()
  hs.window.focusedWindow():sendToBack()
end )

-- Snap window to grid
hs.hotkey.bind(hyper, 'pad7', grid.snap_northwest )
hs.hotkey.bind(hyper, 'pad8', grid.snap_north )
hs.hotkey.bind(hyper, 'pad9', grid.snap_northeast )

hs.hotkey.bind(hyper, 'pad4', grid.snap_west )
hs.hotkey.bind(hyper, 'pad5', grid.snap_center )
hs.hotkey.bind(hyper, 'pad6', grid.snap_east )

hs.hotkey.bind(hyper, 'pad1', grid.snap_southwest )
hs.hotkey.bind(hyper, 'pad2', grid.snap_south )
hs.hotkey.bind(hyper, 'pad3', grid.snap_southeast )

-- Maximize for small keyboard
hs.hotkey.bind(hyper, 'm', grid.maximize_window )


----------------------------------
--     ___   __  ______  ________
--    /   | / / / / __ \/  _/ __ \
--   / /| |/ / / / / / // // / / /
--  / ___ / /_/ / /_/ // // /_/ /
-- /_/  |_\____/_____/___/\____/
--
local spotifyVolume = 100
local oldSpotifyVolume
ok, spotifyVolume = hs.applescript('tell application "Spotify" to sound volume as string')

-- For now, use this
-- hs.hotkey.bind(hyper, 'f6', toggle_audio_output )
-- But in the future, try to use fnutils.cycle to cycle through the table of audio devices returned by hs.audiodevice.allOutputDevices()
-- local soundDeviceCycler = hs.fnutils.cycle( hs.audiodevice.allOutputDevices() )
-- hs.hotkey.bind(hyper, 'f6', function()
--   hs.alert.show( hs.audiodevice.current().name )
--   -- local pelle = soundDeviceCycler()
--   -- hs.alert.show( pelle )
-- end )
hs.hotkey.bind(hyper, 'f4', function()
  hs.spotify.displayCurrentTrack()
end )
hs.hotkey.bind(hyper, 'f5', function()
  hs.spotify.rw()
  hs.alert.show(secondsToClock(hs.spotify.getPosition()))
end )
hs.hotkey.bind(hyper, 'f6', function()
  hs.spotify.ff()
  hs.alert.show(secondsToClock(hs.spotify.getPosition()))
end )
hs.hotkey.bind(hyper, 'f7', function()
  hs.spotify.previous()
end )
hs.hotkey.bind(hyper, 'f8', function()
  hs.spotify.playpause()
end )
hs.hotkey.bind(hyper, 'f9', function()
  hs.spotify.next()
end )
hs.hotkey.bind(hyper, 'f10', function()
  if hs.audiodevice.current().name == 'DisplayPort' then
    -- ok, spotifyVolume = hs.applescript('tell application "Spotify" to sound volume as string')
    -- if spotifyVolume == 0 then
    --   hs.applescript( 'tell application "Spotify" to set sound volume to ' .. oldSpotifyVolume )
    -- else
    --   oldSpotifyVolume = spotifyVolume
    --   spotifyVolume = 0
    --   hs.applescript( 'tell application "Spotify" to set sound volume to 0' )
    -- end
  else
    if hs.audiodevice.current().muted then
      hs.audiodevice.defaultOutputDevice():setMuted( false )
    else
      hs.audiodevice.defaultOutputDevice():setMuted( true )
    end
  end
end )
hs.hotkey.bind(hyper, 'f11', function()
  if hs.audiodevice.current().name == 'DisplayPort' then
    -- DisplayPort has no volume, try changing Spotify's volume
    hs.applescript( 'tell application "Spotify" to set sound volume to (sound volume - 10)' )
  else
    hs.audiodevice.defaultOutputDevice():setVolume( hs.audiodevice.current().volume - 10 )
  end
end )
hs.hotkey.bind(hyper, 'f12', function()
  if hs.audiodevice.current().name == 'DisplayPort' then
    -- DisplayPort has no volume, try changing Spotify's volume
    hs.applescript( 'tell application "Spotify" to set sound volume to (sound volume + 10)' )
  else
    hs.audiodevice.defaultOutputDevice():setVolume( hs.audiodevice.current().volume + 10 )
  end
end )

-- local spotifyStatus = hs.menubar.new()
-- spotifyStatus:setMenu(
--   {
--     { title = 'Track info', fn = function() hs.spotify.displayCurrentTrack() end },
--     { title = '-' },
--     { title = 'disabled item', disabled = true },
--     { title = 'checked item', checked = true },
--   }
-- )
-- function setSpotifyStatusDisplay()
--   spotifyStatus:setTitle( tostring(hs.spotify.getCurrentArtist()) .. ' - ' .. tostring(hs.spotify.getCurrentTrack()) )
-- end
-- local spotifyPoller = hs.timer.new(5, setSpotifyStatusDisplay)
-- spotifyPoller:start()


----------------------------------
--    _____ ____  ____  ____  _   _______
--   / ___// __ \/ __ \/ __ \/ | / / ___/
--   \__ \/ /_/ / / / / / / /  |/ /\__ \
--  ___/ / ____/ /_/ / /_/ / /|  /___/ /
-- /____/_/    \____/\____/_/ |_//____/
--
-- Load some spoons
hs.loadSpoon('SpoonInstall')
Install = spoon.SpoonInstall

Install:andUse('ColorPicker', {
  disable = false,
  hotkeys = {
    show = { hyper, 'z' }
  },
  config = {
    show_in_menubar = false,
  },
  start = true,
})

Install:andUse('ClipboardTool', {
  disable = false,
  hotkeys = {
    toggle_clipboard = { hyper, 'c' }
  },
  config = {
    show_in_menubar = true,
    menubar_title = '✂',
  },
  start = true,
})

-- Optionally load a local file with per-machine settings
-- and/or secret API keys etc.
local localfile = hs.configdir .. '/init-local.lua'
if hs.fs.attributes(localfile) then
  dofile(localfile)
end


----------------------------------
--     __  __________________
--    /  |/  / ____/_  __/   |
--   / /|_/ / __/   / / / /| |
--  / /  / / /___  / / / ___ |
-- /_/  /_/_____/ /_/ /_/  |_|
--
-- Reload config on file change
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == '.lua' then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    if spotifyStatus then
      spotifyStatus:delete()
    end
  end
end
hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reloadConfig):start()

-- All loaded, let user know
hs.alert.show('Config loaded')


-----------------
-- Places to watch:
-- https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations
-- https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
-- https://github.com/trishume/dotfiles/tree/master/hammerspoon/hammerspoon.symlink