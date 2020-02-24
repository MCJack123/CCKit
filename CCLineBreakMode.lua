-- CCLineBreakMode.lua
-- CCKit
--
-- This sets constants that define how text should be wrapped in a CCTextView.
--
-- Copyright (c) 2018 JackMacWindows.

local CCLineBreakMode = {
    byWordWrapping = 1,
    byCharWrapping = 2,
    byClipping = 4,
    byTruncatingHead = 8,
}

local function string_split(str, tok)
    words = {}
    for word in str:gmatch(tok) do table.insert(words, word) end
    return words
end

function CCLineBreakMode.divideText(text, width, mode)
    local retval = {}
    if bit.band(mode, CCLineBreakMode.byCharWrapping) == CCLineBreakMode.byCharWrapping then
        for i=1,string.len(text),width do table.insert(retval, string.sub(text, i, i + width)) end
    elseif bit.band(mode, CCLineBreakMode.byClipping) == CCLineBreakMode.byClipping then
        local lines = string_split(text, "\n")
        for _,line in pairs(lines) do table.insert(retval, string.sub(line, 1, width)) end
    else
        local words = string_split(text, "[%w%p]+")
        local line = ""
        for _,word in pairs(words) do
            if string.len(line) + string.len(word) >= width then
                table.insert(retval, line)
                line = ""
            end
            line = line .. word .. " "
        end
        table.insert(retval, line)
    end
    return retval
end

return CCLineBreakMode