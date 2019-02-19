-- CCWindow.lua
-- CCKit
--
-- This file creates the CCWindow class, which handles the actions required
-- for a window to be displayed on screen.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCGraphics")
local CCEventHandler = CCRequire("CCEventHandler")
if _G._PID ~= nil then loadAPI("CCKernel") end
loadAPI("CCWindowRegistry")

-- Constants for the colors of the window

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
  --math.randomseed(os.clock())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

function CCWindow(x, y, width, height)
    local retval = CCEventHandler("CCWindow")
    retval.window = window.create(term.current(), x, y, width, height)
    retval.title = ""
    retval.frame = {}
    retval.frame.x = x
    retval.frame.y = y
    retval.frame.width = width
    retval.frame.height = height
    retval.defaultFrame = {}
    retval.defaultFrame.x = retval.frame.x
    retval.defaultFrame.y = retval.frame.y
    retval.defaultFrame.width = retval.frame.width
    retval.defaultFrame.height = retval.frame.height
    retval.viewController = nil
    retval.isDragging = false
    retval.mouseOffset = 0
    retval.repaintColor = colors.black
    retval.application = nil
    retval.closing = false
    retval.maximized = false
    retval.maximizable = true
    retval.showTitleBar = true
    function retval:redraw(setapp)
        if setapp == nil then setapp = true end
        if not self.closing then
            self.window.setCursorBlink(false)
            if self.showTitleBar then
                CCGraphics.drawLine(retval.window, 0, 0, self.frame.width-1, false, CCKitGlobals.titleBarColor, CCKitGlobals.titleBarTextColor)
                CCGraphics.setPixelColors(retval.window, self.frame.width-1, 0, colors.white, colors.red)
                CCGraphics.setCharacter(retval.window, self.frame.width-1, 0, "X")
                if self.maximizable then
                    CCGraphics.setPixelColors(retval.window, self.frame.width-2, 0, colors.white, colors.lime)
                    if self.maximized then CCGraphics.setCharacter(retval.window, self.frame.width-2, 0, "o")
                    else CCGraphics.setCharacter(retval.window, self.frame.width-2, 0, "O") end
                end
            else
                CCGraphics.drawLine(retval.window, 0, 0, self.frame.width, false, CCKitGlobals.windowBackgroundColor)
            end
            CCGraphics.drawBox(retval.window, 0, 1, self.frame.width, self.frame.height - 1, CCKitGlobals.windowBackgroundColor)
            self:setTitle(self.title)
            if self.viewController ~= nil then self.viewController.view:draw() end
            if self.application ~= nil and setapp then 
                CCWindowRegistry.setAppTop(self.application.name)
                if not CCWindowRegistry.isAppOnTop(self.application.name) then error("Not on top!") end
            end
        end
    end
    function retval:moveToPos(button, px, py)
        --print("moving")
        if button == 1 and self.isDragging then
            if not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name) then 
                self:redraw() 
                CCWindowRegistry.setAppTop(self.application.name)
                CCWindowRegistry.setWinTop(self)
            end
            CCGraphics.drawFilledBox(self.frame.x, self.frame.y, self.frame.x + self.frame.width, self.frame.y + self.frame.height, self.repaintColor)
            if CCKernel ~= nil then 
                CCKernel.broadcast("redraw_all", self.application.name)
                os.queueEvent("done_redraw")
                os.pullEvent("done_redraw")
            end
            CCWindowRegistry.moveWin(self, px - self.mouseOffset, py)
            self.window.reposition(px - self.mouseOffset, py)
            if self.viewController ~= nil then self.viewController.view:updateAbsolutes(px - self.frame.x - self.mouseOffset, py - self.frame.y) end
            --CCGraphics.redrawScreen(self.window)
            --self:redraw()
            self.frame.x = px - self.mouseOffset
            self.frame.y = py
            --if not CCKitGlobals.liveWindowMove then paintutils.drawBox(self.frame.x, self.frame.y, self.frame.x + self.frame.width - 1, self.frame.y + self.frame.height - 1, CCKitGlobals.windowBackgroundColor) end
            return true
        end
        return false
    end
    function retval:startDrag(button, px, py)
        if not CCWindowRegistry.rayTest(self, px, py) then return false end
        if button == 1 and self.showTitleBar then
            if not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name) then 
                self:redraw() 
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
                    self:resize(self.frame.width, self.frame.height)
                    self.application:setBackgroundColor(self.application.backgroundColor)
                else
                    self.defaultFrame.x = self.frame.x
                    self.defaultFrame.y = self.frame.y
                    self.defaultFrame.width = self.frame.width
                    self.defaultFrame.height = self.frame.height
                    self.frame.x = 1
                    self.frame.y = 1
                    self.maximized = true
                    self:resize(term.native().getSize())
                end
                self.application.log:debug(tostring(self.defaultFrame.width))
                return true
            elseif py == self.frame.y and px == self.frame.x + self.frame.width - 1 then
                CCGraphics.endGraphics(self.window)
                self.window = nil
                self.closing = true
                if self.viewController ~= nil then for k,v in pairs(self.viewController.view.subviews) do
                    self.viewController.view:deregisterSubview(v)
                end end
                os.queueEvent("closed_window", self.name)
                return true
            end
        end
        return false
    end
    function retval:stopDrag(button, px, py)
        --if not CCWindowRegistry.rayTest(self, px, py) then return false end
        if button == 1 and self.isDragging then 
            if not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name) then 
                self:redraw() 
                CCWindowRegistry.setAppTop(self.application.name)
                CCWindowRegistry.setWinTop(self)
            end
            self:moveToPos(button, px, py) 
            self.isDragging = false
            self.window.setVisible(true)
            return true
        end
        return false
    end
    function retval:scroll(direction, px, py)
        if CCWindowRegistry.rayTest(self, px, py) and (not CCWindowRegistry.isWinOnTop(self) or not CCWindowRegistry.isAppOnTop(self.application.name)) then 
            self:redraw() 
            CCWindowRegistry.setAppTop(self.application.name)
            CCWindowRegistry.setWinTop(self)
        end
        return false
    end
    function retval:resize(newWidth, newHeight)
        self.frame.width = newWidth
        self.frame.height = newHeight
        self.window.reposition(self.frame.x, self.frame.y, self.frame.width, self.frame.height)
        CCGraphics.resizeWindow(self.window, newWidth, newHeight)
        CCWindowRegistry.resizeWin(self, newWidth, newHeight)
        self:redraw()
    end
    function retval:setTitle(str)
        self.title = str
        if self.showTitleBar then CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(str)) / 2), 0, str) end
    end
    function retval:setViewController(vc, app)
        self.viewController = vc
        self.application = app
        CCWindowRegistry.registerWindow(retval)
        self.viewController:loadView(self, self.application)
        self.viewController:viewDidLoad()
        self.viewController.view:draw()
        self:redraw()
    end
    function retval:registerObject(obj)
        if self.application ~= nil then
            self.application:registerObject(obj, obj.name, false)
        end
    end
    function retval:close()
        if self.viewController ~= nil then self.viewController:dismiss()
        else os.queueEvent("closed_window", self.name) end
    end
    function retval:present(newwin)
        newwin:redraw()
        self.application:registerObject(newwin, newwin.name)
    end
    retval:addEvent("mouse_drag", retval.moveToPos)
    retval:addEvent("mouse_click", retval.startDrag)
    retval:addEvent("mouse_up", retval.stopDrag)
    retval:addEvent("mouse_scroll", retval.scroll)
    CCGraphics.initGraphics(retval.window)
    retval:redraw()
    return retval
end
