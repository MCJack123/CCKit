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
titleBarColor = colors.yellow,

titleBarTextColor = colors.black,

windowBackgroundColor = colors.white,

liveWindowMove = false,


-- Text views
defaultTextColor = colors.black,


-- CCButtons
buttonColor = colors.lightGray,

buttonSelectedColor = colors.gray,

buttonHighlightedColor = colors.lightBlue,

buttonHighlightedSelectedColor = colors.blue,

buttonDisabledColor = colors.lightGray,

buttonDisabledTextColor = colors.gray,

}
-- Include some global functions
for k,v in pairs(require "CCKitGlobalFunctions") do CCKitGlobals[k] = v end
return CCKitGlobals
