-- CCImageWriter.lua
-- CCKit
--
-- This file creates the CCImageWriter class, which converts CCGraphics images
-- into various image formats.
--
-- Copyright (c) 2018 JackMacWindows.

local CCKitGlobals = require "CCKitGlobals"
local CCLog = require "CCLog"
local CCImageType = require "CCImageType"

local colorString = "0123456789abcdef"

local function cp(color)
    local recurses = 1
    local cc = color
    while cc ~= 1 do 
        cc = bit.blogic_rshift(cc, 1)
        recurses = recurses + 1
    end
    --print(recurses .. " " .. color .. " \"" .. string.sub(colorString, recurses, recurses) .. "\"")
    return string.sub(colorString, recurses, recurses)
end

local function writeCCG(image)
    return textutils.serialize(image)
end

local function writeNFP(image)
    local retval = ""
    for k,v in ipairs(image) do
        if type(k) == "number" then
            for l,w in ipairs(v) do
                if w.transparent then retval = retval .. " "
                else retval = retval .. cp(w.bgColor) end
            end
            retval = retval .. "\n"
        end
    end
    return retval
end

local function CCImageWriter()
    local retval = {}
    retval.fileHandle = nil
    retval.isOpen = false
    retval.type = CCImageType.none
    retval.fileName = nil
    function retval:open(file)
        self.fileHandle = fs.open(file, "w")
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
    end
    function retval:write(image)
        if not self.isOpen or self.type == CCImageType.none then return {width = 0, height = 0, termWidth = 0, termHeight = 0} end
        if self.type == CCImageType.ccg then self.fileHandle.write(writeCCG(image))
        elseif self.type == CCImageType.nfp then self.fileHandle.write(writeNFP(image))
        else
            CCLog.default:error(self.fileName, "File type " .. tostring(self.type) .. " not supported yet", "CCImageWriter", 94)
            return {width = 0, height = 0, termWidth = 0, termHeight = 0}
        end
    end
    function retval:close()
        self.fileHandle.close()
        self.isOpen = false
        self.type = CCImageType.none
        self.fileName = nil
        self.fileHandle = nil
    end
    return retval
end

return CCImageWriter