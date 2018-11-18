-- CCKit.lua
-- CCKit
--
-- The main CCKit include. Renames all classes to be part of itself.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")

local function require(class)
    local remove = true
    if _G[class] ~= nil then remove = false
    else os.loadAPI(CCKitGlobals.CCKitDir .. "/" .. class .. ".lua") end
    local temp = _G[class]
    if remove then os.unloadAPI(class) end
    return temp[class]
end

CCApplication = require("CCApplication")
CCButton = require("CCButton")
CCCheckbox = require("CCCheckbox")
CCControl = require("CCControl")
CCImageLoader = require("CCImageLoader")
os.loadAPI(CCKitGlobals.CCKitDir .. "/CCImageType.lua")
CCImageView = require("CCImageView")
CCImageWriter = require("CCImageWriter")
CCLabel = require("CCLabel")
if CCLog == nil then os.loadAPI(CCKitGlobals.CCKitDir .. "/CCLog.lua") end
CCProgressBar = require("CCProgressBar")
CCScrollView = require("CCScrollView")
CCSlider = require("CCSlider")
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