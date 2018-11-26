A view that displays an image saved by [CCGraphics](CCGraphics.md).
## Constructor
CCImageView(*number* x, *number* y, *table* image) <- [CCView](CCView.md)

* x: The X position of the image
* y: The Y position of the image
* image: The image to display
## Notes
This is a very simple view class which can serve as an example on how to subclass [CCView](CCView.md). There are no extra properties or methods.  
The image format is as follows: (formatting broken for now)

* *table* [0-`width`]: The columns of pixels as an array
    * *table* [0-`height`]: The cells of pixels as an array
        * *color* bgColor: The background color of the pixel
        * *color* fgColor: The foreground color of the pixel
        * *number* pixelCode: A 6-bit number describing the parts of the character to display (mini-pixels). Arranged L->R T->B.
        * *boolean* useCharacter: Whether to display a custom character instead.
        * *string* character: A custom character to draw instead of pixels.
* *number* width: The width of the image in mini-pixels
* *number* height: The height of the image in mini-pixels
* *number* termWidth: The width of the image in characters
* *number* termHeight: The height of the image in characters  

This table is saved with `textutils.serialize()` and loaded with `textutils.unserialize()`. The creator of the view is responsible for loading the file into a table.  
See [testimage.lon](https://github.com/MCJack123/CCKit/blob/master/testimage.lon) to see how the table is arranged. (The `lon` extension stands for Lua Object Notation, which I made up since this isn't JSON.)
