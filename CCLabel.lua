-- CCLabel.lua
-- CCKit
--
-- This is a subclass of CCView that displays text on screen.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCView.lua")

function CCLabel(x, y, text)
    local retval = CCView.CCView(x, y, string.len(text), 1)
    retval.text = text
    retval.textColor = colors.black
    function retval:draw()
        if self.parentWindow ~= nil then
            for px=0,self.frame.width-1 do CCGraphics.setPixelColors(self.window, px, 0, self.textColor, self.backgroundColor) end
            CCGraphics.setString(self.window, 0, 0, self.text)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    return retval
end