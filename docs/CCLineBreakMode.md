This sets constants that define how text should be wrapped in a CCTextView. This is used as an enumeration.
## Constants
* byWordWrapping: Wrap text by word
* byCharWrapping: Wrap text by character
* byClipping: Do not wrap text that overflows
* byTruncatingHead: Replace start of text with "..." to make the end fit
## Functions
*table* divideText(*string* text, *number* width, *CCLineBreakMode* mode): Divide text into lines using the line break mode
* text: The text to divide
* width: The width to fit the text into
* mode: The way the text should be divided