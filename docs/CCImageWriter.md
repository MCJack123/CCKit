A class that writes image files and converts them from CCGraphics images.
## Constructor
CCImageWriter()
## Properties
* *boolean* isOpen: Whether the file has been opened
* _[CCImageType](CCImageType.md)_ type: The type of image that is being processed
## Methods
* *number* open(*string* file): Opens an image file.
    * file: The path to the file to open
    * Returns: 0 if successful, 1 if type couldn't be detected, -1 if failure
* *nil* write(*table* image): Writes a [CCGraphics](CCGraphics.md) image to the file.
    * image: The image to write
* *nil* close(): Closes the image file.