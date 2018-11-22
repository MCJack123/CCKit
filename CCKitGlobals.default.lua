-- CCKitGlobals.lua
-- CCKit
--
-- This file defines global variables that other files read from. This must be
-- placed at /CCKit/CCKitGlobals.lua for other CCKit classes to work. This can
-- also be modified by the end user to change default values.
--
-- Copyright (c) 2018 JackMacWindows.

-- All classes
CCKitDir = "CCKit"                             -- The directory where all of the CCKit files are located
shouldDoubleRequire = true                     -- Whether loadAPI should load the API even when it's already loaded

-- CCWindow
titleBarColor = colors.yellow                  -- The color of the background of the title bar
titleBarTextColor = colors.black               -- The color of the text of the title bar
windowBackgroundColor = colors.white           -- The color of the background of a window
liveWindowMove = false                         -- Whether to redraw window contents while moving or to only show the border (for speed)

-- Text views
defaultTextColor = colors.black                -- The default color of text

-- CCButtons
buttonColor = colors.lightGray                 -- The color of a normal button
buttonSelectedColor = colors.gray              -- The color of a selected button
buttonHighlightedColor = colors.lightBlue      -- The color of a highlighted button
buttonHighlightedSelectedColor = colors.blue   -- The color of a highlighted selected button
buttonDisabledColor = colors.lightGray         -- The color of a disabled button
buttonDisabledTextColor = colors.gray          -- The color of the text in a disabled button

-- Include some global functions
if require == nil then os.loadAPI(CCKitDir.."/CCKitGlobalFunctions.lua")
for k,v in pairs(CCKitGlobalFunctions) do _G[k] = CCKitGlobalFunctions[k] end end