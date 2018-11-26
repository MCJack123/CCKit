A text box that allows the user to enter text.
## Constructor
CCTextField(*number* x, *number* y, *number* width) <- [CCView](CCView.md), [CCEventHandler](CCEventHandler.md)

* x: The X position of the text field
* y: The Y position of the text field
* width: The width of the text field
## Properties
* *string* text: The text that has been entered into the field
* *boolean* isSelected: Whether the field is selected
* *boolean* isEnabled: Whether the field is enabled
* *color* textColor: The color of the text
* *string* placeholderText: Placeholder text to display when the box is unselected and empty, set to nil to disable
## Methods
* *nil* setTextColor(*color* color): Sets the color of the text.
    * color: The color of the text
* *nil* setEnabled(*boolean* e): Sets whether the field is enabled.
    * e: Whether the field is enabled
* *nil* setPlaceholder(*string* text): Sets the placeholder text to display.
    * text: The placeholder text