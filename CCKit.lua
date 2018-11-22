-- CCKit.lua
-- CCKit
--
-- The main CCKit include. Renames all classes to be part of itself.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")

CCAlertWindow = require("CCAlertWindow")
CCApplication = require("CCApplication")
CCButton = require("CCButton")
CCCheckbox = require("CCCheckbox")
CCControl = require("CCControl")
CCEventHandler = require("CCEventHandler")
loadAPI("CCGraphics")
CCImageLoader = require("CCImageLoader")
loadAPI("CCImageType")
CCImageView = require("CCImageView")
CCImageWriter = require("CCImageWriter")
CCLabel = require("CCLabel")
loadAPI("CCLineBreakMode")
loadAPI("CCLog")
CCProgressBar = require("CCProgressBar")
CCRadioButton = require("CCRadioButton")
CCRadioGroup = require("CCRadioGroup")
CCScrollView = require("CCScrollView")
CCSlider = require("CCSlider")
CCTextField = require("CCTextField")
CCTextView = require("CCTextView")
CCView = require("CCView")
CCViewController = require("CCViewController")
CCWindow = require("CCWindow")

function CCMain(initX, initY, initWidth, initHeight, title, vcClass, backgroundColor, appName, showName)
    backgroundColor = backgroundColor or colors.black
    local name = title
    if appName ~= nil then name = appName end
    local app = CCApplication(name)
    app:setBackgroundColor(backgroundColor)
    app.showName = showName or false
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