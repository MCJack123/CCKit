-- CCProgressBar.lua
-- CCKit
--
-- This creates a subclass of CCView called CCProgressBar, which displays a
-- bar showing progress.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
os.loadAPI(CCKitGlobals.CCKitDir.."/CCView.lua")

function CCProgressBar(x, y, width)
    local retval = CCView.CCView(x, y, width, 1)
    retval.backgroundColor = colors.lightGray
    retval.foregroundColor = colors.yellow
    retval.progress = 0.0
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawLine(self.window, 0, 0, self.frame.width, false, self.backgroundColor)
            CCGraphics.drawLine(self.window, 0, 0, math.floor(self.frame.width * self.progress), false, self.foregroundColor)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setProgress(progress)
        if progress > 1 then progress = 1 end
        self.progress = progress
        self:draw()
    end
    return retval
end
