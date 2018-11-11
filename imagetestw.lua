os.loadAPI("CCKit/CCGraphics.lua")

local file = fs.open("CCKit/testimage.lon", "r")
local image = textutils.unserialize(file.readAll())
file.close()
term.setBackgroundColor(colors.blue)
term.setTextColor(colors.white)
term.clear()

local win = window.create(term.current(), 5, 2, 12, 7)
CCGraphics.initGraphics(win)
CCGraphics.drawLine(win, 0, 0, 12, false, colors.yellow, colors.black)
CCGraphics.drawBox(win, 0, 1, 12, 6, colors.white)
CCGraphics.setString(win, 3, 0, "Window")
CCGraphics.drawCapture(win, 1, 2, image)
while true do
    local event = os.pullEvent()
    if event == "mouse_click" or event == "monitor_touch" then break end
end
CCGraphics.endGraphics(win)

win.setVisible(false)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
os.unloadAPI("CCGraphics")