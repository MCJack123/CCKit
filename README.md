# CCKit
A UI library for Computercraft that is designed similar to UIKit.

## Usage
Copy this entire repository into a folder named `CCKit` at the root of your ComputerCraft computer. (You can `cd` to the computer root and `git clone` the repo.)

## Quick Start
1. Load the `CCKit` api:
```
os.loadAPI("CCKit/CCKit.lua")
```
2. Create a main view controller:
```
function MyViewController()
    local vc = CCKit.CCViewController()
    return vc
end
```
3. Put the code for the UI after creating `vc`:
```
function vc:viewDidLoad()
    local label = CCKit.CCLabel(1, 1, "Text")
    self:addSubview(label)
end
```
4. Start the main loop:
```
CCKit.CCMain(5, 2, 12, 4, "Window", MyViewController, colors.blue, "Application")
```

## Classes
Classes are created with `<class>.<class>(<arguments>)` (e.g. `CCLabel.CCLabel(x, y, text)`).  
All methods must be called with a colon and not a period (e.g. `textView:setText(text)`, not `textView.setText(text)`).

### <a name="CCApplication">CCApplication</a>
The main manager for the application. Handles events and redistributes them to other objects.  
#### Constructor
CCApplication(*string* name)
* name: The name of the application (registered in the logs)
#### Properties
* *boolean* isApplicationRunning: Whether to run the loop. Set to `true` before calling `runLoop()`. Only useful with coroutines.
* *color* backgroundColor: The color of the background
* *object* log: The logger (see [CCLog](#CCLog)). If `name` is `nil`, this will be [CCLog](#CCLog).default. <u>Use this to log, do not make a new `CCLog`!</u>
#### Methods
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

### <a name="CCLog">CCLog</a>
A logging system for applications. Creates `CCLog.default` which is a global log that automatically combines all other `CCLog`s.
#### Constructor
CCLog(*string* name)
* name: The name of the log file
#### Properties
* *boolean* showInDefaultLog: Whether to send messages to `CCLog.default`. Defaults to `true`.
* *table* shell: A reference to the `shell` API used by the program. Set this to give better feedback in the tracebacks.
#### Methods
* *nil* open(): Opens the file for writing logs. Call this before using the logger.
* *nil* close(): Closes the file. Call this when done using the logger.
* *nil* debug(*string* text\[, *string* class\[, *number* lineno\]\]): Log text as a debug message.
    * text: Message text
    * class: The class reporting the message
    * lineno: The relevant line number to the message
* *nil* log(*string* text\[, *string* class\[, *number* lineno\]\]): Log text as a default/info message.
    * text: Message text
    * class: The class reporting the message
    * lineno: The relevant line number to the message
* *nil* warn(*string* text\[, *string* class\[, *number* lineno\]\]): Log text as a warning message.
    * text: Message text
    * class: The class reporting the message
    * lineno: The relevant line number to the message
* *nil* error(*string* text\[, *string* class\[, *number* lineno\]\]): Log text as an error message.
    * text: Message text
    * class: The class reporting the message
    * lineno: The relevant line number to the message
* *nil* critical(*string* text\[, *string* class\[, *number* lineno\]\]): Log text as a critical error message.
    * text: Message text
    * class: The class reporting the message
    * lineno: The relevant line number to the message
* *nil* traceback(*string* errortext\[, *string* class\[, *number* lineno\]\]): Prints a traceback to the log.
    * errortext: Message text placed at the top
    * class: The class reporting the message
    * lineno: The relevant line number to the message
#### Notes
When this API is loaded, a default logger is created that logs to `CCKit/logs/default.log`. This can be used without creating a custom logger.  
Any messages sent here will automatically be sent to the terminal window. Also, all loggers that are created will automatically send their messages to the default logger, unless `showInDefaultLog` is set to `false`.  
There are a few differences between a `CCLog` and the default log:
* There is no `showInDefaultLog` property.
* A new property takes its place: `logToConsole`, which enables or disables outputting messages to the console.
* The log is automatically opened, so there's no need to open it after loading the API.
* All logging functions require an extra argument before `text`: the name of the caller, used to differentiate between programs/APIs.
