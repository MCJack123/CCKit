-- CCTextView.lua
-- CCKit
--
-- This creates a subclass of CCView that displays multi-line text.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCView.lua")
os.loadAPI("CCKit/CCLineBreakMode.lua")

function CCTextView(x, y, width, height)
    local retval = CCView.CCView(x, y, width, height)
    retval.textColor = colors.black
    retval.text = ""
    retval.lineBreakMode = CCLineBreakMode.byWordWrapping
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, self.textColor)
            local lines = CCLineBreakMode.divideText(self.text, self.frame.width, self.lineBreakMode)
            --print(textutils.serialize(lines))
            if table.count(lines) > self.frame.height then
                local newlines = {}
                if bit.band(self.lineBreakMode, CCLineBreakMode.byTruncatingHead) then
                    for i=table.count(lines)-self.frame.height,table.count(lines) do table.insert(newlines, lines[i]) end
                else
                    for i=1,table.count(lines) do table.insert(newlines, lines[i]) end
                end
                lines = newlines
            end
            for k,v in pairs(lines) do CCGraphics.setString(self.window, 0, k-1, v) end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setText(text)
        self.text = text
        self:draw()
    end
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    function retval:setLineBreakMode(mode)
        self.lineBreakMode = mode
        self:draw()
    end
    return retval
end
    