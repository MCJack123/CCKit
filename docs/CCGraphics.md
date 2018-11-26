A graphics engine designed for CCKit. This is not a class, but rather a collection of functions that control graphics contexts.  
I have already written documentation for it in the source, so I will be copying it here. The style will be different from the other documentation pages, though.
```lua
-- Draws a filled box on the terminal.
-- Parameter: x = x
-- Parameter: y = y
-- Parameter: endx = end x
-- Parameter: endy = end y
-- Parameter: color = color
function drawFilledBox(x, y, endx, endy, color)

-- Updates the screen with the graphics buffer.
-- Parameter: win = the win to control
function redrawScreen(win)

-- Initializes the graphics buffer.
-- Parameter: win = the win to control
-- Returns: new screen width, new screen height
function initGraphics(win)

-- Checks whether the graphics are initialized.
-- Parameter: win = the win to control
-- Returns: whether the graphics are initialized
function graphicsAreInitialized(win)

-- Ends the graphics buffer.
-- Parameter: win = the win to control
function endGraphics(win)

-- Returns the colors defined at the text location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Returns: foreground color, background color
function getPixelColors(win, x, y)

-- Sets the colors at a text location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: fgColor = the foreground color to set (nil to keep)
-- Parameter: bgColor = the background color to set (nil to keep)
-- Returns: foreground color, background color
function setPixelColors(win, x, y, fgColor, bgColor)

-- Clears the text location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
function clearCharacter(win, x, y, redraw)

-- Turns a pixel on at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
function setPixel(win, x, y)

-- Turns a pixel off at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
function clearPixel(win, x, y)

-- Sets a pixel at a location to a value.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the pixel
-- Parameter: y = the y location of the pixel
-- Parameter: value = the value to set the pixel to
function setPixelValue(win, x, y, value)

-- Sets a custom character to be printed at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: char = the character to print
function setCharacter(win, x, y, char)

-- Sets a custom string to be printed at a location.
-- Parameter: win = the win to control
-- Parameter: x = the x location of the start of the string
-- Parameter: y = the y location of the string
-- Parameter: str = the string to set
function setString(win, x, y, str)

-- Draws a line on the screen.
-- Parameter: win = the win to control
-- Parameter: x = origin x
-- Parameter: y = origin y
-- Parameter: length = length of the line
-- Parameter: isVertical = whether the line is vertical or horizontal
-- Parameter: color = the color of the line
-- Parameter: fgColor = the text color of the line (ignore to keep color)
function drawLine(win, x, y, length, isVertical, color, fgColor)

-- Draws a box on the screen.
-- Parameter: win = the win to control
-- Parameter: x = origin x
-- Parameter: y = origin y
-- Parameter: width = box width
-- Parameter: height = box height
-- Parameter: color = box color
-- Parameter: fgColor = the text color of the line (ignore to keep color)
function drawBox(win, x, y, width, height, color, fgColor)

-- Captures an image of an area on screen to an image.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: width = the width of the image
-- Parameter: height = the height of the image
-- Returns: a table with the image data
function captureRegion(win, x, y, width, height)

-- Draws a previously captured image onto screen at a position.
-- Parameter: win = the win to control
-- Parameter: x = the x location on screen
-- Parameter: y = the y location on screen
-- Parameter: image = a table with the image data
function drawCapture(win, x, y, image)

-- Resizes the window.
-- Parameter: win = the win to control
-- Parameter: width = the new width (in term chars)
-- Parameter: height = the new height (in term chars)
function resizeWindow(win, width, height)
```