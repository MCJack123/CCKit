local class = require "class"

-- Key combo consists of a list of keys that must be down
local CCMenuItem
CCMenuItem = class "CCMenuItem" {
    static = {
        separator = function()
            local retval = CCMenuItem()
            retval.isSeparatorItem = true
            return retval
        end
    },
    isEnabled = true,
    isHidden = false,
    target = nil,
    tag = 0,
    isSelected = false,
    submenu = nil,
    hasSubmenu = false,
    isSeparatorItem = false,
    menu = nil,
    indentationLevel = 0,
    __init = function(title, action, keycombo)
        self.action = action
        self.title = title
        self.keycombo = keycombo
    end
}

return CCMenuItem