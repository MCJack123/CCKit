-- CCImageLoader.lua
-- CCKit
--
-- This file creates the CCImageLoader class, which converts various image formats
-- into CCGraphics images. It also defines extra constants that represent each
-- image file type.
--
-- Copyright (c) 2018 JackMacWindows.

local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCLog = require "CCLog"
local CCImageType = require "CCImageType"

local function inputIter(inputf)
    return inputf
end

-- These functions expect a function to read values from. This will probably be
-- fileHandle.readLine.
local function loadCCG(inputf)
    local retval = ""
    for v in inputIter(inputf) do
        retval = retval .. v .. "\n"
    end
    return textutils.unserialize(retval)
end

local function loadNFP(inputf)
    local retval = {}
    local empty = true
    local offset = 9999999
    local lines = {}
    local maxLen = 0
    retval.termHeight = 0
    retval.termWidth = 0
    for v in inputIter(inputf) do
        if not empty or v ~= "" then
            empty = false
            table.insert(lines, v)
            retval.termHeight = retval.termHeight + 1
            if string.len(v) > maxLen then maxLen = string.len(v) end
            for x=1,offset do
                if x > string.len(v) then break end
                if string.sub(v, x, x) ~= " " then 
                    offset = x
                    break
                end
            end
        end
    end
    for x=offset, maxLen+1 do retval[x-offset] = {} end
    --retval.termWidth = retval.termWidth + 1
    for k,v in ipairs(lines) do
        v = string.sub(v, offset)
        for x=offset,maxLen+1 do
            retval[x-offset][k-1] = {}
            local ch = string.sub(v, x-offset+1, x-offset+1)
            if type(ch) ~= "string" or ch == "" or ch == nil then ch = " " end
            --CCLog.default.debug("decoder", "ch is " .. tostring(ch) .. ", x is " .. x)
            if ch == " " then retval[x-offset][k-1].transparent = true
            else retval[x-offset][k-1].bgColor = bit.blshift(1, tonumber(ch, 16)) end
            retval[x-offset][k-1].fgColor = 1
            retval[x-offset][k-1].pixelCode = 0
            retval[x-offset][k-1].useCharacter = false
            retval[x-offset][k-1].character = " "
            if x-offset > retval.termWidth then retval.termWidth = x-offset end
        end
    end
    retval.width = retval.termWidth * 2
    retval.height = retval.termHeight * 3
    return retval
end

return class "CCImageLoader" {
    fileHandle = nil,
    isOpen = false,
    type = CCImageType.none,
    fileName = nil,
    open = function(file)
        self.fileHandle = fs.open(file, "r")
        if self.fileHandle == nil then return -1 end
        self.isOpen = true
        self.fileName = file
        if string.find(file, ".ccg") ~= nil or string.find(file, ".lon") ~= nil then self.type = CCImageType.ccg
        elseif string.find(file, ".nfp") ~= nil then self.type = CCImageType.nfp
        elseif string.find(file, ".nft") ~= nil then self.type = CCImageType.nft
        elseif string.find(file, ".blt") ~= nil then self.type = CCImageType.blt
        elseif string.find(file, ".gif") ~= nil then self.type = CCImageType.gif
        else return 1 end
        return 0
    end,
    read = function()
        if not self.isOpen or self.type == CCImageType.none then return {width = 0, height = 0, termWidth = 0, termHeight = 0} end
        if self.type == CCImageType.ccg then return loadCCG(self.fileHandle.readLine)
        elseif self.type == CCImageType.nfp then return loadNFP(self.fileHandle.readLine)
        else
            CCLog.default.error(self.fileName, "File type " .. tostring(self.type) .. " not supported yet", "CCImageLoader", 94)
            return {width = 0, height = 0, termWidth = 0, termHeight = 0}
        end
    end,
    close = function()
        self.fileHandle.close()
        self.isOpen = false
        self.type = CCImageType.none
        self.fileName = nil
        self.fileHandle = nil
    end
}