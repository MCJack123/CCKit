-- CCKit.lua
-- CCKit
--
-- The main CCKit include. Renames all classes to be part of itself.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKit = {
    CCKitGlobals = require "CCKitGlobals",
    CCAlertWindow = require "CCAlertWindow",
    CCApplication = require "CCApplication",
    CCButton = require "CCButton",
    CCCheckbox = require "CCCheckbox",
    CCControl = require "CCControl",
    CCEventHandler = require "CCEventHandler",
    CCGraphics = require "CCGraphics",
    CCImageLoader = require "CCImageLoader",
    CCImageType = require "CCImageType",
    CCImageView = require "CCImageView",
    CCImageWriter = require "CCImageWriter",
    CCLabel = require "CCLabel",
    CCLineBreakMode = require "CCLineBreakMode",
    CCLog = require "CCLog",
    CCProgressBar = require "CCProgressBar",
    CCRadioButton = require "CCRadioButton",
    CCRadioGroup = require "CCRadioGroup",
    CCScrollView = require "CCScrollView",
    CCSlider = require "CCSlider",
    CCTextField = require "CCTextField",
    CCTextView = require "CCTextView",
    CCView = require "CCView",
    CCViewController = require "CCViewController",
    CCWindow = require "CCWindow",
    CCWindowRegistry = require "CCWindowRegistry",
}

function CCKit.CCMain(initX, initY, initWidth, initHeight, title, vcClass, backgroundColor, appName, showName)
    _G.windowRegistry = {zPos = {}}
    local forked = _FORK
    if forked == nil then forked = false end
    backgroundColor = backgroundColor or colors.black
    local name = title
    if appName ~= nil then name = appName end
    local app = CCKit.CCApplication(name)
    app.setBackgroundColor(backgroundColor)
    app.showName = showName or false
    local win = CCKit.CCWindow(initX, initY, initWidth, initHeight)
    win.setTitle(title)
    local vc = vcClass()
    win.setViewController(vc, app)
    app.registerObject(win, win.name)
    app.isApplicationRunning = true
    term.setCursorBlink(false)
    pcall(function() app.runLoop() end)
    CCKit.CCWindowRegistry.deregisterApplication(app.name)
    if not forked then
        while table.maxn(_G.windowRegistry.zPos) > 0 do coroutine.yield() end
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        term.setCursorBlink(true)
    end
end

return CCKit