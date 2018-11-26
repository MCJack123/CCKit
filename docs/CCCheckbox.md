A view that can be toggled on and off.
## Constructor
CCCheckbox(*number* x, *number* y[, *string* text]) <- [CCControl](CCControl.md)
* x: The X position of the checkbox
* y: The Y position of the checkbox
* text: Optional, text to display next to the checkbox
## Properties
* *boolean* isOn: The state of the checkbox
* *string* text: The text to draw next to the checkbox
* *color* textColor: The color of the text
## Methods
* *nil* setOn(*boolean* value): Sets the state of the checkbox.
    * value: The value of the checkbox
* *nil* setTextColor(*color* color): Sets the color of the text.
    * color: The color of the text
## Events
* checkbox_toggled: Fired when the checkbox is toggled.
    * *string*: The name of the button's event handler
    * *boolean*: The state of the checkbox