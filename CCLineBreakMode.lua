-- CCLineBreakMode.lua
-- CCKit
--
-- This sets constants that define how text should be wrapped in a CCTextView.
--
-- Copyright (c) 2018 JackMacWindows.

byWordWrapping = 1
byCharWrapping = 2
byClipping = 4
byTruncatingHead = 8

function string.split(str, tok)
    words = {}
    for word in str:gmatch(tok) do table.insert(words, word) end
    return words
end

function table.count(tab)
    local i = 0
    for k,v in pairs(tab) do i = i + 1 end
    return i
end

function divideText(text, width, mode)
    local retval = {}
    if bit.band(mode, byCharWrapping) == byCharWrapping then
        for i=1,string.len(text),width do table.insert(retval, string.sub(text, i, i + width)) end
    elseif bit.band(mode, byClipping) == byClipping then
        local lines = string.split(text, "\n")
        for k,line in pairs(lines) do table.insert(retval, string.sub(line, 1, width)) end
    else
        local words = string.split(text, "[%w%p]+")
        local line = ""
        for k,word in pairs(words) do
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

