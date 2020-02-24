-- CCImageView.lua
-- CCKit
--
-- This file creates the CCImageView class, which inherits from CCView and
-- draws a CCGraphics image into the view.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCView = require "CCView"
local CCGraphics = require "CCGraphics"

return class "CCImageView" {extends = CCView} {
    __init = function(x, y, image)
        _ENV.CCView(x, y, image.termWidth, image.termHeight)
        self.image = image
    end,
    draw = function()
        if self.parentWindow ~= nil then
            CCGraphics.drawCapture(self.window, 0, 0, self.image)
            for k,v in pairs(self.subviews) do v.draw() end
        end
    end
}