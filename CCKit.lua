-- CCKit.lua
-- CCKit
--
-- The main CCKit include. Renames all classes to be part of itself.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitDir = "CCKit"

local function require(class)
    os.loadAPI(CCKitDir .. "/" .. class .. ".lua")
    local temp = _G[class]
    os.unloadAPI(class)
    return temp[class]
end

CCApplication = require("CCApplication")
CCButton = require("CCButton")
CCImageView = require("CCImageView")
CCLabel = require("CCLabel")
CCProgressBar = require("CCProgressBar")
CCScrollView = require("CCScrollView")
CCTextView = require("CCTextView")
CCView = require("CCView")
CCViewController = require("CCViewController")
CCWindow = require("CCWindow")

function CCMain(initX, initY, initWidth, initHeight, title, vcClass, backgroundColor, appName)
    backgroundColor = backgroundColor or colors.black
    local name = title
    if appName ~= nil then name = appName end
    local app = CCApplication(name)
    app:setBackgroundColor(backgroundColor)
    local win = CCWindow(initX, initY, initWidth, initHeight)
    win:setTitle(title)
    local vc = vcClass()
    win:setViewController(vc, app)
    app:registerObject(win, win.name)
    app.isApplicationRunning = true
    term.setCursorBlink(false)
    app:runLoop()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.setCursorBlink(true)
end