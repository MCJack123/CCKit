local function CCMenuItem(title, action, keycombo)
    local retval = {}
    retval.isEnabled = true
    retval.isHidden = false
    retval.target = nil
    retval.action = action
    retval.title = title
    retval.isSelected = false
    retval.submenu = nil
    retval.hasSubmenu = false
    retval.isSeparatorItem = false
    retval.menu = nil
    retval.keycombo = keycombo
    retval.indentationLevel = 0
    
    return retval
end

return CCMenuItem