-- hires.lua
-- CCKit
--
-- The ComputerCraft screen is normally 51x19, but there is an extended
-- character set that allows extra pixels to be drawn. This allows the computer
-- to use modes kind of like early CGA/EGA graphics. The screen can be
-- extended to have a full 102x57 resolution. This file is used to keep track
-- of these mini-pixels and draw to the screen in lower resolution.
--
-- Copyright (c) 2018 JackMacWindows.

if not term.isColor() then error("This API requires an advanced computer.", 2) end

local screenBuffer = {} -- Stores the mappings for character -> pixels
local graphicsInitialized = false

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
-- Parameter: x = x
-- Parameter: y = y
local function redrawChar(x, y)
    term.setCursorPos(x+1, y+1)
    if screenBuffer[x][y] == nil then error("pixel not found at " .. x .. ", " .. y) end
    if screenBuffer[x][y].useCharacter == true then
        term.setBackgroundColor(screenBuffer[x][y].bgColor)
        term.setTextColor(screenBuffer[x][y].fgColor)
        term.write(screenBuffer[x][y].character)
    else
        local char, flip = pixelToChar(screenBuffer[x][y].pixelCode)
        if flip then
            term.setBackgroundColor(screenBuffer[x][y].fgColor)
            term.setTextColor(screenBuffer[x][y].bgColor)
        else
            term.setBackgroundColor(screenBuffer[x][y].bgColor)
            term.setTextColor(screenBuffer[x][y].fgColor)
        end
        term.write(char)
    end
end

-- Updates the screen with the graphics buffer.
function redrawScreen()
    if not graphicsInitialized then error("graphics not initialized", 3) end
    term.clear()
    for x=0,screenBuffer.termWidth-1 do
        for y=0,screenBuffer.termHeight-1 do
            redrawChar(x, y)
        end
    end
end

-- Initializes the graphics buffer.
-- Returns: new screen width, new screen height
function initGraphics()
    local width, height = term.getSize()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    term.setCursorBlink(false)
    screenBuffer.width = width * 2
    screenBuffer.height = height * 3
    screenBuffer.termWidth = width
    screenBuffer.termHeight = height
    for x=0,width-1 do
        screenBuffer[x] = {}
        for y=0,height-1 do
            --print("creating pixel " .. x .. ", " .. y)
            screenBuffer[x][y] = {}
            screenBuffer[x][y].fgColor = colors.white -- Text color
            screenBuffer[x][y].bgColor = colors.black -- Background color
            screenBuffer[x][y].pixelCode = 0 -- Stores the data as a 6-bit integer (tl, tr, cl, cr, bl, br)
            screenBuffer[x][y].useCharacter = false -- Whether to print a custom character
            screenBuffer[x][y].character = " " -- Custom character
        end
    end
    graphicsInitialized = true
    return width * 2, height * 3
end

-- Checks whether the graphics are initialized.
-- Returns: whether the graphics are initialized
function graphicsAreInitialized()
    return graphicsInitialized
end

-- Ends the graphics buffer.
function endGraphics()
    screenBuffer = {}
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    term.setCursorBlink(true)
    graphicsInitialized = false
end

-- Returns the colors defined at the text location.
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Returns: foreground color, background color
function getPixelColors(x, y)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.termWidth or y > screenBuffer.termHeight then error("position out of bounds", 2) end
    return screenBuffer[x][y].fgColor, screenBuffer[x][y].backgroundColor
end

-- Sets the colors at a text location.
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: fgColor = the foreground color to set (nil to keep)
-- Parameter: bgColor = the background color to set (nil to keep)
-- Returns: foreground color, background color
function setPixelColors(x, y, fgColor, bgColor)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.termWidth or y > screenBuffer.termHeight then error("position out of bounds", 2) end
    if fgColor ~= nil then screenBuffer[x][y].fgColor = fgColor end
    if bgColor ~= nil then screenBuffer[x][y].bgColor = bgColor end
    redrawChar(x, y)
    return screenBuffer[x][y].fgColor, screenBuffer[x][y].bgColor
end

-- Clears the text location.
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
function clearCharacter(x, y)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.termWidth or y > screenBuffer.termHeight then error("position out of bounds", 2) end
    screenBuffer[x][y].useCharacter = false
    screenBuffer[x][y].pixelCode = 0
    redrawChar(x, y)
end

-- Turns a pixel on at a location.
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
function setPixel(x, y)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.width or y > screenBuffer.height then error("position out of bounds", 2) end
    screenBuffer[x][y].useCharacter = false
    screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode = bit.bor(screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode, 2^(2*(y % 3) + (x % 2)))
    redrawChar(math.floor(x / 2), math.floor(y / 3))
end

-- Turns a pixel off at a location.
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
function clearPixel(x, y)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.width or y > screenBuffer.height then error("position out of bounds", 2) end
    screenBuffer[x][y].useCharacter = false
    screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode = bit.band(screenBuffer[math.floor(x / 2)][math.floor(y / 3)].pixelCode, bit.bnot(2^(2*(y % 3) + (x % 2))))
    redrawChar(math.floor(x / 2), math.floor(y / 3))
end

-- Sets a pixel at a location to a value.
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
-- Parameter: value = the value to set the pixel to
function setPixelValue(x, y, value)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.width or y > screenBuffer.height then error("position out of bounds", 2) end
    if value then setPixel(x, y) else clearPixel(x, y) end
end

-- Sets a custom character to be printed at a location.
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: char = the character to print
function setCharacter(x, y, char)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x > screenBuffer.termWidth or y > screenBuffer.termHeight then error("position out of bounds", 2) end
    screenBuffer[x][y].useCharacter = true
    screenBuffer[x][y].character = char
    redrawChar(x, y)
end

-- Sets a custom string to be printed at a location.
-- Parameter: x = the x location of the start of the string
-- Parameter: y = the y location of the string
-- Parameter: str = the string to set
function setString(x, y, str)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x + string.len(str) > screenBuffer.termWidth or y > screenBuffer.termHeight then error("region out of bounds", 2) end
    for px=1,string.len(str) do setCharacter(px+x-1, y, str[px]) end
end

-- Draws a line on the screen.
-- Parameter: x = origin x
-- Parameter: y = origin y
-- Parameter: length = length of the line
-- Parameter: isVertical = whether the line is vertical or horizontal
-- Parameter: color = the color of the line
-- Parameter: fgColor = the text color of the line (ignore to keep color)
function drawLine(x, y, length, isVertical, color, fgColor)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if isVertical then
        if y + length > screenBuffer.termHeight then error("region out of bounds", 2) end
        for py=y,y+length-1 do
            clearCharacter(x, py)
            setPixelColors(x, py, fgColor, color)
            redrawChar(x, py)
        end
    else
        if x + length > screenBuffer.termWidth then error("region out of bounds", 2) end
        for px=x,x+length-1 do
            clearCharacter(px, y)
            setPixelColors(px, y, fgColor, color)
            redrawChar(px, y)
        end
    end
end

-- Draws a box on the screen.
-- Parameter: x = origin x
-- Parameter: y = origin y
-- Parameter: width = box width
-- Parameter: height = box height
-- Parameter: color = box color
-- Parameter: fgColor = the text color of the line (ignore to keep color)
function drawBox(x, y, width, height, color, fgColor)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x + width > screenBuffer.termWidth or y + height > screenBuffer.termHeight then error("region out of bounds", 2) end
    for px=x,x+length-1 do for py=y,y+height-1 do
        clearCharacter(px, py)
        setPixelColors(px, py, fgColor, color)
        redrawChar(px, py)
    end end
end

-- Captures an image of an area on screen to an image.
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: width = the width of the image
-- Parameter: height = the height of the image
-- Returns: a table with the image data
function captureRegion(x, y, width, height)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if x + width > screenBuffer.termWidth or y + height > screenBuffer.termHeight then error("region out of bounds", 2) end
    local captureTable = {}
    captureTable.width = width * 2
    captureTable.height = height * 3
    captureTable.termWidth = width
    captureTable.termHeight = height
    for px=x,x+width-1 do
        captureTable[px-x] = {}
        for py=y,height-1 do captureTable[px-x][py-y] = screenBuffer[px][py] end
    end
    return captureTable
end

-- Draws a previously captured image onto screen at a position.
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: image = a table with the image data
function drawCapture(x, y, image)
    if not graphicsInitialized then error("graphics not initialized", 2) end
    if image.width == nil or image.height == nil or image.termWidth == nil or image.termHeight == nil then error("invalid image", 2) end
    if x + image.termWidth > screenBuffer.termWidth or y + image.termHeight > screenBuffer.termHeight then error("region out of bounds", 2) end
    for px=x,x+image.termWidth-1 do for py=y,y+image.termHeight-1 do 
        --print(px .. " " .. py)
        if image[px-x][py-y] == nil then error("no data at " .. px-x .. ", " .. py-y) end
        screenBuffer[px][py] = image[px-x][py-y] end end
    redrawScreen()
end
