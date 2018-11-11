-- CCViewController.lua
-- CCKit
--
-- This file creates the CCViewController class, which is used in a CCWindow
-- to control the window contents. This can be subclassed to create custom
-- controllers for your application.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCView.lua")

function CCViewController()
    local retval = {}
    retval.view = {}
    retval.parentWindow = nil
    retval.currentApplication = nil
    function retval:loadView(win, app)
        --print("loaded view " .. win.name)
        self.parentWindow = win
        self.currentApplication = app
        local width, height = win.window.getSize()
        self.view = CCView.CCView(0, 1, width, height - 1)
        self.view:setParent(self.parentWindow.window, self.currentApplication, self.parentWindow.name, retval.parentWindow.frame.x, retval.parentWindow.frame.y)
    end
    retval.superLoadView = retval.loadView
    function retval:viewDidLoad()
        -- override this to create custom subviews
    end
    return retval
end

--os.unloadAPI("CCView")