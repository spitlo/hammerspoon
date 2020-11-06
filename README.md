# Hammerspoon config

## Official spoons

[ClipboardTool](https://www.hammerspoon.org/Spoons/ClipboardTool.html), [ColorPicker](https://www.hammerspoon.org/Spoons/ColorPicker.html), [PasswordGenerator](https://www.hammerspoon.org/Spoons/PasswordGenerator.html), [ReloadConfiguration](https://www.hammerspoon.org/Spoons/ReloadConfiguration.html) and [SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html)

## Custom or customized spoons

### Symbats

Shows a list of Unicode Symbols and Dingbats, copies to pasteboard on select.

### WinWin (customized)

Adds a method, `smartStepResize`, that resizes the focused window "smartly" by one step.

By smartly, we mean:

- If window gravitates to the left, `right` and `left` expands and shrinks the window on the right border (see illustration).
- If window is more to the right, it resizes on the left border.
- The same principal applies to `up` and `down`.
- When a window is full width or full height, it will shrink/expand in the 'direction' direction.

```text
 +------------------+------------------+
 |   +-------------------+             |
 |   |              |    |             |
 |   |              |  < | >           |
 +-------------------------------------+
 |   |         /\   |    |             |
 |   +-------------------+             |
 |             \/   |                  |
 +------------------+------------------+
```

### HttpStatus (from gist)

Shows a list of http statuses. Opens the relevant status description at httpstatuses.com on select.

Taken from: https://gist.github.com/james2doyle/8cec2b2693f7909b36587327a85055d5

## Installation

```bash
$ cd ~
$ git clone https://github.com/spitlo/hammerspoon .hammerspoon
```
