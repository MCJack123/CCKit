-- CCKit.lua
-- CCKit
--
-- The main CCKit include. Renames all classes to be part of itself.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")

CCAlertWindow = CCRequire("CCAlertWindow")
CCApplication = CCRequire("CCApplication")
CCButton = CCRequire("CCButton")
CCCheckbox = CCRequire("CCCheckbox")
CCControl = CCRequire("CCControl")
CCEventHandler = CCRequire("CCEventHandler")
loadAPI("CCGraphics")
CCImageLoader = CCRequire("CCImageLoader")
loadAPI("CCImageType")
CCImageView = CCRequire("CCImageView")
CCImageWriter = CCRequire("CCImageWriter")
if _G._PID ~= nil then loadAPI("CCKernel") end
CCLabel = CCRequire("CCLabel")
loadAPI("CCLineBreakMode")
CCLog = loadAPI("CCLog")
CCProgressBar = CCRequire("CCProgressBar")
CCRadioButton = CCRequire("CCRadioButton")
CCRadioGroup = CCRequire("CCRadioGroup")
CCScrollView = CCRequire("CCScrollView")
CCSlider = CCRequire("CCSlider")
CCTextField = CCRequire("CCTextField")
CCTextView = CCRequire("CCTextView")
CCView = CCRequire("CCView")
CCViewController = CCRequire("CCViewController")
CCWindow = CCRequire("CCWindow")
loadAPI("CCWindowRegistry")

function CCMain(initX, initY, initWidth, initHeight, title, vcClass, backgroundColor, appName, showName)
    local forked = _FORK
    if forked == nil then forked = false end
    backgroundColor = backgroundColor or colors.black
    local name = title
    if appName ~= nil then name = appName end
    if _G._startPID == nil then _G._startPID = _G._PID end
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
    win:redraw()
    pcall(function() app:runLoop() end)
    CCWindowRegistry.deregisterApplication(app.name)
    if _G._PID == nil then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        term.setCursorBlink(true)
    else
        while _G._runningApps > 0 do coroutine.yield() end
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        term.setCursorBlink(true)
    end
end