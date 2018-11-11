-- CCWindow.lua
-- CCKit
--
-- This file creates the CCWindow class, which handles the actions required
-- for a window to be displayed on screen.
--
-- Copyright (c) 2018 JackMacWindows.

if CCGraphics == nil then os.loadAPI("CCKit/CCGraphics.lua") end

-- Constants for the colors of the window
local titleBarColor = colors.yellow
local titleBarTextColor = colors.black
local windowBackgroundColor = colors.white

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
    local retval = {}
    retval.name = string.random(8)
    retval.class = "CCWindow"
    retval.window = window.create(term.native(), x, y, width, height)
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
    retval.currentApplication = nil
    retval.closing = false
    retval.maximized = false
    function retval:redraw()
        if not self.closing then
            self.window.setCursorBlink(false)
            CCGraphics.drawLine(retval.window, 0, 0, self.frame.width-1, false, titleBarColor, titleBarTextColor)
            CCGraphics.setPixelColors(retval.window, self.frame.width-1, 0, colors.white, colors.red)
            CCGraphics.setPixelColors(retval.window, self.frame.width-2, 0, colors.white, colors.lime)
            CCGraphics.setCharacter(retval.window, self.frame.width-1, 0, "X")
            if self.maximized then CCGraphics.setCharacter(retval.window, self.frame.width-2, 0, "o")
            else CCGraphics.setCharacter(retval.window, self.frame.width-2, 0, "O") end
            CCGraphics.drawBox(retval.window, 0, 1, self.frame.width, self.frame.height - 1, windowBackgroundColor)
            self:setTitle(self.title)
            if self.viewController ~= nil then self.viewController.view:draw() end
        end
    end
    function retval:moveToPos(button, px, py)
        --print("moving")
        if button == 1 and self.isDragging then
            CCGraphics.drawFilledBox(self.frame.x, self.frame.y, self.frame.x + self.frame.width, self.frame.y + self.frame.height, self.repaintColor)
            self.window.reposition(px - self.mouseOffset, py)
            if self.viewController ~= nil then self.viewController.view:updateAbsolutes(px - self.frame.x - self.mouseOffset, py - self.frame.y) end
            --CCGraphics.redrawScreen(self.window)
            --self:redraw()
            self.frame.x = px - self.mouseOffset
            self.frame.y = py
            return true
        end
        return false
    end
    function retval:startDrag(button, px, py)
        if button == 1 then
            if py == self.frame.y and px >= self.frame.x and px < self.frame.x + self.frame.width - 2 then 
                self.isDragging = true 
                self.mouseOffset = px - self.frame.x
                return true
            elseif py == self.frame.y and px == self.frame.x + self.frame.width - 2 then
                if self.maximized then
                    self.frame.x = self.defaultFrame.x
                    self.frame.y = self.defaultFrame.y
                    self.frame.width = self.defaultFrame.width
                    self.frame.height = self.defaultFrame.height
                    self.maximized = false
                    self:resize(self.frame.width, self.frame.height)
                    self.currentApplication:setBackgroundColor(self.currentApplication.backgroundColor)
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
                self.currentApplication.log:debug(tostring(self.defaultFrame.width))
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
        if button == 1 and self.isDragging then 
            self:moveToPos(button, px, py) 
            self.isDragging = false
            return true
        end
        return false
    end
    function retval:resize(newWidth, newHeight)
        self.frame.width = newWidth
        self.frame.height = newHeight
        self.window.reposition(self.frame.x, self.frame.y, self.frame.width, self.frame.height)
        CCGraphics.resizeWindow(self.window, newWidth, newHeight)
        self:redraw()
    end
    function retval:setTitle(str)
        self.title = str
        CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(str)) / 2), 0, str)
    end
    function retval:setViewController(vc, app)
        self.viewController = vc
        self.currentApplication = app
        self.viewController:loadView(self, self.currentApplication)
        self.viewController:viewDidLoad()
        self.viewController.view:draw()
        --self:redraw()
    end
    function retval:registerObject(obj)
        if self.currentApplication ~= nil then
            self.currentApplication:registerObject(obj, obj.name, false)
        end
    end
    retval.events = {mouse_drag = {func = retval.moveToPos, self = retval.name}, mouse_click = {func = retval.startDrag, self = retval.name}, mouse_up = {func = retval.stopDrag, self = retval.name}}
    CCGraphics.initGraphics(retval.window)
    retval:redraw()
    return retval
end
