A class that loads image files and converts them to CCGraphics images.
## Constructor
CCImageLoader()
## Properties
* *boolean* isOpen: Whether the file has been opened
* _[CCImageType](CCImageType.md)_ type: The type of image that is being processed
## Methods
* *number* open(*string* file): Opens an image file.
    * file: The path to the file to open
    * Returns: 0 if successful, 1 if type couldn't be detected, -1 if failure
* *table* read(): Reads the image into a [CCGraphics](CCGraphics.md) image.
    * Returns: The new image file
* *nil* close(): Closes the image file.