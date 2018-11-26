A view that can be interacted with by the user.
## Constructor
CCControl(*number* x, *number* y, *number* width, *number* height) <- [CCView](CCView.md), [CCEventHandler](CCEventHandler.md)

* x: The X position of the control
* y: The Y position of the control
* width: The width of the control
* height: The height of the control
## Properties
* *boolean* hasEvents: Whether the control has events (probably true)
* *boolean* isEnabled: Whether the control is enabled
* *boolean* isSelected: Whether the control is being clicked on
* *boolean* isHighlighted: Whether the control can be selected with enter
* *function* action: The function to call when the control is selected
## Methods
* *nil* setAction(*function* func, *any* obj): Sets the function to call when the control is selected.
    * func: The function to call
    * obj: An object that will be sent as the first object and/or self
* *nil* setHighlighted: Sets whether the control is highlighted.
    * h: Whether the control is highlighted
* *nil* setEnabled: Sets whether the control is enabled.
    * e: Whether the control is enabled