-- CCKitGlobalFunctions.lua
-- CCKit
--
-- Defines some functions that are used by some files. Automatically included by
-- CCKitGlobals.lua.
--
-- Copyright (c) 2018 JackMacWindows.

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.combine(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return nil end
    local orig_type = type(b)
    local copy = deepcopy(a)
    for orig_key, orig_value in next, b, nil do
        copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(b)))
    return copy
end

function multipleInheritance(...)
    local tables = { ... }
    local retval = tables[1]
    for k,v in ipairs(tables) do if k ~= 1 then retval = table.combine(retval, v) end end
    return retval
end

function require(class)
    local remove = true
    if _G[class] ~= nil and type(_G[class]) == "function" then remove = false
    else os.loadAPI(CCKitGlobals.CCKitDir .. "/" .. class .. ".lua") end
    local temp = _G[class]
    if remove then os.unloadAPI(class) end
    return temp[class]
end

function loadAPI(class)
    if _G[class] ~= nil and not CCKitGlobals.shouldDoubleRequire then return end
    os.loadAPI(CCKitGlobals.CCKitDir .. "/" .. class .. ".lua")
end

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
        return "unserializable"
        
    end
end

function textutils.serialize( t )
    local tTracking = {}
    return serializeImpl( t, tTracking, "" )
end

function setEGAColors() -- just putting this here if anyone really wants it
    if tonumber(string.sub(os.version(), 9)) < 1.8 then error("This requires CraftOS 1.8 or later.", 2) end
    term.setPaletteColor(colors.black, 0, 0, 0)
    term.setPaletteColor(colors.blue, 0, 0, 0.625)
    term.setPaletteColor(colors.green, 0, 0.625, 0)
    term.setPaletteColor(colors.cyan, 0, 0.625, 0.625)
    term.setPaletteColor(colors.red, 0.625, 0, 0)
    term.setPaletteColor(colors.purple, 0.625, 0, 0.625)
    term.setPaletteColor(colors.brown, 0.625, 0.3125, 0)
    term.setPaletteColor(colors.lightGray, 0.625, 0.625, 0.625)
    term.setPaletteColor(colors.gray, 0.3125, 0.3125, 0.3125)
    term.setPaletteColor(colors.lightBlue, 0.3125, 0.3125, 1)
    term.setPaletteColor(colors.lime, 0.3125, 1, 0.3125)
    term.setPaletteColor(colors.pink, 1, 0.3125, 0.3125)
    -- CraftOS uses orange instead of light cyan, skipping
    term.setPaletteColor(colors.magenta, 1, 0.3125, 1)
    term.setPaletteColor(colors.yellow, 1, 1, 0.3125)
    term.setPaletteColor(colors.white, 1, 1, 1)
end