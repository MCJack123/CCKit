A window with decorations that holds views.
## Constructor
CCWindow(*number* x, *number* y, *number* width, *number* height) <- [CCEventHandler](CCEventHandler.md)

* x: The X position of the window
* y: The Y position of the window
* width: The width of the window
* height: The height of the window
## Properties
* *table* window: The ComputerCraft window this window occupies
* *string* title: The text in the title bar
* *table* frame: The frame of the window
    * *number* x: The X position of the window relative to the superview
    * *number* y: The Y position of the window relative to the superview
    * *number* width: The width of the window
    * *number* height: The height of the window
* *table* defaultFrame: The frame of the window when not maximized
* _[CCViewController](CCViewController.md)_ viewController: The view controller that holds the views inside the window
* *color* repaintColor: The default color of the window when there isn't a view controller
* _[CCApplication](CCApplication.md)_ application: The application this window is registered to
* *boolean* maximized: Whether the window is maximized
* *boolean* maximizable: Whether the window can be maximized (hides/shows green box in title bar)
* *boolean* showTitleBar: Whether to show a title bar
## Methods
* *nil* redraw(): Redraws the window.
* *nil* resize(*number* newWidth, *number* newHeight): Resizes the window to a new size.
    * newWidth: The new width of the window
    * newHeight: The new height of the window
* *nil* setTitle(*string* str): Sets the title of the window
    * str: The new title of the window
* *nil* setViewController(_[CCViewController](CCViewController.md)_ vc, _[CCApplication](CCApplication.md)_ app): Sets the view controller and application for the window.
    * vc: The new view controller of the window
    * app: The application to register the window to
* *nil* registerObject(_[CCEventHandler](CCEventHandler.md)_ obj): Registers an object to the application. Use this instead of [CCApplication](CCApplication.md).registerObject().
    * obj: The object to register, must conform to [CCEventHandler](CCEventHandler.md)
* *nil* close(): Closes the window.
* *nil* present(*CCWindow* newwin): Shows a window on screen.
    * newwin: The new window to show
