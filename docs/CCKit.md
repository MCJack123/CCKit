This is the main API that you need to load. This will automatically load all other classes, which will be available under the CCKit API. This way you can use `CCKit.CCView()` instead of `CCView.CCView()`. This also makes it unnecessary to keep track of multiple APIs.  
There is only one function defined inside CCKit.  
## Main Function
*nil* CCMain(*number* initX, *number* initY, *number* initWidth, *number* initHeight, *string* title, *function* vcClass, *color* backgroundColor[, *string* appName[, *boolean* showName]]): Main function that creates one window with a view controller.
* initX: The X position of the window
* initY: The Y position of the window
* initWidth: The width of the window
* initHeight: The height of the window
* title: The title of the window
* vcClass: The constructor for the view controller of the window
* backgroundColor: The color of the background of the screen
* appName: The name of the app for logging, defaults to `title`
* showName: Whether to show the name at the top, defaults to false
## Notes
This function will return once the main window is closed. If your application needs more customization in its starting procedure, you can write your own main function.