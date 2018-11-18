-- CCScrollView.lua
-- CCKit
--
-- This creates the CCScrollView class, which is used to display subviews
-- that would otherwise be too tall for the area.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
os.loadAPI(CCKitGlobals.CCKitDir.."/CCView.lua")

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

function CCScrollView(x, y, width, height, innerHeight)
    local retval = CCView.CCView(x, y, width, height)
    retval.name = string.random(8)
    retval.contentHeight = innerHeight
    retval.currentOffset = 0
    retval.hasEvents = true
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            for k,v in pairs(self.subviews) do 
                if v.frame.y < self.frame.height + self.currentOffset then
                    v.window.setVisible(true)
                    v:draw() 
                else
                    v.window.setVisible(false)
                end
            end
        end
    end
    function retval:scroll(direction, px, py)
        if px >= self.frame.absoluteX and py >= self.frame.absoluteY and px < self.frame.absoluteX + self.frame.width and py < self.frame.absoluteY + self.frame.height then
            self.currentOffset = self.currentOffset + direction
            --self:draw()
            return true
        end
        return false
    end
    retval.events = {mouse_scroll = {func = retval.scroll, self = retval.name}}
    return retval
end
