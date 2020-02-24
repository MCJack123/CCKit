-- ConfigureCCKit.lua
-- CCKit
--
-- This file is a configuration utility for CCKit.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCKit = require "CCKit"
local class = require "class"

local ColorPickerController = class "ColorPickerController" {extends = CCKit.CCViewController} {
    __init = function(name)
        self.name = name
        self.selectedColor = colors.blue
        self.selectedColorView = CCKit.CCView(0, 0, 4, 1)
        self.buttons = {}
        self.selects = {}
        local i = 0
        while i < 16 do
            self.buttons[i] = CCKit.CCButton(i % 4, math.floor(i / 4) + 1, 1, 1)
            self.buttons[i].backgroundColor = bit.blshift(1, i)
            self.selects[i] = loadstring([[return function(self) 
                self.selectedColor = ]] .. bit.blshift(1, i) .. [[
                self.selectedColorView.setBackgroundColor(self.selectedColor)
            end]])()
            self.buttons[i].setAction(self.selects[i], self)
            i=i+1
        end
    end,
    viewDidLoad = function()
        local i = 0
        while i < 16 do 
            self.view.addSubview(self.buttons[i]) 
            i=i+1
        end
        self.view.addSubview(self.selectedColorView)
        local okButton = CCKit.CCButton(0, 5, 4, 1)
        okButton.text = "OK"
        okButton.setAction(self.ok, self)
        self.view.addSubview(okButton)
    end,
    ok = function()
        os.queueEvent("color_picker_ok", self.name, self.selectedColor)
        self.window.close()
    end
}

local function iDontTrustToStringOnBools(b) if b then return "true" else return "false" end end
local function log2(num) return math.log10(num) / math.log10(2) end
local colorNames = {
    "colors.white", "colors.orange", "colors.magenta", "colors.lightBlue",
    "colors.yellow", "colors.lime", "colors.pink", "colors.gray",
    "colors.lightGray", "colors.cyan", "colors.purple", "colors.blue",
    "colors.brown", "colors.green", "colors.red", "colors.black"
}
local function intToColor(i) return colorNames[log2(i)+1] end

local ConfiguratorViewController = class "ConfiguratorViewController" {extends = {CCKit.CCViewController, CCKit.CCEventHandler}} {
    __init = function()
        _ENV.CCEventHandler("ConfiguratorViewController")
        --self.shouldDoubleRequire = CCKit.CCCheckbox(1, 2, "Double Require")
        self.titleBarColor = CCKit.CCButton(1, 3, 2, 1)
        self.titleBarTextColor = CCKit.CCButton(1, 4, 2, 1)
        self.windowBackgroundColor = CCKit.CCButton(1, 5, 2, 1)
        self.liveWindowMove = CCKit.CCCheckbox(1, 6, "Live Window Move")
        self.defaultTextColor = CCKit.CCButton(1, 7, 2, 1)
        self.buttonColor = CCKit.CCButton(1, 8, 2, 1)
        self.buttonSelectedColor = CCKit.CCButton(1, 9, 2, 1)
        self.buttonHighlightedColor = CCKit.CCButton(1, 10, 2, 1)
        self.buttonHighlightedSelectedColor = CCKit.CCButton(23, 1, 2, 1)
        self.buttonDisabledColor = CCKit.CCButton(23, 2, 2, 1)
        self.buttonDisabledTextColor = CCKit.CCButton(23, 3, 2, 1)
        self.addEvent("color_picker_ok", self.colorPickerOk)
        self.addEvent("checkbox_toggled", self.checkboxToggled)
    end,
    checkboxToggled = function(name, value)
        --if name == self.shouldDoubleRequire.name then CCKitGlobals.shouldDoubleRequire = value
        if name == self.liveWindowMove.name then CCKitGlobals.liveWindowMove = value
        else return false end
        return true
    end,
    colorPickerOk = function(name, selectedColor)
        self[name].setBackgroundColor(selectedColor)
        CCKitGlobals[name] = selectedColor
    end,
    openColorPanel = function(obj)
        local vc = ColorPickerController(obj.name)
        local newwin = CCKit.CCWindow(5, 5, 4, 7)
        newwin.maximizable = false
        newwin.setViewController(vc, obj.self.application)
        obj.self.window.present(newwin)
    end,
    default = function()
        local file = fs.open("/CCKit/CCKitGlobals.lua", "w")
        file.write([[-- CCKitGlobals.lua
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
]])
        file.close()
        os.loadAPI("/CCKit/CCKitGlobals.lua")
        local done = CCKit.CCAlertWindow(15, 5, 21, 6, "Done", "Finished saving.", self.application)
        self.window.present(done)
    end,
    save = function()
        local file = fs.open("/CCKit/CCKitGlobals.lua", "w")
        file.write([[-- CCKitGlobals.lua
-- CCKit
--
-- This file defines global variables that other files read from. This must be
-- placed at /CCKit/CCKitGlobals.lua for other CCKit classes to work. This can
-- also be modified by the end user to change default values.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = {
-- CCWindow
titleBarColor = ]] .. intToColor(CCKitGlobals.titleBarColor) .. [[,

titleBarTextColor = ]] .. intToColor(CCKitGlobals.titleBarTextColor) .. [[,

windowBackgroundColor = ]] .. intToColor(CCKitGlobals.windowBackgroundColor) .. [[,

liveWindowMove = ]] .. iDontTrustToStringOnBools(CCKitGlobals.liveWindowMove) .. [[,


-- Text views
defaultTextColor = ]] .. intToColor(CCKitGlobals.defaultTextColor) .. [[,


-- CCButtons
buttonColor = ]] .. intToColor(CCKitGlobals.buttonColor) .. [[,

buttonSelectedColor = ]] .. intToColor(CCKitGlobals.buttonSelectedColor) .. [[,

buttonHighlightedColor = ]] .. intToColor(CCKitGlobals.buttonHighlightedColor) .. [[,

buttonHighlightedSelectedColor = ]] .. intToColor(CCKitGlobals.buttonHighlightedSelectedColor) .. [[,

buttonDisabledColor = ]] .. intToColor(CCKitGlobals.buttonDisabledColor) .. [[,

buttonDisabledTextColor = ]] .. intToColor(CCKitGlobals.buttonDisabledTextColor) .. [[,

}
-- Include some global functions
for k,v in pairs(require "CCKitGlobalFunctions") do CCKitGlobals[k] = v end
return CCKitGlobals
]])
        file.close()
        package.loaded.CCKitGlobals = nil
        package.loaded.CCKit = nil
        local done = CCKit.CCAlertWindow(15, 5, 21, 6, "Done", "Finished saving.", self.application)
        self.window.present(done)
    end,
    viewDidLoad = function()
        --local CCKitDir = CCKit.CCView(1, 1, 8, 1)
        --CCKitDir.backgroundColor = colors.lightGray
        --local CCKitDirLabel = CCKit.CCLabel(10, 1, "CCKitDir")
        --local CCKitDirDefault = CCKit.CCLabel(0, 0, CCKitGlobals.CCKitDir)
        --CCKitDirDefault.backgroundColor = colors.lightGray
        --self.view.addSubview(CCKitDir)
        --self.view.addSubview(CCKitDirLabel)
        --CCKitDir.addSubview(CCKitDirDefault)

        --self.shouldDoubleRequire.isOn = CCKitGlobals.shouldDoubleRequire
        --self.view.addSubview(self.shouldDoubleRequire)

        self.titleBarColor.backgroundColor = CCKitGlobals.titleBarColor
        self.titleBarColor.setAction(self.openColorPanel, {self=self, name="titleBarColor"})
        local titleBarColorLabel = CCKit.CCLabel(4, 3, "Title Bar Color")
        self.view.addSubview(self.titleBarColor)
        self.view.addSubview(titleBarColorLabel)

        self.titleBarTextColor.backgroundColor = CCKitGlobals.titleBarTextColor
        self.titleBarTextColor.setAction(self.openColorPanel, {self=self, name="titleBarTextColor"})
        local titleBarTextColorLabel = CCKit.CCLabel(4, 4, "Title Bar Text")
        self.view.addSubview(self.titleBarTextColor)
        self.view.addSubview(titleBarTextColorLabel)

        self.windowBackgroundColor.backgroundColor = CCKitGlobals.windowBackgroundColor
        self.windowBackgroundColor.setAction(self.openColorPanel, {self=self, name="windowBackgroundColor"})
        local windowBackgroundColorLabel = CCKit.CCLabel(4, 5, "Window Background")
        self.view.addSubview(self.windowBackgroundColor)
        self.view.addSubview(windowBackgroundColorLabel)

        self.liveWindowMove.isOn = CCKitGlobals.liveWindowMove
        self.view.addSubview(self.liveWindowMove)

        self.defaultTextColor.backgroundColor = CCKitGlobals.defaultTextColor
        self.defaultTextColor.setAction(self.openColorPanel, {self=self, name="defaultTextColor"})
        local defaultTextColorLabel = CCKit.CCLabel(4, 7, "Text Color")
        self.view.addSubview(self.defaultTextColor)
        self.view.addSubview(defaultTextColorLabel)

        self.buttonColor.backgroundColor = CCKitGlobals.buttonColor
        self.buttonColor.setAction(self.openColorPanel, {self=self, name="buttonColor"})
        local buttonColorLabel = CCKit.CCLabel(4, 8, "Button")
        self.view.addSubview(self.buttonColor)
        self.view.addSubview(buttonColorLabel)

        self.buttonSelectedColor.backgroundColor = CCKitGlobals.buttonSelectedColor
        self.buttonSelectedColor.setAction(self.openColorPanel, {self=self, name="buttonSelectedColor"})
        local buttonSelectedColorLabel = CCKit.CCLabel(4, 9, "Selected Button")
        self.view.addSubview(self.buttonSelectedColor)
        self.view.addSubview(buttonSelectedColorLabel)

        self.buttonHighlightedColor.backgroundColor = CCKitGlobals.buttonHighlightedColor
        self.buttonHighlightedColor.setAction(self.openColorPanel, {self=self, name="buttonHighlightedColor"})
        local buttonHighlightedColorLabel = CCKit.CCLabel(4, 10, "Highlighted Button")
        self.view.addSubview(self.buttonHighlightedColor)
        self.view.addSubview(buttonHighlightedColorLabel)

        self.buttonHighlightedSelectedColor.backgroundColor = CCKitGlobals.buttonHighlightedSelectedColor
        self.buttonHighlightedSelectedColor.setAction(self.openColorPanel, {self=self, name="buttonHighlightedSelectedColor"})
        local buttonHighlightedSelectedColorLabel = CCKit.CCLabel(26, 1, "Selected Highlighted")
        self.view.addSubview(self.buttonHighlightedSelectedColor)
        self.view.addSubview(buttonHighlightedSelectedColorLabel)

        self.buttonDisabledColor.backgroundColor = CCKitGlobals.buttonDisabledColor
        self.buttonDisabledColor.setAction(self.openColorPanel, {self=self, name="buttonDisabledColor"})
        local buttonDisabledColorLabel = CCKit.CCLabel(26, 2, "Disabled Button")
        self.view.addSubview(self.buttonDisabledColor)
        self.view.addSubview(buttonDisabledColorLabel)

        self.buttonDisabledTextColor.backgroundColor = CCKitGlobals.buttonDisabledTextColor
        self.buttonDisabledTextColor.setAction(self.openColorPanel, {self=self, name="buttonDisabledTextColor"})
        local buttonDisabledTextColorLabel = CCKit.CCLabel(26, 3, "Disabled Text")
        self.view.addSubview(self.buttonDisabledTextColor)
        self.view.addSubview(buttonDisabledTextColorLabel)

        local saveButton = CCKit.CCButton(20, 12, 6, 1)
        saveButton.text = "Save"
        saveButton.setAction(self.save, self)
        self.view.addSubview(saveButton)

        local defaultButton = CCKit.CCButton(25, 5, 18, 1)
        defaultButton.text = "Restore Defaults"
        defaultButton.setAction(self.default, self)
        self.view.addSubview(defaultButton)

        self.window.registerObject(self)
    end,
}

CCKit.CCMain(3, 3, 47, 15, "Configure CCKit", ConfiguratorViewController, colors.blue, "Configure CCKit", true)