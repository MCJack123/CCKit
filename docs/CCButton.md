A view that can be clicked to produce an action.
## Constructor
CCButton(*number* x, *number* y, *number* width, *number* height) <- [CCControl](CCControl.md)
* x: The X position of the button
* y: The Y position of the button
* width: The width of the button
* height: The height of the button
## Properties
* *string* text: The text of the button
* *color* textColor: The color of the text
## Methods
* *nil* setAction(*function* func, *any* object): Sets the action to run when the button is clicked.
    * func: The function to call
    * object: An argument that is passed to the function.
* *nil* setText(*string* text): Sets the text of the button.
    * text: The text to set
* *nil* setTextColor(*color* color): Sets the color of the text.
    * color: The color to set