-- CCKitAmalgamated.lua
-- CCKit
--
-- This file combines all of the files in CCKit into one file that can be loaded.
--
-- Copyright (c) 2018 JackMacWindows.

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

local colorString = "0123456789abcdef"
CCGraphics = {}

local function cp(color)
    local recurses = 1
    local cc = color
    while cc ~= 1 do 
        cc = bit.brshift(cc, 1)
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
    win.screenBuffer[x][y].useCharacter = false
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
    win.screenBuffer[x][y].useCharacter = false
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
    if win.screenBuffer[x] == nil or win.screenBuffer[x][y] == nil then error("position out of bounds", 2) end
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
        if image[px-x][py-y] == nil then error("no data at " .. px-x .. ", " .. py-y) end
        win.screenBuffer[px][py] = image[px-x][py-y]
    end end
    CCGraphics.redrawScreen(win)
end

-- CCApplication.lua
-- CCKit
--
-- This file creates the CCApplication, which manages the program's run loop.
--
-- Copyright (c) 2018 JackMacWindows.

local function drawFilledBox(x, y, endx, endy, color) for px=x,x+endx-1 do for py=y,y+endy-1 do 
    term.setCursorPos(px, py)
    term.blit(" ", "0", cp(color)) 
end end end

function CCApplication()
    local retval = {}
    term.setBackgroundColor(colors.black)
    retval.class = "CCApplication"
    retval.objects = {count = 0}
    retval.events = {}
    retval.isApplicationRunning = false
    retval.backgroundColor = colors.black
    retval.objectOrder = {}
    function retval:setBackgroundColor(color)
        self.backgroundColor = color
        term.setBackgroundColor(color)
        term.clear()
        for k,v in pairs(self.objects) do if k ~= "count" and v.class == "CCWindow" then v:redraw() end end
    end
    function retval:registerObject(win, name, up) -- adds the events in the object to the run loop
        --if win.class ~= "CCWindow" then error("tried to register non-CCWindow type " .. win.class, 2) end
        if win == nil then error("win is nil", 2) end
        if up == nil then up = true end
        if win.repaintColor ~= nil then win.repaintColor = self.backgroundColor end
        self.objects[name] = win
        table.insert(self.objectOrder, name)
        if up then self.objects.count = self.objects.count + 1 end
        --print("added to " .. name)
        --local i = 0
        --print(textutils.serialize(win.events))
        for k,v in pairs(win.events) do
            if self.events[k] == nil then self.events[k] = {} end
            table.insert(self.events[k], v)
            --print("added event " .. k)
            --i=i+1
        end
        --print(textutils.serialize(self.events))
        --print(i)
    end
    function retval:deregisterObject(name)
        retval.objects[name] = nil
        local remove = {}
        for k,v in pairs(self.events) do for l,w in pairs(v) do if w.self == name then table.insert(remove, {f = k, s = l}) end end end
        for a,b in pairs(remove) do self.events[b.f][b.s] = nil end
    end
    function retval:runLoop()
        --print("starting loop")
        while self.isApplicationRunning do
            --print("looking for event")
            if retval.objects.count == 0 then break end
            local ev, p1, p2, p3, p4, p5 = os.pullEvent()
            --print("recieved event " .. ev)
            if ev == "closed_window" then
                if retval.objects[p1] ~= nil then 
                    drawFilledBox(retval.objects[p1].frame.x, retval.objects[p1].frame.y, retval.objects[p1].frame.width, retval.objects[p1].frame.height, self.backgroundColor)
                    retval.objects[p1] = nil
                    retval.objects.count = retval.objects.count - 1
                    if retval.objects.count == 0 then break end
                    local remove = {}
                    for k,v in pairs(self.events) do for l,w in pairs(v) do if w.self == p1 then 
                        --print("removing " .. k)
                        table.insert(remove, {e = k, s = l}) 
                    end end end
                    for a,b in pairs(remove) do self.events[b.e][b.s] = nil end
                    for k,v in pairs(self.objectOrder) do 
                        if v == p1 then 
                            table.remove(self.objectOrder, k)
                            break
                        end
                        if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil then self.objects[v].window.redraw() end 
                    end
                end
            elseif ev == "redraw_window" then
                if retval.objects[p1] ~= nil and retval.objects[p1].redraw ~= nil then retval.objects[p1]:redraw() end
            end
            local didEvent = false
            local redraws = {}
            for k,v in pairs(self.events) do if ev == k then 
                --print("got event " .. ev)
                --print(textutils.serialize(v))
                for l,w in pairs(v) do 
                    if self.objects[w.self] == nil then error(w.self .. " is nil") end
                    if w.func(self.objects[w.self], p1, p2, p3, p4, p5) then 
                        redraws[w.self] = true
                        didEvent = true
                        break 
                    end
                end 
            end end
            if didEvent then for k,v in pairs(self.objectOrder) do if self.objects[v] ~= nil and self.objects[v].class == "CCWindow" and self.objects[v].window ~= nil then self.objects[v].window.redraw() end end end
        end
        --print("ending loop")
        self.isApplicationRunning = false
        coroutine.yield()
    end
    function retval:startRunLoop()
        self.coro = coroutine.create(self.runLoop)
        self.isApplicationRunning = true
        coroutine.resume(self.coro, self)
    end
    function retval:stopRunLoop()
        self.isApplicationRunning = false
    end
    return retval
end

-- CCWindow.lua
-- CCKit
--
-- This file creates the CCWindow class, which handles the actions required
-- for a window to be displayed on screen.
--
-- Copyright (c) 2018 JackMacWindows.

-- Constants for the colors of the window
local titleBarColor = colors.yellow
local titleBarTextColor = colors.black
local windowBackgroundColor = colors.white

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
  --math.randomseed(os.clock())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

function CCWindow(x, y, width, height)
    local retval = {}
    retval.name = string.random(8)
    retval.class = "CCWindow"
    retval.window = window.create(term.native(), x, y, width, height)
    retval.title = ""
    retval.frame = {}
    retval.frame.x = x
    retval.frame.y = y
    retval.frame.width = width
    retval.frame.height = height
    retval.viewController = nil
    retval.isDragging = false
    retval.mouseOffset = 0
    retval.repaintColor = colors.black
    retval.currentApplication = nil
    retval.closing = false
    function retval:redraw()
        if not self.closing then
            self.window.setCursorBlink(false)
            CCGraphics.drawLine(retval.window, 0, 0, self.frame.width-1, false, titleBarColor, titleBarTextColor)
            CCGraphics.setPixelColors(retval.window, self.frame.width-1, 0, colors.white, colors.red)
            CCGraphics.setCharacter(retval.window, self.frame.width-1, 0, "X")
            CCGraphics.drawBox(retval.window, 0, 1, self.frame.width, self.frame.height - 1, windowBackgroundColor)
            self:setTitle(self.title)
            if self.viewController ~= nil then self.viewController.view:draw() end
        end
    end
    function retval:moveToPos(button, px, py)
        --print("moving")
        if button == 1 and self.isDragging then
            CCGraphics.drawFilledBox(self.frame.x, self.frame.y, self.frame.x + self.frame.width, self.frame.y + self.frame.height, self.repaintColor)
            self.window.reposition(px - self.mouseOffset, py)
            if self.viewController ~= nil then self.viewController.view:updateAbsolutes(px - self.frame.x - self.mouseOffset, py - self.frame.y) end
            --CCGraphics.redrawScreen(self.window)
            --self:redraw()
            self.frame.x = px - self.mouseOffset
            self.frame.y = py
            return true
        end
        return false
    end
    function retval:startDrag(button, px, py)
        if button == 1 then
            if py == self.frame.y and px >= self.frame.x and px < self.frame.x + self.frame.width - 1 then 
                self.isDragging = true 
                self.mouseOffset = px - self.frame.x
                return true
            elseif py == self.frame.y and px == self.frame.x + self.frame.width - 1 then
                CCGraphics.endGraphics(self.window)
                self.window = nil
                self.closing = true
                if self.viewController ~= nil then for k,v in pairs(self.viewController.view.subviews) do
                    self.viewController.view:deregisterSubview(v)
                end end
                os.queueEvent("closed_window", self.name)
                return true
            end
        end
        return false
    end
    function retval:stopDrag(button, px, py)
        if button == 1 and self.isDragging then 
            self:moveToPos(button, px, py) 
            self.isDragging = false
            return true
        end
        return false
    end
    function retval:resize(newWidth, newHeight)
        self.frame.width = newWidth
        self.frame.height = newHeight
        self.window.reposition(self.frame.x, self.frame.y, self.frame.width, self.frame.height)
        self:redraw()
    end
    function retval:setTitle(str)
        self.title = str
        CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(str)) / 2), 0, str)
    end
    function retval:setViewController(vc, app)
        self.viewController = vc
        self.currentApplication = app
        self.viewController:loadView(self, self.currentApplication)
        self.viewController:viewDidLoad()
        self.viewController.view:draw()
        --self:redraw()
    end
    function retval:registerObject(obj)
        if self.currentApplication ~= nil then
            self.currentApplication:registerObject(obj, obj.name, false)
        end
    end
    retval.events = {mouse_drag = {func = retval.moveToPos, self = retval.name}, mouse_click = {func = retval.startDrag, self = retval.name}, mouse_up = {func = retval.stopDrag, self = retval.name}}
    CCGraphics.initGraphics(retval.window)
    retval:redraw()
    return retval
end

-- CCView.lua
-- CCKit
--
-- This file creates the CCView class, which handles initializing, drawing,
-- and displaying information inside a CCWindow.
--
-- Copyright (c) 2018 JackMacWindows.

function CCView(x, y, width, height)
    local retval = {}
    retval.class = "CCView"
    retval.parentWindowName = nil
    retval.parentWindow = nil
    retval.currentApplication = nil
    retval.window = nil
    retval.hasEvents = false
    retval.events = {}
    retval.subviews = {}
    retval.backgroundColor = colors.white
    retval.frame = {x = x, y = y, width = width, height = height, absoluteX = x, absoluteY = y}
    function retval:setBackgroundColor(color)
        self.backgroundColor = color
        self:draw()
    end
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:addSubview(view)
        if view == nil then error("view added is nil", 2) end
        if self.currentApplication == nil then error("current application is nil", 2) end
        if view.hasEvents then self.currentApplication:registerObject(view, view.name, false) end
        view:setParent(self.window, self.currentApplication, self.parentWindowName, self.frame.absoluteX, self.frame.absoluteY)
        table.insert(self.subviews, view)
    end
    function retval:setParent(parent, application, name, absoluteX, absoluteY)
        self.parentWindow = parent
        self.parentWindowName = name
        self.currentApplication = application
        self.frame.absoluteX = absoluteX + self.frame.x
        self.frame.absoluteY = absoluteY + self.frame.y
        self.window = window.create(self.parentWindow, self.frame.x+1, self.frame.y+1, self.frame.width, self.frame.height)
        CCGraphics.initGraphics(self.window)
    end
    function retval:updateAbsolutes(addX, addY)
        --print(addX .. ", " .. addY)
        self.frame.absoluteX = self.frame.absoluteX + addX
        self.frame.absoluteY = self.frame.absoluteY + addY
        for k,view in pairs(self.subviews) do view:updateAbsolutes(addX, addY) end
    end
    function retval:deregisterSubview(view)
        if view.hasEvents and self.currentApplication ~= nil then
            self.currentApplication:deregisterObject(view.name)
            for k,v in pairs(view.subviews) do view:deregisterSubview(v) end
        end
    end
    return retval
end

-- CCViewController.lua
-- CCKit
--
-- This file creates the CCViewController class, which is used in a CCWindow
-- to control the window contents. This can be subclassed to create custom
-- controllers for your application.
--
-- Copyright (c) 2018 JackMacWindows.

function CCViewController()
    local retval = {}
    retval.view = {}
    retval.parentWindow = nil
    retval.currentApplication = nil
    function retval:loadView(win, app)
        --print("loaded view " .. win.name)
        self.parentWindow = win
        self.currentApplication = app
        local width, height = win.window.getSize()
        self.view = CCView(0, 1, width, height - 1)
        self.view:setParent(self.parentWindow.window, self.currentApplication, self.parentWindow.name, retval.parentWindow.frame.x, retval.parentWindow.frame.y)
    end
    retval.superLoadView = retval.loadView
    function retval:viewDidLoad()
        -- override this to create custom subviews
    end
    return retval
end

-- CCLabel.lua
-- CCKit
--
-- This is a subclass of CCView that displays text on screen.
--
-- Copyright (c) 2018 JackMacWindows.

function CCLabel(x, y, text)
    local retval = CCView(x, y, string.len(text), 1)
    retval.text = text
    retval.textColor = colors.black
    function retval:draw()
        if self.parentWindow ~= nil then
            for px=0,self.frame.width-1 do CCGraphics.setPixelColors(self.window, px, 0, self.textColor, self.backgroundColor) end
            CCGraphics.setString(self.window, 0, 0, self.text)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    return retval
end

-- CCButton.lua
-- CCKit
--
-- This file creates a subclass of CCView called CCButton, which allows a user
-- to click and start an action.
--
-- Copyright (c) 2018 JackMacWindows.

function CCButton(x, y, width, height)
    local retval = CCView(x, y, width, height)
    retval.name = string.random(8)
    retval.textColor = colors.black
    retval.text = nil
    retval.hasEvents = true
    retval.action = nil
    retval.backgroundColor = colors.lightGray
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, self.textColor)
            if retval.text ~= nil then CCGraphics.setString(self.window, math.floor((self.frame.width - string.len(self.text)) / 2), math.floor((self.frame.height - 1) / 2), self.text) end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setAction(func, object)
        self.action = func
        self.actionObject = object
    end
    function retval:onClick(button, px, py)
        --print("got click")
        if self == nil then error("window is nil", 2) end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.action ~= nil then 
            --print("clicked button")
            self.action(self.actionObject) 
            return true
        end
        return false
    end
    function retval:setText(text)
        self.text = text
        self:draw()
    end
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    retval.events = {mouse_click = {func = retval.onClick, self = retval.name}}
    return retval
end

-- CCImageView.lua
-- CCKit
--
-- This file creates the CCImageView class, which inherits from CCView and
-- draws a CCGraphics image into the view.
--
-- Copyright (c) 2018 JackMacWindows.

function CCImageView(x, y, image)
    local retval = CCView(x, y, image.termWidth, image.termHeight)
    retval.image = image
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawCapture(self.window, 0, 0, self.image)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    return retval
end

-- CCProgressBar.lua
-- CCKit
--
-- This creates a subclass of CCView called CCProgressBar, which displays a
-- bar showing progress.
--
-- Copyright (c) 2018 JackMacWindows.

function CCProgressBar(x, y, width)
    local retval = CCView(x, y, width, 1)
    retval.backgroundColor = colors.lightGray
    retval.foregroundColor = colors.yellow
    retval.progress = 0.0
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawLine(self.window, 0, 0, self.frame.width, false, self.backgroundColor)
            CCGraphics.drawLine(self.window, 0, 0, math.floor(self.frame.width * self.progress), false, self.foregroundColor)
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setProgress(progress)
        if progress > 1 then progress = 1 end
        self.progress = progress
        self:draw()
    end
    return retval
end

-- CCLineBreakMode.lua
-- CCKit
--
-- This sets constants that define how text should be wrapped in a CCTextView.
--
-- Copyright (c) 2018 JackMacWindows.

CCLineBreakMode = {}
CCLineBreakMode.byWordWrapping = 1
CCLineBreakMode.byCharWrapping = 2
CCLineBreakMode.byClipping = 4
CCLineBreakMode.byTruncatingHead = 8

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

function CCLineBreakMode.divideText(text, width, mode)
    local retval = {}
    if bit.band(mode, CCLineBreakMode.byCharWrapping) == CCLineBreakMode.byCharWrapping then
        for i=1,string.len(text),width do table.insert(retval, string.sub(text, i, i + width)) end
    elseif bit.band(mode, CCLineBreakMode.byClipping) == CCLineBreakMode.byClipping then
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

-- CCTextView.lua
-- CCKit
--
-- This creates a subclass of CCView that displays multi-line text.
--
-- Copyright (c) 2018 JackMacWindows.

function CCTextView(x, y, width, height)
    local retval = CCView(x, y, width, height)
    retval.textColor = colors.black
    retval.text = ""
    retval.lineBreakMode = CCLineBreakMode.byWordWrapping
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor, self.textColor)
            local lines = CCLineBreakMode.divideText(self.text, self.frame.width, self.lineBreakMode)
            --print(textutils.serialize(lines))
            if table.count(lines) > self.frame.height then
                local newlines = {}
                if bit.band(self.lineBreakMode, CCLineBreakMode.byTruncatingHead) then
                    for i=table.count(lines)-self.frame.height,table.count(lines) do table.insert(newlines, lines[i]) end
                else
                    for i=1,table.count(lines) do table.insert(newlines, lines[i]) end
                end
                lines = newlines
            end
            for k,v in pairs(lines) do CCGraphics.setString(self.window, 0, k-1, v) end
            for k,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:setText(text)
        self.text = text
        self:draw()
    end
    function retval:setTextColor(color)
        self.textColor = color
        self:draw()
    end
    function retval:setLineBreakMode(mode)
        self.lineBreakMode = mode
        self:draw()
    end
    return retval
end

-- CCKit.lua
-- CCKit
--
-- The main CCKit include. Renames all classes to be part of itself.
--
-- Copyright (c) 2018 JackMacWindows.

function CCMain(initX, initY, initWidth, initHeight, title, vcClass, backgroundColor)
    backgroundColor = backgroundColor or colors.black
    local app = CCApplication()
    app:setBackgroundColor(backgroundColor)
    local win = CCWindow(initX, initY, initWidth, initHeight)
    win:setTitle(title)
    local vc = vcClass()
    win:setViewController(vc, app)
    app:registerObject(win, win.name)
    app.isApplicationRunning = true
    term.setCursorBlink(false)
    app:runLoop()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.setCursorBlink(true)
end
