-- CCView.lua
-- CCKit
--
-- This file creates the CCView class, which handles initializing, drawing,
-- and displaying information inside a CCWindow.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCGraphics")

function CCView(x, y, width, height)
    local retval = {}
    retval.class = "CCView"
    retval.parentWindowName = nil
    retval.parentWindow = nil
    retval.application = nil
    retval.window = nil
    retval.hasEvents = false
    retval.events = {}
    retval.subviews = {}
    retval.backgroundColor = colors.white
    retval.frame = {x = x, y = y, width = width, height = height, absoluteX = x, absoluteY = y}
    function retval:setBackgroundColor(color)
        self.backgroundColor = color
        self:draw()
    end
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:addSubview(view)
        if self.application == nil then error("Parent view must be added before subviews", 2) end
        if view == nil then self.application.log:error("Cannot add nil subview", 2) end
        if view.hasEvents then self.application:registerObject(view, view.name, false) end
        view:setParent(self.window, self.application, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY)
        table.insert(self.subviews, view)
    end
    function retval:setParent(parent, application, name, absoluteX, absoluteY)
        self.parentWindow = parent
        self.parentWindowName = name
        self.application = application
        self.frame.absoluteX = absoluteX + self.frame.x
        self.frame.absoluteY = absoluteY + self.frame.y
        self.window = window.create(self.parentWindow, self.frame.x+1, self.frame.y+1, self.frame.width, self.frame.height)
        CCGraphics.initGraphics(self.window)
    end
    function retval:updateAbsolutes(addX, addY)
        --print(addX .. ", " .. addY)
        self.frame.absoluteX = self.frame.absoluteX + addX
        self.frame.absoluteY = self.frame.absoluteY + addY
        for k,view in pairs(self.subviews) do view:updateAbsolutes(addX, addY) end
    end
    function retval:deregisterSubview(view)
        if view.hasEvents and self.application ~= nil then
            self.application:deregisterObject(view.name)
            for k,v in pairs(view.subviews) do view:deregisterSubview(v) end
        end
    end
    return retval
end
