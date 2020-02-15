-- CCKitGlobals.lua
-- CCKit
--
-- This file defines global variables that other files read from. This must be
-- placed at /CCKit/CCKitGlobals.lua for other CCKit classes to work. This can
-- also be modified by the end user to change default values.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = {

-- CCWindow
titleBarColor = colors.yellow,                  -- The color of the background of the title bar
titleBarTextColor = colors.black,               -- The color of the text of the title bar
windowBackgroundColor = colors.white,           -- The color of the background of a window
liveWindowMove = true,                          -- Whether to redraw window contents while moving or to only show the border (for speed)

-- Text views
defaultTextColor = colors.black,                -- The default color of text

-- CCButtons
buttonColor = colors.lightGray,                 -- The color of a normal button
buttonSelectedColor = colors.gray,              -- The color of a selected button
buttonHighlightedColor = colors.lightBlue,      -- The color of a highlighted button
buttonHighlightedSelectedColor = colors.blue,   -- The color of a highlighted selected button
buttonDisabledColor = colors.lightGray,         -- The color of a disabled button
buttonDisabledTextColor = colors.gray,          -- The color of the text in a disabled button

}

-- Include some global functions
for k,v in pairs(require "CCKitGlobalFunctions") do CCKitGlobals[k] = v end
return CCKitGlobals