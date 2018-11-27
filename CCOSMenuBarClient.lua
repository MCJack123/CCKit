-- CCOSMenuBarClient.lua
-- CCKitOS
--
-- This file creates a class that allows applications to interface with the menu
-- bar of CCKitOS.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCWindowRegistry")
loadAPI("CCKernel")

function CCOSMenuBarClient(application)
    local retval = {}
    retval.application = application
    retval.menuBarPID = 0
    retval.menuEntries = {}
    retval.menuEntries[application.applicationName] = {}
    retval.menuEntries.order = {application.applicationName}
    retval.menuEntries.quit = {text = "Quit", func = function(app) app.isApplicationRunning = false end, self = retval.application}
    function retval:addMenu(name)
        if name == "order" or name == "quit" then return end
        self.menuEntries[name] = {}
        self:updateServer()
    end
    function retval:addAction(menu, title, func, object)
        table.insert(self.menuEntries[menu], {text = title, func = func, self = object})
        self:updateServer()
    end
    function retval:removeMenu(menu)
        for k,v in pairs(self.menuEntries.order) do if v == menu then
            table.remove(self.menuEntries.order, k)
            self.menuEntries[menu] = nil
            self:updateServer()
            break
        end end
    end
    function retval:removeAction(menu, title)
        for k,v in pairs(self.menuEntries[menu]) do if v.text == title then
            table.remove(self.menuEntries[menu], k)
            self:updateServer()
            break
        end end
    end
    function retval:searchForServer()
        if _G._PID == nil then return end
        CCKernel.broadcast("menu_bar_ping", _G._PID)
        os.pullEvent("menu_bar_ping")
        local ev, pid = os.pullEvent()
        if ev ~= "menu_bar_pong" or pid == 0 or pid == _G._PID then return end
        self.menuBarPID = pid
        self:registerApplication()
        self:updateServer()
    end
    function retval:registerApplication()
        if self.menuBarPID == 0 then self:searchForServer() end
        CCKernel.send(self.menuBarPID, "menu_bar_register", self.application.name)
    end
    function retval:updateServer()
        if self.menuBarPID == 0 then return end
        CCKernel.send(self.menuBarPID, "menu_bar_update", self.application.name, self.menuEntries)
    end
    retval:searchForServer()
    return retval, retval.menuBarPID == 0
end