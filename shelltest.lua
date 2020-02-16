local CCKit = require "CCKit"

local function ShellView(x, y, width, height)
    local retval = CCKit.CCView(x, y, width, height)
    retval.coro = coroutine.create(function() os.run(setmetatable({}, {__index = _G}), "/rom/programs/shell.lua") end)
    retval.filter = nil
    function retval:draw() self.window.redraw() end
    function retval:resumeCoro(...)
        if self.filter == nil or self.filter == ... then
            local old = term.redirect(self.window)
            local ok
            ok, self.filter = coroutine.resume(self.coro, ...)
            term.redirect(old)
            self.window.redraw()
            if not ok or coroutine.status(self.coro) == "dead" then end
        end
    end
    return retval
end

local function TabView(x, y, width)
    local retval = CCKit.CCKitGlobals.multipleInheritance(CCKit.CCView(x, y, width, 1), CCKit.CCEventHandler("TabView"))
    retval.count = 1
    retval.selected = 1
    function retval:draw()
        if self.parentWindow ~= nil then
            for i = 0, self.count-1 do
                local color = colors.gray
                if i == self.selected - 1 then color = colors.gray
                else color = colors.lightGray end
                CCKit.CCGraphics.drawLine(self.window, math.round((width / self.count) * i), 0, math.round((width / self.count)), false, color, colors.black)
            end
        end
    end
    function retval:click(button, px, py)
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 then 
            self.selected = math.floor((px - bx) / (width / self.count)) + 1
            os.queueEvent("tab_selected", self.selected)
            self:draw()
            return true
        end
        return false
    end
    retval:addEvent("mouse_click", retval.click)
    return retval
end

local function ShellViewController()
    local retval = CCKit.CCKitGlobals.multipleInheritance(CCKit.CCViewController(), CCKit.CCEventHandler("ShellViewController"))
    retval.views = {ShellView(0, 1, 42, 12)}
    retval.tabbar = TabView(0, 0, 42)
    retval.currentView = 1
    retval.isCtrlDown = false
    retval.isShiftDown = false
    function retval:viewDidLoad()
        self.view:addSubview(self.tabbar)
        self.view:addSubview(self.views[1])
        self.views[1]:resumeCoro()
        self.window:registerObject(self)
    end
    function retval:viewWillDisappear()
        for _,v in ipairs(self.views) do self.view:deregisterSubview(v) end --?
    end
    retval:addEvent("key", function(self, ...)
        if not CCKit.CCWindowRegistry.isWinOnTop(self.window) then return false end
        if ... == keys.leftCtrl or ... == keys.rightCtrl then self.isCtrlDown = true
        elseif ... == keys.leftShift or ... == keys.rightShift then self.isShiftDown = true
        elseif self.isCtrlDown and not self.isShiftDown and ... == keys.n then
            table.insert(self.views, ShellView(0, 1, 42, 12))
            self.currentView = #self.views
            self.view:addSubview(self.views[self.currentView])
            self.tabbar.count = #self.views
            self.tabbar.selected = #self.views
            self.tabbar:draw()
        elseif self.isCtrlDown and self.isShiftDown and ... == keys.n then
            local win = CCKit.CCWindow(self.window.frame.x+1, self.window.frame.y+1, 42, 14)
            win:setTitle("CraftOS Shell")
            win:setViewController(ShellViewController(), self.application)
            self.window:present(win)
        end
        return self.views[self.currentView]:resumeCoro("key", ...)
    end)
    retval:addEvent("key_up", function(self, ...)
        if not CCKit.CCWindowRegistry.isWinOnTop(self.window) then return false end
        if ... == keys.leftCtrl or ... == keys.rightCtrl then self.isCtrlDown = false
        elseif ... == keys.leftShift or ... == keys.rightShift then self.isShiftDown = false end
        return self.views[self.currentView]:resumeCoro("key_up", ...)
    end)
    retval:addEvent("char", function(self, ...) 
        if not CCKit.CCWindowRegistry.isWinOnTop(self.window) then return false end
        return self.views[self.currentView]:resumeCoro("char", ...) 
    end)
    retval:addEvent("tab_selected", function(self, tab)
        self.currentView = tab
        self.views[tab]:draw()
    end)
    return retval
end

CCKit.CCMain(5, 3, 42, 14, "CraftOS Shell", ShellViewController, colors.blue)