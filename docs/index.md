# CCKit
A UI library for Computercraft that is designed similar to UIKit.

# Usage
Copy this entire repository into a folder named `CCKit` at the root of your ComputerCraft computer. (You can `cd` to the computer root and `git clone` the repo.)

# Quick Start
<span>1.</span> Load the `CCKit` api: 
```lua
os.loadAPI("CCKit/CCKit.lua")
```
<span>2.</span> Create a main view controller:
```lua
function MyViewController()
    local vc = CCKit.CCViewController()
    return vc
end
```
<span>3.</span> Put the code for the UI after creating `vc`:
```lua
function vc:viewDidLoad()
    local label = CCKit.CCLabel(1, 1, "Text")
    self:addSubview(label)
end
```
<span>4.</span> Start the main loop:
```lua
CCKit.CCMain(5, 2, 12, 4, "Window", MyViewController, colors.blue, "Application")
```

# Classes
Classes are created with `CCKit.<class>(<arguments>)` (e.g. `CCKit.CCLabel(x, y, text)`).  
All methods must be called with a colon and not a period (e.g. `textView:setText(text)`, not `textView.setText(text)`).  
See the sidebar for all of the classes.