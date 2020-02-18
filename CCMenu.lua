local CCKitGlobals = require "CCKitGlobals"
local CCMenuItem = require "CCMenuItem"
local CCView = require "CCView"
local CCGraphics = require "CCGraphics"
local CCEventHandler = require "CCEventHandler"
local CCWindowRegistry = require "CCWindowRegistry"

local function CCContextMenuView(x, y, menu)
    local maxw = menu.minimumWidth
    for _,v in ipairs(menu.items) do maxw = math.max(maxw, v.indentationLevel + #v.title) end
    local retval = CCKitGlobals.multipleInheritance(CCView(x, y, maxw), CCEventHandler("CCContextMenuView"))
    retval.menu = menu
    retval.didSelect = false
    function retval:draw()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            for k,v in ipairs(self.menu.items) do
                if self.menu.highlightedItem == k then CCGraphics.drawLine(self.window, 0, k-1, self.frame.width, false, CCKitGlobals.buttonColor) end
                CCGraphics.setString(self.window, 0, k-1, v.title)
            end
            for _,v in pairs(self.subviews) do v:draw() end
        end
    end
    function retval:select(button, px, py)
        if not CCWindowRegistry.rayTest(self, px, py) then return false end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.action ~= nil and self.isEnabled then 
            self.menu.highlightedItem = px - bx + 1
            self.didSelect = true
            self:draw()
            self.menu:performActionForItem(self.menu.highlightedItem)
            self.menu:cancelTracking()
            return true
        end
        self.menu:cancelTracking()
        return false
    end
    retval:addEvent("mouse_click", retval.select)
    return retval
end

local function CCMenu(title)
    local retval = {}
    retval.title = title
    retval.items = {}
    retval.supermenu = nil
    retval.minimumWidth = 1
    retval.highlightedItem = nil
    retval.menuView = nil
    function retval:insertItem(item, index)
        table.insert(self.items, index, item)
    end
    function retval:insertItemWithTitle(str, action, keycombo, index)
        local item = CCMenuItem(str, action, keycombo)
        table.insert(self.items, index, item)
        return retval
    end
    function retval:addItem(item) self:insertItem(item, #self.items) end
    function retval:addItemWithTitle(str, action, keycombo) return self:insertItemWithTitle(str, action, keycombo, #self.items) end
    function retval:removeItem(item) -- note: this checks the table pointer, NOT the table value
        for i,v in ipairs(self.items) do if v == item then
            table.remove(self.items, i)
            return
        end end
    end
    function retval:removeItemAt(idx)
        table.remove(self.items, idx)
    end
    function retval:removeAllItems()
        self.items = {}
    end
    local function findItem(tab, comp)
        for i,v in ipairs(tab) do if comp(v) then return i, v end end
        return nil
    end
    function retval:itemWithTag(tag)
        return select(2, findItem(self.items, function(v) return v.tag == tag end))
    end
    function retval:itemWithTitle(title)
        return select(2, findItem(self.items, function(v) return v.title == title end))
    end
    function retval:itemAt(idx)
        return self.items[idx]
    end
    function retval:numberOfItems()
        return #self.items
    end
    function retval:indexOf(item)
        return select(1, findItem(self.items, function(v) return v == item end))
    end
    function retval:indexOfItemWithTitle(title)
        return select(1, findItem(self.items, function(v) return v.title == title end))
    end
    function retval:indexOfItemWithTag(tag)
        return select(1, findItem(self.items, function(v) return v.tag == tag end))
    end
    function retval:indexOfItemWithTarget(target, action)
        return select(1, findItem(self.items, function(v) return v.target == target and v.action == action end))
    end
    function retval:indexOfItemWithSubmenu(submenu)
        return select(1, findItem(self.items, function(v) return v.submenu == submenu end))
    end
    function retval:setSubmenu(menu, item)
        item.submenu = menu
    end
    function retval:performKeyEquivalent(keysDown) -- expects table with list of keys down
        local item = findItem(self.items, function(v)
            if v.keycombo == nil or #v.keycombo ~= #keysDown or v.action == nil then return false end
            for _,w in ipairs(v.keycombo) do
                local found = false
                for _,x in ipairs(keysDown) do if w == x then 
                    found = true
                    break
                end end
                if not found then return false end
            end
            return true
        end)
        if item == nil then return false else
            item:action(item.target)
            return true
        end
    end
    function retval:performActionForItem(idx)
        local _ = self.items[idx] and self.items[idx].action and self.items[idx]:action(self.items[idx].target)
    end
    function retval:popUpContextMenu(event, view)
        if self.menuView ~= nil then self.menuView:removeFromSuperview() end
        self.menuView = CCContextMenuView(0, 0, self)
        view:addSubview(self.menuView)
    end
    function retval:cancelTracking()
        if self.menuView == nil then return end
        self.menuView:removeFromSuperview()
    end
    return retval
end

return CCMenu