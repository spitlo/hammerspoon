local log = hs.logger.new('init', 'verbose')

local hyper = { 'shift', 'cmd', 'alt', 'ctrl' }


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

function openApplication(name)
  hs.application.launchOrFocus(name)
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
hs.hotkey.bind({ 'alt' }, 'Tab', function()
  windowFlipper('next')
end)
hs.hotkey.bind( {'shift', 'alt' }, 'Tab', function()
  windowFlipper('prev')
end)

-- Open or focus applications with keyboard shortcuts
hs.hotkey.bind(hyper, 'n', function()
  openApplication('nvAlt')
end)

-- Send 'ctrl+c - arrow up - enter' to restart a long-running command in the terminal.
-- (Uses the 'releasefn' argument to only send ctrl and not the full hyper combo)
hs.hotkey.bind(hyper, 'q', nil, function()
  hs.eventtap.keyStroke({ 'ctrl' }, 'c')
  hs.eventtap.keyStroke(nil, 'up')
  hs.eventtap.keyStroke(nil, 'return')
end)

----------------------------------
--     ___   __  ______  ________
--    /   | / / / / __ \/  _/ __ \
--   / /| |/ / / / / / // // / / /
--  / ___ / /_/ / /_/ // // /_/ /
-- /_/  |_\____/_____/___/\____/
--
local spotifyVolume
local oldSpotifyVolume
ok, spotifyVolume = hs.applescript(ifRunning('Spotify', 'tell application "Spotify" to sound volume as string'))
if not ok then
  spotifyVolume = 100
end

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

Install:andUse('ClipboardTool', {
  disable = false,
  hotkeys = {
    toggle_clipboard = { hyper, 'c' },
    clear_history = { hyper, 'x' },
  },
  config = {
    show_in_menubar = true,
    menubar_title = '✂',
  },
  start = true,
})

Install:andUse('WinWin', {
  config = {
    gridparts = 18,
  }
})

if spoon.WinWin then
  -- Snap window to grid
  hs.hotkey.bind(hyper, 'pad7', function() spoon.WinWin:moveAndResize('cornerNW') end)
  hs.hotkey.bind(hyper, 'pad8', function() spoon.WinWin:moveAndResize('halfup') end)
  hs.hotkey.bind(hyper, 'pad9', function() spoon.WinWin:moveAndResize('cornerNE') end)

  hs.hotkey.bind(hyper, 'pad4', function() spoon.WinWin:moveAndResize('halfleft') end)
  hs.hotkey.bind(hyper, 'pad5', function() spoon.WinWin:moveAndResize('center') end)
  hs.hotkey.bind(hyper, 'pad6', function() spoon.WinWin:moveAndResize('halfright') end)

  hs.hotkey.bind(hyper, 'pad1', function() spoon.WinWin:moveAndResize('cornerSW') end)
  hs.hotkey.bind(hyper, 'pad2', function() spoon.WinWin:moveAndResize('halfdown') end)
  hs.hotkey.bind(hyper, 'pad3', function() spoon.WinWin:moveAndResize('cornerSE') end)

  -- Increas/decreas size
  hs.hotkey.bind(hyper, 'pad+', function() spoon.WinWin:moveAndResize('expand') end)
  hs.hotkey.bind(hyper, 'pad-', function() spoon.WinWin:moveAndResize('shrink') end)

  -- Maximize for small keyboard
  hs.hotkey.bind(hyper, 'm', function() spoon.WinWin:moveAndResize('maximize') end)

  -- -- Move window
  hs.hotkey.bind(hyper, 'j', function() spoon.WinWin:stepMove('left') end)
  hs.hotkey.bind(hyper, 'l', function() spoon.WinWin:stepMove('right') end)
  hs.hotkey.bind(hyper, 'i', function() spoon.WinWin:stepMove('up') end)
  hs.hotkey.bind(hyper, 'k', function() spoon.WinWin:stepMove('down') end)

  -- -- Resize window
  hs.hotkey.bind(hyper, 'left', function() spoon.WinWin:smartStepResize('left') end)
  hs.hotkey.bind(hyper, 'right', function() spoon.WinWin:smartStepResize('right') end)
  hs.hotkey.bind(hyper, 'up', function() spoon.WinWin:smartStepResize('up') end)
  hs.hotkey.bind(hyper, 'down', function() spoon.WinWin:smartStepResize('down') end)

  -- -- Move window between screens
  hs.hotkey.bind(hyper, 'home', function() spoon.WinWin:moveToScreen('left') end )
  hs.hotkey.bind(hyper, 'end', function() spoon.WinWin:moveToScreen('right') end )
end

Install:andUse('PasswordGenerator', {
  hotkeys = {
    paste = { hyper, 'p' }
  },
  config = {
    password_length = 32,
  },
})

-- Reload config on file change
-- and when pressing Hyper + r
Install:andUse('ReloadConfiguration', {
  hotkeys = {
    reloadConfiguration = { hyper, 'r' }
  },
  start = true,
})

-- Show a list of HTTP statuses
-- when pressing hyper + h
Install:andUse('HttpStatus', {
  hotkeys = {
    show = { hyper, 'h' }
  },
})

-- Show a list of Unicode Symbols and
-- Dingbats when pressing hyper + s
Install:andUse('Symbats', {
  hotkeys = {
    show = { hyper, 's' }
  },
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
-- All loaded, let user know
hs.alert.show('Config loaded')


-----------------
-- Places to watch:
-- https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations
-- https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
-- https://github.com/trishume/dotfiles/tree/master/hammerspoon/hammerspoon.symlink
