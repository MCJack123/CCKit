This table contains constants for use with CCKit's inner workings. These values can be customized to change the look of the UI as well as the location of all of the CCKit source files.  
This file **MUST** be placed at `/CCKit/CCKitGlobals.lua` for the other classes to find what they need. Other ones can be placed in the folder specified in CCKitDir.
## Constants
* *string* CCKitDir: The main directory where all of the CCKit files are located
* *boolean* shouldDoubleRequire: Whether require/loadAPI should try to load an API when it's already loaded
* *color* titleBarColor: The color of all title bars
* *color* titleBarTextColor: The color of all title bar text
* *color* windowBackgroundColor: The color of the background of windows
* *boolean* liveWindowMove: Whether windows should redraw their contents while moving
* *color* defaultTextColor: The default color of text
* *color* buttonColor: The color of a normal button
* *color* buttonSelectedColor: The color of a selected button
* *color* buttonHighlightedColor: The color of a highlighted button
* *color* buttonHighlightedSelectedColor: The color of a highlighted selected button
* *color* buttonDisabledColor: The color of a disabled button
* *color* buttonDisabledTextColor: The color of the text in a disabled button

## Global Functions
These functions are available at the global scope and are not addressed in CCKitGlobals.
* *function* require(*string* class): Returns the constructor for a class.
    * class: The name of the class
    * Returns: The constructor of the class
* *nil* loadAPI(*string* class): Loads a CCKit API from CCKitDir.
    * class: The name of the API
* *table* multipleInheritance(...): Combines tables to allow multiple inheritance.
    * ...: The tables/objects to combine
    * Returns: The new combined object
* *table* deepCopy(*table* orig): Copies a table and its values recursively.
    * orig: The original table to copy
    * Returns: A copy of orig
* *nil* setEGAColors(): For CC 1.8 only; sets the color palette to EGA colors.