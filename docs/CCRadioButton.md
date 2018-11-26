A type of checkbox that only allows one in a group to be selected at a time. Each radio button should be grouped inside a [CCRadioGroup](CCRadioGroup.md).
## Constructor
CCRadioButton(*number* x, *number* y[, *string* text]) <- [CCControl](CCControl.md)

* x: The X position of the radio button
* y: The Y position of the radio button
* text: Any text to display next to the button
## Properties
* *boolean* isOn: Whether the button is selected
* *string* text: Text to display next to the button
* *color* textColor: The color of the text
* *number* buttonId: The ID of the button in the group
* *string* groupName: The name of the group
## Methods
* *nil* setOn(*boolean* value): Sets whether the button is on.
    * value: Whether the button is on
* *nil* setTextColor(*color* color): Sets the color of the text.
    * color: The color of the text
## Events
* radio_selected: Fired when the radio button is selected.
    * *string*: The name of the group
    * *number*: The ID of the button