A rectangular area that can be subclassed and rendered to.
## Constructor
CCView(*number* x, *number* y, *number* width, *number* height) <- [CCEventHandler](CCEventHandler.md)

* x: The X position of the view
* y: The Y position of the view
* width: The width of the view
* height: The height of the view
## Properties
* *table* parentWindow: The ComputerCraft window this view is inside
* _[CCApplication](CCApplication.md)_ application: The application this view is registered to
* *table* window: The ComputerCraft window this view is drawing to
* *table* subviews: The subviews owned by this view
* *color* backgroundColor: The color of the background of the view
* *table* frame: The frame of the view
    * *number* x: The X position of the view relative to the superview
    * *number* y: The Y position of the view relative to the superview
    * *number* width: The width of the view
    * *number* height: The height of the view
    * *number* absoluteX: The absolute X position of the view
    * *number* absoluteY: The absolute Y position of the view
## Methods
* *nil* setBackgroundColor(*color* color)
    * color: The color to set the background to
* *nil* draw(): Draws the view and all subviews. Override to add custom drawing. Make sure to redraw all subviews if overridden.
* *nil* addSubview(_CCView_ view): Adds a view that will be displayed inside this view.
    * view: The child view
* *nil* setParent(*table* parent, _[CCApplication](CCApplication.md)_ application, *string* name, *number* absoluteX, *number* absoluteY): Sets some variables that are passed from the caller.
    * parent: The parent ComputerCraft window of the view (created by `window.create(parentTerm, x, y, width, height)`)
    * application: The [CCApplication](CCApplication.md) this view will be registered to
    * name: The name of the [CCWindow](CCWindow.md) that this view is inside
    * absoluteX: The absolute X of the [CCWindow](CCWindow.md) that this view is inside
    * absoluteX: The absolute Y of the [CCWindow](CCWindow.md) that this view is inside
* *nil* deregisterSubview(_CCView_ view): Deregisters a subview from the application.
    * view: The subview to deregister
## Notes
Anything that is displayed on screen (aside from a window) is a view. GUI elements are just subclasses of CCView.  
To create your own view type, create a function with the name of your new class and create a new CCView variable inside it. Then override the `draw()` method and add whatever code you want to use to draw onto the screen. Lastly, remember to return the new modified CCView from the function.