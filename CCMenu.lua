local class = require "class"
local CCKitGlobals = require "CCKitGlobals"
local CCMenuItem = require "CCMenuItem"
local CCView = require "CCView"
local CCGraphics = require "CCGraphics"
local CCEventHandler = require "CCEventHandler"
local CCWindowRegistry = require "CCWindowRegistry"

local CCContextMenuView = class "CCContextMenuView" {extends = {CCEventHandler, CCView}} {
    didSelect = false,
    __init = function(x, y, menu)
        local maxw = menu.minimumWidth
        for _,v in ipairs(menu.items) do maxw = math.max(maxw, v.indentationLevel + #v.title) end
        _ENV.CCView(x, y, maxw)
        _ENV.CCEventHandler("CCContextMenuView")
        self.menu = menu
        self.addEvent("mouse_click", self.select)
    end,
    draw = function()
        if self.parentWindow ~= nil then
            CCGraphics.drawBox(self.window, 0, 0, self.frame.width, self.frame.height, self.backgroundColor)
            for k,v in ipairs(self.menu.items) do
                if self.menu.highlightedItem == k then CCGraphics.drawLine(self.window, 0, k-1, self.frame.width, false, CCKitGlobals.buttonColor) end
                CCGraphics.setString(self.window, 0, k-1, v.title)
            end
            for _,v in pairs(self.subviews) do v.draw() end
        end
    end,
    select = function(button, px, py)
        if not CCWindowRegistry.rayTest(self, px, py) then return false end
        local bx = self.frame.absoluteX
        local by = self.frame.absoluteY
        if px >= bx and py >= by and px < bx + self.frame.width and py < by + self.frame.height and button == 1 and self.action ~= nil and self.isEnabled then 
            self.menu.highlightedItem = px - bx + 1
            self.didSelect = true
            self.draw()
            self.menu.performActionForItem(self.menu.highlightedItem)
            self.menu.cancelTracking()
            return true
        end
        self.menu.cancelTracking()
        return false
    end
}

local function findItem(tab, comp)
    for i,v in ipairs(tab) do if comp(v) then return i, v end end
    return nil
end

return class "CCMenu" {
    supermenu = nil,
    minimumWidth = 1,
    highlightedItem = nil,
    menuView = nil,
    __init = function(title)
        self.title = title
        self.items = {}
    end,
    insertItem = function(item, index)
        table.insert(self.items, index, item)
    end,
    insertItemWithTitle = function(str, action, keycombo, index)
        local item = CCMenuItem(str, action, keycombo)
        table.insert(self.items, index, item)
        return item
    end,
    addItem = function(item) self.insertItem(item, #self.items) end,
    addItemWithTitle = function(str, action, keycombo) return self.insertItemWithTitle(str, action, keycombo, #self.items) end,
    removeItem = function(item) -- note: this checks the table pointer, NOT the table value
        for i,v in ipairs(self.items) do if v == item then
            table.remove(self.items, i)
            return
        end end
    end,
    removeItemAt = function(idx)
        table.remove(self.items, idx)
    end,
    removeAllItems = function()
        self.items = {}
    end,
    itemWithTag = function(tag)
        return select(2, findItem(self.items, function(v) return v.tag == tag end))
    end,
    itemWithTitle = function(title)
        return select(2, findItem(self.items, function(v) return v.title == title end))
    end,
    itemAt = function(idx)
        return self.items[idx]
    end,
    numberOfItems = function()
        return #self.items
    end,
    indexOf = function(item)
        return select(1, findItem(self.items, function(v) return v == item end))
    end,
    indexOfItemWithTitle = function(title)
        return select(1, findItem(self.items, function(v) return v.title == title end))
    end,
    indexOfItemWithTag = function(tag)
        return select(1, findItem(self.items, function(v) return v.tag == tag end))
    end,
    indexOfItemWithTarget = function(target, action)
        return select(1, findItem(self.items, function(v) return v.target == target and v.action == action end))
    end,
    indexOfItemWithSubmenu = function(submenu)
        return select(1, findItem(self.items, function(v) return v.submenu == submenu end))
    end,
    setSubmenu = function(menu, item)
        item.submenu = menu
    end,
    performKeyEquivalent = function(keysDown) -- expects table with list of keys down
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
            item.action(item.target)
            return true
        end
    end,
    performActionForItem = function(idx)
        local _ = self.items[idx] and self.items[idx].action and self.items[idx].action(self.items[idx].target)
    end,
    popUpContextMenu = function(event, view)
        if self.menuView ~= nil then self.menuView.removeFromSuperview() end
        self.menuView = CCContextMenuView(0, 0, self)
        view.addSubview(self.menuView)
    end,
    cancelTracking = function()
        if self.menuView == nil then return end
        self.menuView.removeFromSuperview()
    end
}