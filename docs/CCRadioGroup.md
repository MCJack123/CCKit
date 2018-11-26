A view that controls a group of [CCRadioButton](CCRadioButton.md)s.
## Constructor
CCRadioGroup(*number* x, *number* y, *number* width, *number* height) <- [CCView](CCView.md), [CCEventHandler](CCEventHandler.md)

* x: The X position of the group
* y: The Y position of the group
* width: The width of the group
* height: The height of the group
## Properties
* *number* selectedId: The ID of the currently selected button
* *number* nextId: The number of buttons inside the group
## Methods
* *nil* setAction(*function* func, *any* obj): Sets the action to call when a button is selected.
    * func: A function of the form `function(obj, selectedId)` that will be called when a button is selected
    * obj: A value to pass to func, usually `self`
