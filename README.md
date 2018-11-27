# CCKit
A UI library for Computercraft that is designed similar to UIKit.  
This branch is for development for CCKitOS. It includes extra features that only work under CCKitOS.

# Usage
Copy this entire repository into a folder named `CCKit` at the root of your ComputerCraft computer. (You can `cd` to the computer root and `git clone` the repo.)

# Quick Start
1. Load the `CCKit` api:
```lua
os.loadAPI("CCKit/CCKit.lua")
```
2. Create a main view controller:
```lua
function MyViewController()
    local vc = CCKit.CCViewController()
    return vc
end
```
3. Put the code for the UI after creating `vc`:
```lua
function vc:viewDidLoad()
    local label = CCKit.CCLabel(1, 1, "Text")
    self:addSubview(label)
end
```
4. Start the main loop:
```lua
CCKit.CCMain(5, 2, 12, 4, "Window", MyViewController, colors.blue, "Application")
```

# Classes
Classes are created with `CCKit.<class>(<arguments>)` (e.g. `CCKit.CCLabel(x, y, text)`) if you load the CCKit API.  
All methods must be called with a colon and not a period (e.g. `textView:setText(text)`, not `textView.setText(text)`).  
  
See the [wiki](https://github.com/MCJack123/CCKit/wiki) for a list of classes.