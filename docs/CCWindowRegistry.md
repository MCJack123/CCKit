A library for storing information on the position of windows, allowing hit testing at points.
## Functions
* *nil* registerApplication(*string* appname): Registers a [CCApplication](CCApplication.md) in the window registry.
    * appname: The application's .name property
* *nil* registerWindow(_[CCWindow](CCWindow.md)_ win): Registers a window in the window registry.
    * win: The window to register
* *nil* deregisterApplication(*string* appname): Deregisters a CCApplication in the window registry.
    * appname: The application's .name property
* *nil* deregisterWindow(_CCWindow_ win): Deregisters a window in the window registry.
    * win: The window to deregister
* *nil* setAppZ(*string* appname, *number* z): Sets the Z position of the app.
* *nil* setAppTop(*string* appname): Sets the Z position of the app to the top.
* *nil* setWinZ(*CCWindow* win, *number* z): Sets the Z position of the window.
* *nil* setWinTop(*CCWindow* win): Sets the Z position of the window to the top.
* *nil* moveWin(*CCWindow* win, *number* x, *number* y): Changes the position of a window.
* *nil* resizeWin(*CCWindow* win, *number* w, *number* h): Changes the size of a window.
* *boolean* isAppOnTop(*string* appname): Returns whether the app is on the top.
* *boolean* isWinOnTop(*CCWindow* win): Returns whether the window is on the top.
* *boolean* hitTest(*CCWindow* win, *number* px, *number* py): Returns whether the point is inside the window. Don't use this, use rayTest().
* *number* getAppZ(*string* appname): Returns the Z position of the app.
* *boolean* rayTest(*CCWindow* win, *number* px, *number* py): Tests if the mouse cursor is pointing at the window on the screen.