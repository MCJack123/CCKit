-- CCKitGlobals.lua
-- CCKit
--
-- This file defines global variables that other files read from. This must be
-- placed at /CCKit/CCKitGlobals.lua for other CCKit classes to work. This can
-- also be modified by the end user to change default values.
--
-- Copyright (c) 2018 JackMacWindows.

-- All classes
CCKitDir = "CCKit"                             -- The directory where all of the CCKit files are located

-- CCWindow
titleBarColor = colors.yellow                  -- The color of the background of the title bar
titleBarTextColor = colors.black               -- The color of the text of the title bar
windowBackgroundColor = colors.white           -- The color of the background of a window

-- Text views
defaultTextColor = colors.black                -- The default color of text

-- CCButton's
buttonColor = colors.lightGray                 -- The color of a normal button
buttonSelectedColor = colors.gray              -- The color of a selected button
buttonHighlightedColor = colors.lightBlue      -- The color of a highlighted button
buttonHighlightedSelectedColor = colors.blue   -- The color of a highlighted selected button
buttonDisabledColor = colors.lightGray         -- The color of a disabled button
buttonDisabledTextColor = colors.gray          -- The color of the text in a disabled button


-- Better serialize
local g_tLuaKeywords = {
    [ "and" ] = true,
    [ "break" ] = true,
    [ "do" ] = true,
    [ "else" ] = true,
    [ "elseif" ] = true,
    [ "end" ] = true,
    [ "false" ] = true,
    [ "for" ] = true,
    [ "function" ] = true,
    [ "if" ] = true,
    [ "in" ] = true,
    [ "local" ] = true,
    [ "nil" ] = true,
    [ "not" ] = true,
    [ "or" ] = true,
    [ "repeat" ] = true,
    [ "return" ] = true,
    [ "then" ] = true,
    [ "true" ] = true,
    [ "until" ] = true,
    [ "while" ] = true,
}

local function serializeImpl( t, tTracking, sIndent )
    local sType = type(t)
    if sType == "table" then
        if tTracking[t] ~= nil then
            return "recursive"
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local sResult = "{\n"
            local sSubIndent = sIndent .. "  "
            local tSeen = {}
            for k,v in ipairs(t) do
                tSeen[k] = true
                sResult = sResult .. sSubIndent .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
            end
            for k,v in pairs(t) do
                if not tSeen[k] then
                    local sEntry
                    if type(k) == "string" and not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
                        sEntry = k .. " = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
                    else
                        sEntry = "[ " .. serializeImpl( k, tTracking, sSubIndent ) .. " ] = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
                    end
                    sResult = sResult .. sSubIndent .. sEntry
                end
            end
            sResult = sResult .. sIndent .. "}"
            return sResult
        end
        
    elseif sType == "string" then
        return string.format( "%q", t )
    
    elseif sType == "number" or sType == "boolean" or sType == "nil" then
        return tostring(t)
        
    else
        --error( "Cannot serialize type "..sType, 0 )
        return "unserializable"
        
    end
end

function textutils.serialize( t )
    local tTracking = {}
    return serializeImpl( t, tTracking, "" )
end