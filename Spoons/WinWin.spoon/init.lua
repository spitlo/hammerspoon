--- === WinWin ===
---
--- Windows manipulation
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "WinWin"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Windows manipulation history. Only the last operation is stored.
obj.history = {}

--- WinWin.gridparts
--- Variable
--- An integer specifying how many gridparts the screen should be divided into. Defaults to 30.
obj.gridparts = 30

-- Internal method to find out what part of the screen a window gravitates towards (left/right, top/bottom)
--      +------------------+------------------+
--      |   +-------------------+             |   Example: The window gravitates towards left and top
--      |   |              |    |             |
--      |   |              |    |             |
--      +-------------------------------------+
--      |   |              |    |             |
--      |   +-------------------+             |
--      |                  |                  |
--      +------------------+------------------+
-- Perhaps there is a much easier way to calculate this?
function obj:_getWindowGravity(window)
    local screen = window:screen()
    local sFrame = screen:frame()
    local wFrame = window:frame()

    local halfWidth = sFrame.w / 2
    local lMargin = wFrame.x
    local rMargin = sFrame.w - (lMargin + wFrame.w)
    local lPart = halfWidth - lMargin
    local rPart = halfWidth - rMargin

    local halfHeight = sFrame.h / 2
    local tMargin = wFrame.y
    local bMargin = sFrame.h - (tMargin + wFrame.h)
    local tPart = halfHeight - tMargin
    local bPart = halfHeight - bMargin

    return {
        left = lPart >= rPart,
        right = rPart > lPart,
        top = tPart >= bPart,
        bottom = bPart > tPart,
    }
end

--- WinWin:stepMove(direction)
--- Method
--- Move the focused window in the `direction` by on step. The step scale equals to the width/height of one gridpart.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
function obj:stepMove(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wtopleft = cwin:topLeft()
        if direction == "left" then
            cwin:setTopLeft({x=wtopleft.x-stepw, y=wtopleft.y})
        elseif direction == "right" then
            cwin:setTopLeft({x=wtopleft.x+stepw, y=wtopleft.y})
        elseif direction == "up" then
            cwin:setTopLeft({x=wtopleft.x, y=wtopleft.y-steph})
        elseif direction == "down" then
            cwin:setTopLeft({x=wtopleft.x, y=wtopleft.y+steph})
        else
            hs.alert.show("Unknown direction: " .. direction)
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:stepResize(direction)
--- Method
--- Resize the focused window in the `direction` by on step.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
function obj:stepResize(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wsize = cwin:size()
        if direction == "left" then
            cwin:setSize({w=wsize.w-stepw, h=wsize.h})
        elseif direction == "right" then
            cwin:setSize({w=wsize.w+stepw, h=wsize.h})
        elseif direction == "up" then
            cwin:setSize({w=wsize.w, h=wsize.h-steph})
        elseif direction == "down" then
            cwin:setSize({w=wsize.w, h=wsize.h+steph})
        else
            hs.alert.show("Unknown direction: " .. direction)
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:smartStepResize(direction)
--- Method
--- Resize the focused window "smartly" by one step. See notes for our definition of smartly.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
---
--- Notes:
--- * If window gravitates to the right, `right` and `left` expands and shrinks the window on the left border.
--- * If window is more to the left, it resizes on the right border.
--- * The same principal applies to `up` and `down`.
--- * When a window is full width or full height, it will shrink/expand in the 'direction' direction.
function obj:smartStepResize(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local wsize = cwin:size()
        local gravity = obj:_getWindowGravity(cwin)

        local sFrame = cscreen:frame()
        local wFrame = cwin:frame()
        local isFullWidth = sFrame.w == wFrame.w
        local isFullHeight = sFrame.h == wFrame.h

        if direction == "left" then
            if isFullWidth then
                gravity.left = true
                gravity.right = false
            end
            if gravity.left then
                obj:stepResize('left')
            else
                obj:stepMove('left')
                obj:stepResize('right')
            end

        elseif direction == "right" then
            if isFullWidth then
                gravity.left = false
                gravity.right = true
            end
            if gravity.right then
                obj:stepResize('left')
                obj:stepMove('right')
            else
                obj:stepResize('right')
            end

        elseif direction == "up" then
            if isFullHeight then
                gravity.top = true
                gravity.bottom = false
            end
            if gravity.top then
                obj:stepResize('up')
            else
                obj:stepMove('up')
                obj:stepResize('down')
            end

        elseif direction == "down" then
            if isFullHeight then
                gravity.top = false
                gravity.bottom = true
            end
            if gravity.bottom then
                obj:stepResize('up')
                obj:stepMove('down')
            else
                obj:stepResize('down')
            end
        else
            hs.alert.show("Unknown direction: " .. direction)
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:moveAndResize(option)
--- Method
--- Move and resize the focused window.
---
--- Parameters:
---  * option - A string specifying the option, valid strings are: `halfleft`, `halfright`, `halfup`, `halfdown`, `cornerNW`, `cornerSW`, `cornerNE`, `cornerSE`, `center`, `fullscreen`, `maximize`, `minimize`, `expand`, `shrink`.
local function windowStash(window)
    local winid = window:id()
    local winf = window:frame()
    if #obj.history > 50 then
        -- Make sure the history doesn't reach the maximum (50 items).
        table.remove(obj.history) -- Remove the last item
    end
    local winstru = {winid, winf}
    table.insert(obj.history, winstru) -- Insert new item of window history
end

function obj:moveAndResize(option)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local stepw = cres.w/obj.gridparts
        local steph = cres.h/obj.gridparts
        local wf = cwin:frame()
        options = {
            halfleft = function() cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h}) end,
            halfright = function() cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h}) end,
            halfup = function() cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2}) end,
            halfdown = function() cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2}) end,
            cornerNW = function() cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h/2}) end,
            cornerNE = function() cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h/2}) end,
            cornerSW = function() cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2}) end,
            cornerSE = function() cwin:setFrame({x=cres.x+cres.w/2, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2}) end,
            fullscreen = function() cwin:setFullScreen(true) end,
            maximize = function() cwin:maximize() end,
            minimize = function() cwin:minimize() end,
            center = function() cwin:centerOnScreen() end,
            expand = function() cwin:setFrame({x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)}) end,
            shrink = function() cwin:setFrame({x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)}) end,
        }
        if options[option] == nil then
            hs.alert.show("Unknown option: " .. option)
        else
            -- if the window is fullscreen, and that's not what the user wants,
            -- toggle fullscreen off before proceeding
            if option ~= "fullscreen" and cwin:isFullScreen() then
                cwin:setFullScreen(false)
                -- a sleep is required to let the window manager register the new state,
                -- otherwise the follow-up minimize() call doesn't work
                hs.timer.usleep(999999)
            end
            windowStash(cwin)
            options[option]()
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:moveToScreen(direction)
--- Method
--- Move the focused window between all of the screens in the `direction`.
---
--- Parameters:
---  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`, `next`.
function obj:moveToScreen(direction)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        if direction == "up" then
            cwin:moveOneScreenNorth()
        elseif direction == "down" then
            cwin:moveOneScreenSouth()
        elseif direction == "left" then
            cwin:moveOneScreenWest()
        elseif direction == "right" then
            cwin:moveOneScreenEast()
        elseif direction == "next" then
            cwin:moveToScreen(cscreen:next())
        else
            hs.alert.show("Unknown direction: " .. direction)
        end
    else
        hs.alert.show("No focused window!")
    end
end

--- WinWin:undo()
--- Method
--- Undo the last window manipulation. Only those "moveAndResize" manipulations can be undone.
---
function obj:undo()
    local cwin = hs.window.focusedWindow()
    local cwinid = cwin:id()
    for idx,val in ipairs(obj.history) do
        -- Has this window been stored previously?
        if val[1] == cwinid then
            cwin:setFrame(val[2])
        end
    end
end

--- WinWin:centerCursor()
--- Method
--- Center the cursor on the focused window.
---
function obj:centerCursor()
    local cwin = hs.window.focusedWindow()
    local wf = cwin:frame()
    local cscreen = cwin:screen()
    local cres = cscreen:fullFrame()
    if cwin then
        -- Center the cursor one the focused window
        hs.mouse.setAbsolutePosition({x=wf.x+wf.w/2, y=wf.y+wf.h/2})
    else
        -- Center the cursor on the screen
        hs.mouse.setAbsolutePosition({x=cres.x+cres.w/2, y=cres.y+cres.h/2})
    end
end

return obj
