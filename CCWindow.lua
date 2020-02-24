-- CCWindow.lua
-- CCKit
--
-- This file creates the CCWindow class, which handles the actions required
-- for a window to be displayed on screen.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"
local CCEventHandler = require "CCEventHandler"
--if _G._PID ~= nil then loadAPI("CCKernel") end
local CCWindowRegistry = require "CCWindowRegistry"

-- Constants for the colors of the window

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

local function string_random(length)
  --math.randomseed(os.clock())

  if length > 0 then
    return string_random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

return class "CCWindow" {extends = CCEventHandler} {
    title = "",
    viewController = nil,
    isDragging = false,
    mouseOffset = 0,
    repaintColor = colors.black,
    application = nil,
    closing = false,
    maximized = false,
    maximizable = true,
    showTitleBar = true,
    __init = function(x, y, width, height)
        _ENV.CCEventHandler("CCWindow")
        self.window = window.create(term.native(), x, y, width, height)
        self.frame = {}
        self.frame.x = x
        self.frame.y = y
        self.frame.width = width
        self.frame.height = height
        self.defaultFrame = {}
        self.defaultFrame.x = self.frame.x
        self.defaultFrame.y = self.frame.y
        self.defaultFrame.width = self.frame.width
        self.defaultFrame.height = self.frame.height
        self.addEvent("mouse_drag", self.moveToPos)
        self.addEvent("mouse_click", self.startDrag)
        self.addEvent("mouse_up", self.stopDrag)
        self.addEvent("mouse_scroll", self.scroll)
        CCGraphics.initGraphics(self.window)
        self.redraw()
    end,
    redrawTitleBar = function()
        if self.showTitleBar then
            local color = (self.application ~= nil and not CCWindowRegistry.isWinOnTop(self)) and CCKitGlobals.inactiveTitleBarColor or CCKitGlobals.titleBarColor
            CCGraphics.drawLine(self.window, 0, 0, self.frame.width-1, false, color, CCKitGlobals.titleBarTextColor)
            CCGraphics.setPixelColors(self.window, self.frame.width-1, 0, colors.white, colors.red)
            CCGraphics.setCharacter(self.window, self.frame.width-1, 0, "X")
            if self.maximizable then
                CCGraphics.setPixelColors(self.window, self.frame.width-2, 0, colors.white, colors.lime)
                if self.maximized then CCGraphics.setCharacter(self.window, self.frame.width-2, 0, "o")
                else CCGraphics.setCharacter(self.window, self.frame.width-2, 0, "O") end
            end
        else
            CCGraphics.drawLine(self.window, 0, 0, self.frame.width, false, CCKitGlobals.windowBackgroundColor)
        end
        self.setTitle(self.title)
    end,
    redraw = function(setapp, fullRedraw)
        if setapp == nil then setapp = true end
        if fullRedraw == nil then fullRedraw = true end
        if not self.closing then
            self.window.setCursorBlink(false)
            self.redrawTitleBar()
            if fullRedraw then
                CCGraphics.drawBox(self.window, 0, 1, self.frame.width, self.frame.height - 1, CCKitGlobals.windowBackgroundColor)
                if self.viewController ~= nil then self.viewController.view.draw() end
            end
            if self.application ~= nil and setapp then 
                CCWindowRegistry.setAppTop(self.application.name)
                if not CCWindowRegistry.isAppOnTop(self.application.name) then error("Not on top!") end
                os.queueEvent("redraw_all")
                --os.pullEvent("redraw_all")
            end
        end
    end,
    moveToPos = function(button, px, py)
        --print("moving")
        if button == 1 and self.isDragging then
            if not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name) then 
                self.redraw() 
                CCWindowRegistry.setAppTop(self.application.name)
                CCWindowRegistry.setWinTop(self)
            end
            if CCKernel ~= nil then 
                CCKernel.broadcast("redraw_all", self.application.name)
                os.queueEvent("done_redraw")
                os.pullEvent("done_redraw")
            end
            CCWindowRegistry.moveWin(self, px - self.mouseOffset, py)
            --self.window.setVisible(false)
            self.window.reposition(px - self.mouseOffset, py)
            if self.viewController ~= nil then self.viewController.view.updateAbsolutes(px - self.frame.x - self.mouseOffset, py - self.frame.y) end
            --CCGraphics.redrawScreen(self.window)
            --self.redraw(true, false)
            self.redrawTitleBar()
            CCGraphics.drawFilledBox(self.frame.x, self.frame.y, self.frame.x + self.frame.width, self.frame.y + self.frame.height, self.repaintColor)
            self.frame.x = px - self.mouseOffset
            self.frame.y = py
            if not CCKitGlobals.liveWindowMove then
                paintutils.drawBox(self.frame.x, self.frame.y, self.frame.x + self.frame.width - 1, self.frame.y + self.frame.height - 1, CCKitGlobals.windowBackgroundColor)
            else
                --self.window.setVisible(true)
                --self.window.redraw()
            end
            return true
        end
        return false
    end,
    startDrag = function(button, px, py)
        if not CCWindowRegistry.rayTest(self, px, py) then return false end
        if button == 1 then
            if not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name) then
                self.redraw()
                CCWindowRegistry.setAppTop(self.application.name)
                CCWindowRegistry.setWinTop(self)
            end
            if py == self.frame.y and px >= self.frame.x and px < self.frame.x + self.frame.width - 2 then
                self.isDragging = true 
                self.mouseOffset = px - self.frame.x
                self.window.setVisible(CCKitGlobals.liveWindowMove)
                return true
            elseif py == self.frame.y and px == self.frame.x + self.frame.width - 2 and self.maximizable then
                if self.maximized then
                    self.frame.x = self.defaultFrame.x
                    self.frame.y = self.defaultFrame.y
                    self.frame.width = self.defaultFrame.width
                    self.frame.height = self.defaultFrame.height
                    self.maximized = false
                    self.resize(self.frame.width, self.frame.height)
                    self.application.setBackgroundColor(self.application.backgroundColor)
                else
                    self.defaultFrame.x = self.frame.x
                    self.defaultFrame.y = self.frame.y
                    self.defaultFrame.width = self.frame.width
                    self.defaultFrame.height = self.frame.height
                    self.frame.x = 1
                    self.frame.y = 1
                    self.maximized = true
                    self.resize(term.native().getSize())
                end
                self.application.log.debug(tostring(self.defaultFrame.width))
                return true
            elseif py == self.frame.y and px == self.frame.x + self.frame.width - 1 then
                CCGraphics.endGraphics(self.window)
                self.window = nil
                self.closing = true
                if self.viewController ~= nil then for k,v in pairs(self.viewController.view.subviews) do
                    self.viewController.view.deregisterSubview(v)
                end end
                os.queueEvent("closed_window", self.name)
                return true
            end
        end
        return false
    end,
    stopDrag = function(button, px, py)
        --if not CCWindowRegistry.rayTest(self, px, py) then return false end
        if button == 1 and self.isDragging then 
            if not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name) then 
                self.redraw() 
                CCWindowRegistry.setAppTop(self.application.name)
                CCWindowRegistry.setWinTop(self)
            end
            self.moveToPos(button, px, py)
            self.isDragging = false
            self.window.setVisible(true)
            return true
        end
        return false
    end,
    scroll = function(direction, px, py)
        if CCWindowRegistry.rayTest(self, px, py) and (not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name)) then
            self.redraw() 
            CCWindowRegistry.setAppTop(self.application.name)
            CCWindowRegistry.setWinTop(self)
        end
        return false
    end,
    resize = function(newWidth, newHeight)
        self.frame.width = newWidth
        self.frame.height = newHeight
        self.window.reposition(self.frame.x, self.frame.y, self.frame.width, self.frame.height)
        CCGraphics.resizeWindow(self.window, newWidth, newHeight)
        CCWindowRegistry.resizeWin(self, newWidth, newHeight)
        self.redraw()
    end,
    setTitle = function(str)
        self.title = str
        CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(str)) / 2), 0, str)
    end,
    setViewController = function(vc, app)
        self.viewController = vc
        self.application = app
        CCWindowRegistry.registerWindow(self)
        self.viewController.loadView(self, self.application)
        self.viewController.viewDidLoad()
        self.viewController.view.draw()
        self.redraw()
    end,
    registerObject = function(obj)
        if self.application ~= nil then
            self.application.registerObject(obj, obj.name, false)
        end
    end,
    close = function()
        if self.viewController ~= nil then self.viewController.dismiss() end
        os.queueEvent("closed_window", self.name)
    end,
    present = function(newwin)
        newwin.redraw()
        self.application.registerObject(newwin, newwin.name)
    end
}