A custom window displaying a message to the user.
## Constructor
CCAlertWindow(*number* x, *number* y, *number* width, *number* height, *string* title, *string* message, _[CCApplication](CCApplication.md)_ application) <- [CCWindow](CCWindow.md)  

* x: The X position of the alert
* y: The Y position of the alert
* width: The width of the alert
* height: The height of the alert
* title: The title displayed at the top of the window
* message: The message body to display in the window
* application: The current application
### Example
```lua
local alert = CCKit.CCAlertWindow(2, 2, 10, 5, "Alert", "Hello World!", self.application)
self.window:present(alert)
```