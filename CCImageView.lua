-- CCImageView.lua
-- CCKit
--
-- This file creates the CCImageView class, which inherits from CCView and
-- draws a CCGraphics image into the view.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
os.loadAPI(CCKitGlobals.CCKitDir.."/CCView.lua")

function CCImageView(x, y, image)
    local retval = CCView.CCView(x, y, image.termWidth, image.termHeight)
    retval.image = image
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawCapture(self.window, 0, 0, self.image)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    return retval
end

--os.unloadAPI("CCView")