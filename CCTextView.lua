-- CCTextView.lua
-- CCKit
--
-- This creates a subclass of CCView that displays multi-line text.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCView = require "CCView"
local CCLineBreakMode = require "CCLineBreakMode"
local CCGraphics = require "CCGraphics"

local function table_count(tab)
    local i = 0
    for k,v in pairs(tab) do i = i + 1 end
    return i
end

return class "CCTextView" {extends = CCView} {
    textColor = CCKitGlobals.defaultTextColor,
    text = "",
    lineBreakMode = CCLineBreakMode.byWordWrapping,
    draw = function()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, self.textColor)
            local lines = CCLineBreakMode.divideText(self.text, self.frame.width, self.lineBreakMode)
            --print(textutils.serialize(lines))
            if table_count(lines) > self.frame.height then
                local newlines = {}
                if bit.band(self.lineBreakMode, CCLineBreakMode.byTruncatingHead) then
                    for i=table_count(lines)-self.frame.height,table_count(lines) do table.insert(newlines, lines[i]) end
                else
                    for i=1,table_count(lines) do table.insert(newlines, lines[i]) end
                end
                lines = newlines
            end
            for k,v in pairs(lines) do CCGraphics.setString(self.window, 0, k-1, v) end
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end,
    setText = function(text)
        self.text = text
        self.draw()
    end,
    setTextColor = function(color)
        self.textColor = color
        self.draw()
    end,
    setLineBreakMode = function(mode)
        self.lineBreakMode = mode
        self.draw()
    end
}