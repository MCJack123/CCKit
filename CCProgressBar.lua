-- CCProgressBar.lua
-- CCKit
--
-- This creates a subclass of CCView called CCProgressBar, which displays a
-- bar showing progress.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCGraphics = require "CCGraphics"
local CCView = require "CCView"

return class "CCProgressBar" {extends = CCView} {
    backgroundColor = colors.lightGray,
    foregroundColor = colors.yellow,
    progress = 0.0,
    indeterminate = false,
    __init = function(x, y, width)
        _ENV.CCView(x, y, width, 1)
    end,
    draw = function()
        if self.parentWindow ~= nil then
            if self.indeterminate then
                local i = 0
                while i < self.frame.width do
                    local c = self.backgroundColor
                    if i / 2 == 0.0 then c = self.foregroundColor end
                    CCGraphics.setColor(self.window, i, 0, nil, c)
                    i=i+1
                end
            else
                CCGraphics.drawLine(self.window, 0, 0, self.frame.width, false, self.backgroundColor)
                CCGraphics.drawLine(self.window, 0, 0, math.floor(self.frame.width * self.progress), false, self.foregroundColor)
            end
            for k,v in pairs(self.subviews) do v.draw() end
        end
    end,
    setProgress = function(progress)
        if progress > 1 then progress = 1 end
        self.progress = progress
        self.draw()
    end,
    setIndeterminate = function(id)
        self.indeterminate = id
        self.draw()
    end
}