The main manager for the application. Handles events and redistributes them to other objects.  
## Constructor
CCApplication(*string* name)

* name: The name of the application (registered in the logs)
## Properties
* *boolean* isApplicationRunning: Whether to run the loop. Set to `true` before calling `runLoop()`. Only useful with coroutines.
* *color* backgroundColor: The color of the background
* *object* log: The logger (see [CCLog](CCLog.md)). If `name` is `nil`, this will be [CCLog](CCLog.md).default. <u>Use this to log, do not make a new `CCLog`!</u>
* *boolean* showName: Whether to show the name of the program at the top
## Methods
* *nil* setBackgroundColor(*color* color): Sets the color that will be drawn in the background.
    * color: The color to set
* *nil* registerObject(*object* win, *string* name\[, *boolean* up = true\]): Registers an object's events with the application.
    * win: The object that will be registered, can be any object that has events
    * name: A unique name identifying the object (usually automatically set)
    * up: Whether this is a window
* *nil* deregisterObject(*string* name)
    * name: The name of the object to remove
* *nil* runLoop(): The main loop of the application.
* *nil* startRunLoop(): Runs the main loop in a coroutine.
* *nil* stopRunLoop(): Stops the main loop.