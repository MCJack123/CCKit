-- CCScrollView.lua
-- CCKit
--
-- This creates the CCScrollView class, which is used to display subviews
-- that would otherwise be too tall for the area.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCGraphics")
local CCView = CCRequire("CCView")
local CCEventHandler = CCRequire("CCEventHandler")
local CCControl = CCRequire("CCControl")
loadAPI("CCWindowRegistry")

local function CCScrollBar(x, y, height) -- may make this public later
    local retval = CCControl(x, y, 1, height)
    retval.class = "CCScrollBar"
    retval.buttonColor = CCKitGlobals.buttonColor
    retval.sliderValue = 0
    function retval:setValue(value)
        self.sliderValue = value
        self:draw()
    end
    function retval:onMouseDown(button, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.isEnabled then 
            self.isSelected = true
            self:onDrag(button, px, py)
            return true
        end
        return false
    end
    function retval:onDrag(button, px, py)
        --if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if self.isSelected and button == 1 then
            if py < self.frame.absoluteY then self.sliderValue = 0
            elseif py > self.frame.absoluteY + self.frame.height - 1 then self.sliderValue = self.frame.height - 1
            else self.sliderValue = py - self.frame.absoluteY end
            self:draw()
            os.queueEvent("slider_dragged", self.name, self.sliderValue)
            return true
        end
        return false
    end
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawLine(self.window, 0, 0, self.frame.height, true, self.backgroundColor)
            if self.isSelected then CCGraphics.setPixelColors(self.window, 0, self.sliderValue, CCKitGlobals.buttonSelectedColor, CCKitGlobals.buttonSelectedColor)
            else CCGraphics.setPixelColors(self.window, 0, self.sliderValue, self.buttonColor, self.buttonColor) end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    retval:setAction(function() return end, self)
    retval:addEvent("mouse_click", retval.onMouseDown)
    retval:addEvent("mouse_drag", retval.onDrag)
    return retval
end

local function getWindowCapture(view)
    local image = CCGraphics.captureRegion(view.window, 0, 0, view.frame.width, view.frame.height)
    for k,v in pairs(view.subviews) do
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

function math.round(num) if num % 1 < 0.5 then return math.floor(num) else return math.ceil(num) end end

function CCScrollView(x, y, width, height, innerHeight)
    local retval = multipleInheritance(CCView(x, y, width, height), CCEventHandler("CCScrollView"))
    retval.contentHeight = innerHeight
    retval.currentOffset = 0
    retval.renderWindow = window.create(term.native(), 1, 1, width-1, innerHeight, false)
    retval.scrollBar = CCScrollBar(width-1, 0, height)
    retval.lastAbsolute = 0
    CCGraphics.initGraphics(retval.renderWindow)
    function retval:draw() -- won't work with any views that don't use CCGraphics (please use CCGraphics)
        if self.parentWindow ~= nil then
            self.scrollBar.sliderValue = math.round(self.currentOffset * (self.frame.height / (self.contentHeight - self.frame.height + 1)))
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            --self.renderWindow.setVisible(true)
            CCGraphics.drawBox(self.renderWindow, 0, 0, self.frame.width-1, self.contentHeight, self.backgroundColor)
            local image = CCGraphics.captureRegion(self.renderWindow, 0, 0, self.frame.width-1, self.contentHeight)
            for k,v in pairs(self.subviews) do 
                v:updateAbsolutes(0, (self.frame.absoluteY - self.currentOffset) - self.lastAbsolute)
                v:draw()
                if v.class ~= "CCScrollBar" then
                    local subimage = getWindowCapture(v)
                    for x,r in pairs(subimage) do if type(x) ~= "string" then 
                        if image[x+v.frame.x] == nil then image[x+v.frame.x] = {} end
                        for y,p in pairs(r) do image[x+v.frame.x][y+v.frame.y] = p end 
                    end end
                end
            end
            image = resizeImage(image, 0, self.currentOffset, self.frame.width-1, self.frame.height, self.backgroundColor)
            --self.application.log:debug(textutils.serialize(image))
            CCGraphics.drawCapture(self.window, 0, 0, image)
            self.scrollBar:draw()
            self.lastAbsolute = self.frame.absoluteY - self.currentOffset
            --self.renderWindow.setVisible(false)
        end
    end
    function retval:scroll(direction, px, py)
        if not CCWindowRegistry.rayTest(self.application.objects[self.parentWindowName], px, py) then return false end
        if px >= self.frame.absoluteX and py >= self.frame.absoluteY and px < self.frame.absoluteX + self.frame.width and py < self.frame.absoluteY + self.frame.height and self.currentOffset + direction <= self.contentHeight - self.frame.height and self.currentOffset + direction >= 0 then
            self.currentOffset = self.currentOffset + direction
            self:draw()
            return true
        end
        return false
    end
    function retval:addSubview(view)
        if self.application == nil then error("Parent view must be added before subviews", 2) end
        if view == nil then self.application.log:error("Cannot add nil subview", 2) end
        if view.hasEvents then self.application:registerObject(view, view.name, false) end
        if view.class == "CCScrollBar" then view:setParent(self.window, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY)
        else view:setParent(self.renderWindow, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY - self.currentOffset) end
        table.insert(self.subviews, view)
    end
    function retval:setParent(parent, application, name, absoluteX, absoluteY)
        self.parentWindow = parent
        self.parentWindowName = name
        self.application = application
        self.frame.absoluteX = absoluteX + self.frame.x
        self.frame.absoluteY = absoluteY + self.frame.y
        self.lastAbsolute = self.frame.absoluteY - self.currentOffset
        self.window = window.create(self.parentWindow, self.frame.x+1, self.frame.y+1, self.frame.width, self.frame.height)
        CCGraphics.initGraphics(self.window)
        self:addSubview(self.scrollBar)
    end
    function retval:didScroll(name, value)
        self.application.log:debug("Slider dragged")
        if name == self.scrollBar.name then
            self.currentOffset = math.round(((self.contentHeight - self.frame.height + 1) / self.frame.height) * value)
            self:draw()
            return true
        end
        return false
    end
    retval:addEvent("mouse_scroll", retval.scroll)
    retval:addEvent("slider_dragged", retval.didScroll)
    return retval
end
