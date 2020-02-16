-- CCGraphics.lua
-- CCKit
--
-- The ComputerCraft screen is normally 51x19, but there is an extended
-- character set that allows extra pixels to be drawn. This allows the computer
-- to use modes kind of like early CGA/EGA graphics. The screen can be
-- extended to have a full 102x57 resolution. This file is used to keep track
-- of these mini-pixels and draw to the screen in lower resolution.
-- This file is used for windows and other non-term screens.
--
-- Copyright (c) 2018 JackMacWindows.

if not term.isColor() then error("This API requires an advanced computer.", 2) end

local CCGraphics = {}

local colorString = "0123456789abcdef"

local function cp(color)
    if color == 0 then return 0 end
    local recurses = 1
    local cc = color
    while cc ~= 1 do 
        cc = bit.blogic_rshift(cc, 1)
        recurses = recurses + 1
    end
    --print(recurses .. " " .. color .. " \"" .. string.sub(colorString, recurses, recurses) .. "\"")
    return string.sub(colorString, recurses, recurses)
end

function CCGraphics.drawFilledBox(x, y, endx, endy, color)
    for px=x,endx do for py=y,endy do
        term.setCursorPos(px, py)
        term.blit(" ", "0", cp(color))
    end end
end

-- Converts a 6-bit pixel value to a character.
-- Returns: character, whether to flip the colors
local function pixelToChar(pixel)
    if pixel < 32 then
        return string.char(pixel + 128), false
    else
        return string.char(bit.band(bit.bnot(pixel), 63) + 128), true
    end
end

-- Redraws a certain pixel.
-- Parameter: win = the win to control
-- Parameter: x = x
-- Parameter: y = y
local function redrawChar(win, x, y)
    win.setCursorPos(x+1, y+1)
    if win.screenBuffer[x][y] == nil then error("pixel not found at " .. x .. ", " .. y) end
    if win.screenBuffer[x][y].transparent == true then return end
    if win.screenBuffer[x][y].useCharacter == true then win.blit(win.screenBuffer[x][y].character, cp(win.screenBuffer[x][y].fgColor), cp(win.screenBuffer[x][y].bgColor))
    else
        local char, flip = pixelToChar(win.screenBuffer[x][y].pixelCode)
        if flip then win.blit(char, cp(win.screenBuffer[x][y].bgColor), cp(win.screenBuffer[x][y].fgColor))
        else win.blit(char, cp(win.screenBuffer[x][y].fgColor), cp(win.screenBuffer[x][y].bgColor)) end
    end
end

-- Updates the screen with the graphics buffer.
-- Parameter: win = the win to control
function CCGraphics.redrawScreen(win)
    if not win.graphicsInitialized then error("graphics not initialized", 3) end
    win.clear()
    for x=0,win.screenBuffer.termWidth-1 do
        for y=0,win.screenBuffer.termHeight-1 do
            redrawChar(win, x, y)
        end
    end
end

-- Initializes the graphics buffer.
-- Parameter: win = the win to control
-- Returns: new screen width, new screen height
function CCGraphics.initGraphics(win)
    local width, height = win.getSize()
    win.setBackgroundColor(colors.black)
    win.setTextColor(colors.white)
    win.clear()
    win.setCursorPos(1, 1)
    win.setCursorBlink(false)
    win.screenBuffer = {}
    win.screenBuffer.width = width * 2
    win.screenBuffer.height = height * 3
    win.screenBuffer.termWidth = width
    win.screenBuffer.termHeight = height
    for x=0,width-1 do
        win.screenBuffer[x] = {}
        for y=0,height-1 do
            --print("creating pixel " .. x .. ", " .. y)
            win.screenBuffer[x][y] = {}
            win.screenBuffer[x][y].fgColor = colors.white -- Text color
            win.screenBuffer[x][y].bgColor = colors.black -- Background color
            win.screenBuffer[x][y].pixelCode = 0 -- Stores the data as a 6-bit integer (tl, tr, cl, cr, bl, br)
            win.screenBuffer[x][y].useCharacter = false -- Whether to print a custom character
            win.screenBuffer[x][y].character = " " -- Custom character
        end
    end
    win.graphicsInitialized = true
    return width * 2, height * 3
end

-- Checks whether the graphics are initialized.
-- Parameter: win = the win to control
-- Returns: whether the graphics are initialized
function CCGraphics.graphicsAreInitialized(win)
    if win == nil then return false end
    return win.graphicsInitialized
end

-- Ends the graphics buffer.
-- Parameter: win = the win to control
function CCGraphics.endGraphics(win)
    win.screenBuffer = nil
    win.setBackgroundColor(colors.black)
    win.setTextColor(colors.white)
    win.clear()
    win.setCursorPos(1, 1)
    win.setCursorBlink(false)
    win.graphicsInitialized = false
end

-- Returns the colors defined at the text location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Returns: foreground color, background color
function CCGraphics.getPixelColors(win, x, y)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x > win.screenBuffer.termWidth or y > win.screenBuffer.termHeight then error("position out of bounds", 2) end
    return win.screenBuffer[x][y].fgColor, win.screenBuffer[x][y].backgroundColor
end

-- Sets the colors at a text location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: fgColor = the foreground color to set (nil to keep)
-- Parameter: bgColor = the background color to set (nil to keep)
-- Returns: foreground color, background color
function CCGraphics.setPixelColors(win, x, y, fgColor, bgColor)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x % 1 ~= 0 or y % 1 ~= 0 then error("coordinates must be integers, got (" .. x .. ", " .. y .. ")", 2) end
    if x > win.screenBuffer.termWidth or y > win.screenBuffer.termHeight then error("position out of bounds", 2) end
    if fgColor ~= nil then win.screenBuffer[x][y].fgColor = fgColor end
    if bgColor ~= nil then win.screenBuffer[x][y].bgColor = bgColor end
    redrawChar(win, x, y)
    return win.screenBuffer[x][y].fgColor, win.screenBuffer[x][y].bgColor
end

-- Clears the text location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
function CCGraphics.clearCharacter(win, x, y, redraw)
    redraw = redraw or true
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x > win.screenBuffer.termWidth or y > win.screenBuffer.termHeight then error("position out of bounds", 2) end
    win.screenBuffer[x][y].useCharacter = false
    win.screenBuffer[x][y].pixelCode = 0
    if redraw then redrawChar(win, x, y) end
end

-- Turns a pixel on at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
function CCGraphics.setPixel(win, x, y)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x > win.screenBuffer.width or y > win.screenBuffer.height then error("position out of bounds", 2) end
    win.screenBuffer[math.floor(x / 2)][math.floor(y / 3)].useCharacter = false
    win.screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode = bit.bor(win.screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode, 2^(2*(y % 3) + (x % 2)))
    redrawChar(win, math.floor(x / 2), math.floor(y / 3))
end

-- Turns a pixel off at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
function CCGraphics.clearPixel(win, x, y)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x > win.screenBuffer.width or y > win.screenBuffer.height then error("position out of bounds", 2) end
    win.screenBuffer[math.floor(x / 2)][math.floor(y / 3)].useCharacter = false
    win.screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode = bit.band(win.screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode, bit.bnot(2^(2*(y % 3) + (x % 2))))
    redrawChar(win, math.floor(x / 2), math.floor(y / 3))
end

-- Sets a pixel at a location to a value.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
-- Parameter: value = the value to set the pixel to
function CCGraphics.setPixelValue(win, x, y, value)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x > win.screenBuffer.width or y > win.screenBuffer.height then error("position " .. x .. ", " .. y .. " out of bounds", 2) end
    if value then CCGraphics.setPixel(win, x, y) else CCGraphics.clearPixel(win, x, y) end
end

-- Sets a custom character to be printed at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: char = the character to print
function CCGraphics.setCharacter(win, x, y, char)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if win.screenBuffer[x] == nil or win.screenBuffer[x][y] == nil then error("position out of bounds: " .. x .. ", " .. y, 2) end
    win.screenBuffer[x][y].useCharacter = true
    win.screenBuffer[x][y].character = char
    redrawChar(win, x, y)
end

-- Sets a custom string to be printed at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the start of the string
-- Parameter: y = the y location of the string
-- Parameter: str = the string to set
function CCGraphics.setString(win, x, y, str)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x + string.len(str) - 1 > win.screenBuffer.termWidth or y > win.screenBuffer.termHeight then error("region out of bounds", 2) end
    for px=x,x+string.len(str)-1 do CCGraphics.setCharacter(win, px, y, string.sub(str, px-x+1, px-x+1)) end
end

-- Draws a line on the screen.
-- Parameter: win = the win to control
-- Parameter: x = origin x
-- Parameter: y = origin y
-- Parameter: length = length of the line
-- Parameter: isVertical = whether the line is vertical or horizontal
-- Parameter: color = the color of the line
-- Parameter: fgColor = the text color of the line (ignore to keep color)
function CCGraphics.drawLine(win, x, y, length, isVertical, color, fgColor)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if isVertical then
        if y + length > win.screenBuffer.termHeight then error("region out of bounds", 2) end
        for py=y,y+length-1 do
            CCGraphics.clearCharacter(win, x, py, false)
            CCGraphics.setPixelColors(win, x, py, fgColor, color)
            --redrawChar(win, x, py)
        end
    else
        if x + length > win.screenBuffer.termWidth then error("region out of bounds", 2) end
        for px=x,x+length-1 do
            CCGraphics.clearCharacter(win, px, y, false)
            CCGraphics.setPixelColors(win, px, y, fgColor, color)
            --redrawChar(win, px, y)
        end
    end
end

-- Draws a box on the screen.
-- Parameter: win = the win to control
-- Parameter: x = origin x
-- Parameter: y = origin y
-- Parameter: width = box width
-- Parameter: height = box height
-- Parameter: color = box color
-- Parameter: fgColor = the text color of the line (ignore to keep color)
function CCGraphics.drawBox(win, x, y, width, height, color, fgColor)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x + width > win.screenBuffer.termWidth or y + height > win.screenBuffer.termHeight then error("region out of bounds", 2) end
    for px=x,x+width-1 do for py=y,y+height-1 do
        CCGraphics.clearCharacter(win, px, py, false)
        CCGraphics.setPixelColors(win, px, py, fgColor, color)
        --redrawChar(win, px, py)
    end end
end

-- Captures an image of an area on screen to an image.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: width = the width of the image
-- Parameter: height = the height of the image
-- Returns: a table with the image data
function CCGraphics.captureRegion(win, x, y, width, height)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if x + width > win.screenBuffer.termWidth or y + height > win.screenBuffer.termHeight then error("region out of bounds", 2) end
    local captureTable = {}
    captureTable.width = width * 2
    captureTable.height = height * 3
    captureTable.termWidth = width
    captureTable.termHeight = height
    for px=x,x+width-1 do
        captureTable[px-x] = {}
        for py=y,height-1 do captureTable[px-x][py-y] = win.screenBuffer[px][py] end
    end
    return captureTable
end

-- Draws a previously captured image onto screen at a position.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: image = a table with the image data
function CCGraphics.drawCapture(win, x, y, image)
    if not win.graphicsInitialized then error("graphics not initialized", 2) end
    if image.width == nil or image.height == nil or image.termWidth == nil or image.termHeight == nil then error("invalid image", 2) end
    if x + image.termWidth > win.screenBuffer.termWidth or y + image.termHeight > win.screenBuffer.termHeight then error("region out of bounds", 2) end
    for px=x,x+image.termWidth-1 do for py=y,y+image.termHeight-1 do 
        --print(px .. " " .. py)
        if image[px-x] == nil then error("no row at " .. px-x) end
        if image[px-x][py-y] == nil then error("no data at " .. px-x .. ", " .. py-y, 2) end
        win.screenBuffer[px][py] = image[px-x][py-y] end end
        CCGraphics.redrawScreen(win)
end

-- Resizes the window.
-- Parameter: win = the win to control
-- Parameter: width = the new width (in term chars)
-- Parameter: height = the new height (in term chars)
function CCGraphics.resizeWindow(win, width, height)
    win.screenBuffer.width = width * 2
    win.screenBuffer.height = height * 3
    win.screenBuffer.termWidth = width
    win.screenBuffer.termHeight = height
    for x=0,width-1 do
        if win.screenBuffer[x] == nil then win.screenBuffer[x] = {} end
        for y=0,height-1 do
            --print("creating pixel " .. x .. ", " .. y)
            if win.screenBuffer[x][y] == nil then
                win.screenBuffer[x][y] = {}
                win.screenBuffer[x][y].fgColor = colors.white -- Text color
                win.screenBuffer[x][y].bgColor = colors.black -- Background color
                win.screenBuffer[x][y].pixelCode = 0 -- Stores the data as a 6-bit integer (tl, tr, cl, cr, bl, br)
                win.screenBuffer[x][y].useCharacter = false -- Whether to print a custom character
                win.screenBuffer[x][y].character = " " -- Custom character
            end
        end
    end
end

return CCGraphics