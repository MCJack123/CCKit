A view that displays multi-line text.
## Constructor
CCTextView(*number* x, *number* y, *number* width, *number* height) <- [CCView](CCView.md)

* x: The X position of the text view
* y: The Y position of the text view
* width: The width of the text view
* height: The height of the text view
## Properties
* *color* textColor: The color of the text
* *string* text: The text to display
* _[CCLineBreakMode](CCLineBreakMode.md)_ lineBreakMode: The line break mode of the text
## Methods
* *nil* setText(*string* text): Sets the text
    * text: The text to set
* *nil* setTextColor(*color* color): Sets the text color
    * color: The color of the text to set
* *nil* setLineBreakMode(_[CCLineBreakMode](CCLineBreakMode.md)_ mode): Sets the line break mode
    * mode: The line break mode to set