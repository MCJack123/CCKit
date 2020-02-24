-- CCScrollView.lua
-- CCKit
--
-- This creates the CCScrollView class, which is used to display subviews
-- that would otherwise be too tall for the area.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"
local CCView = require "CCView"
local CCEventHandler = require "CCEventHandler"
local CCControl = require "CCControl"
local CCWindowRegistry = require "CCWindowRegistry"

local CCScrollBar = class "CCScrollBar" {extends = CCControl} { -- may make this public later
    buttonColor = CCKitGlobals.buttonColor,
    sliderValue = 0,
    __init = function(x, y, height)
        _ENV.CCControl(x, y, 1, height)
        self.setAction(function() return end, self)
        self.addEvent("mouse_click", self.onMouseDown)
        self.addEvent("mouse_drag", self.onDrag)
    end,
    setValue = function(value)
        self.sliderValue = value
        self.draw()
    end,
    onMouseDown = function(button, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.isEnabled then 
            self.isSelected = true
            self.onDrag(button, px, py)
            return true
        end
        return false
    end,
    onDrag = function(button, px, py)
        --if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if self.isSelected and button == 1 then
            if py < self.frame.absoluteY then self.sliderValue = 0
            elseif py > self.frame.absoluteY + self.frame.height - 1 then self.sliderValue = self.frame.height - 1
            else self.sliderValue = py - self.frame.absoluteY end
            self.draw()
            os.queueEvent("slider_dragged", self.name, self.sliderValue)
            return true
        end
        return false
    end,
    draw = function()
        if self.parentWindow ~= nil then
            CCGraphics.drawLine(self.window, 0, 0, self.frame.height, true, self.backgroundColor)
            if self.isSelected then CCGraphics.setPixelColors(self.window, 0, self.sliderValue, CCKitGlobals.buttonSelectedColor, CCKitGlobals.buttonSelectedColor)
            else CCGraphics.setPixelColors(self.window, 0, self.sliderValue, self.buttonColor, self.buttonColor) end
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end
}

local function getWindowCapture(view)
    local image = CCGraphics.captureRegion(view.window, 0, 0, view.frame.width, view.frame.height)
    for _,v in pairs(view.subviews) do
        local subimage = getWindowCapture(v)
        for x,r in pairs(subimage) do if type(x) ~= "string" then 
            if image[x+v.frame.x] == nil then image[x+v.frame.x] = {} end
            for y,p in pairs(r) do image[x+v.frame.x][y+v.frame.y] = p end 
        end end
    end
    return image
end

local function resizeImage(image, x, y, width, height, default)
    local retval = {width = width * 2, height = height * 3, termWidth = width, termHeight = height}
    for px=0,width-1 do
        if retval[px] == nil then retval[px] = {} end
        for py=0,height-1 do
            --print("creating pixel " .. x .. ", " .. y)
            if retval[px][py] == nil then
                retval[px][py] = {}
                retval[px][py].fgColor = default -- Text color
                retval[px][py].bgColor = default -- Background color
                retval[px][py].pixelCode = 0 -- Stores the data as a 6-bit integer (tl, tr, cl, cr, bl, br)
                retval[px][py].useCharacter = false -- Whether to print a custom character
                retval[px][py].character = " " -- Custom character
            end
        end
    end
    for dx,r in pairs(image) do if type(dx) ~= "string" then 
        if retval[dx-x] == nil then retval[dx-x] = {} end
        for dy,p in pairs(r) do retval[dx-x][dy-y] = p end
    end end
    return retval
end

local function math_round(num) if num % 1 < 0.5 then return math.floor(num) else return math.ceil(num) end end

return class "CCScrollView" {extends = {CCView, CCEventHandler}} {
    currentOffset = 0,
    lastAbsolute = 0,
    __init = function(x, y, width, height, innerHeight)
        _ENV.CCView(x, y, width, height)
        _ENV.CCEventHandler("CCScrollView")
        self.contentHeight = innerHeight
        self.renderWindow = window.create(term.native(), 1, 1, width-1, innerHeight, false)
        self.scrollBar = CCScrollBar(width-1, 0, height)
        CCGraphics.initGraphics(self.renderWindow)
        self.addEvent("mouse_scroll", self.scroll)
        self.addEvent("slider_dragged", self.didScroll)
    end,
    draw = function() -- won't work with any views that don't use CCGraphics (please use CCGraphics)
        if self.parentWindow ~= nil then
            self.scrollBar.sliderValue = math_round(self.currentOffset * (self.frame.height / (self.contentHeight - self.frame.height + 1)))
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            --self.renderWindow.setVisible(true)
            CCGraphics.drawBox(self.renderWindow, 0, 0, self.frame.width-1, self.contentHeight, self.backgroundColor)
            local image = CCGraphics.captureRegion(self.renderWindow, 0, 0, self.frame.width-1, self.contentHeight)
            for _,v in pairs(self.subviews) do
                v.updateAbsolutes(0, (self.frame.absoluteY - self.currentOffset) - self.lastAbsolute)
                v.draw()
                if v.class ~= "CCScrollBar" then
                    local subimage = getWindowCapture(v)
                    for x,r in pairs(subimage) do if type(x) ~= "string" then 
                        if image[x+v.frame.x] == nil then image[x+v.frame.x] = {} end
                        for y,p in pairs(r) do image[x+v.frame.x][y+v.frame.y] = p end
                    end end
                end
            end
            image = resizeImage(image, 0, self.currentOffset, self.frame.width-1, self.frame.height, self.backgroundColor)
            --self.application.log.debug(textutils.serialize(image))
            CCGraphics.drawCapture(self.window, 0, 0, image)
            self.scrollBar.draw()
            self.lastAbsolute = self.frame.absoluteY - self.currentOffset
            --self.renderWindow.setVisible(false)
        end
    end,
    scroll = function(direction, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if px >= self.frame.absoluteX and py >= self.frame.absoluteY and px < self.frame.absoluteX + self.frame.width and py < self.frame.absoluteY + self.frame.height and self.currentOffset + direction <= self.contentHeight - self.frame.height and self.currentOffset + direction >= 0 then
            self.currentOffset = self.currentOffset + direction
            self.draw()
            return true
        end
        return false
    end,
    addSubview = function(view)
        if self.application == nil then error("Parent view must be added before subviews", 2) end
        if view == nil then self.application.log.error("Cannot add nil subview", 2) end
        if view.hasEvents then self.application.registerObject(view, view.name, false) end
        if view.class == "CCScrollBar" then view.setParent(self.window, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY, self)
        else view.setParent(self.renderWindow, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY - self.currentOffset, self) end
        table.insert(self.subviews, view)
    end,
    setParent = function(parent, application, name, absoluteX, absoluteY, superview)
        self.parentWindow = parent
        self.parentWindowName = name
        self.application = application
        self.frame.absoluteX = absoluteX + self.frame.x
        self.frame.absoluteY = absoluteY + self.frame.y
        self.superview = superview
        self.lastAbsolute = self.frame.absoluteY - self.currentOffset
        self.window = window.create(self.parentWindow, self.frame.x+1, self.frame.y+1, self.frame.width, self.frame.height)
        CCGraphics.initGraphics(self.window)
        self.addSubview(self.scrollBar)
    end,
    didScroll = function(name, value)
        self.application.log.debug("Slider dragged")
        if name == self.scrollBar.name then
            self.currentOffset = math_round(((self.contentHeight - self.frame.height + 1) / self.frame.height) * value)
            self.draw()
            return true
        end
        return false
    end
}
