local CCMenuItem = require "CCMenuItem"

local function CCMenu(title)
    local retval = {}
    retval.title = title
    retval.items = {}
    retval.supermenu = nil
    retval.minimumWidth = 1
    retval.highlightedItem = nil
    function retval:insertItem(item, index)
        table.insert(self.items, index, item)
    end
    function retval:insertItemWithTitle(str, action, keycombo, index)
        local item = CCMenuItem()
    end
    return retval
end

return CCMenu