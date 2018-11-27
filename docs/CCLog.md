A logging system for applications. Creates `CCLog.default` which is a global log that automatically combines all other `CCLog`s.
## Constructor
CCLog(*string* name)

* name: The name of the log file
## Properties
* *boolean* showInDefaultLog: Whether to send messages to `CCLog.default`. Defaults to `true`.
* *table* shell: A reference to the `shell` API used by the program. Set this to give better feedback in the tracebacks.
## Methods
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
## Notes
When this API is loaded, a default logger is created that logs to `CCKit/logs/default.log`. This can be used without creating a custom logger.  
Any messages sent here will automatically be sent to the terminal window. Also, all loggers that are created will automatically send their messages to the default logger, unless `showInDefaultLog` is set to `false`.  
There are a few differences between a `CCLog` and the default log:

* There is no `showInDefaultLog` property, since this is the default log.
* A new property takes its place: `logToConsole`, which enables or disables outputting messages to the console.
* The log is automatically opened, so there's no need to open it after loading the API.
* All logging functions require an extra argument before `text`: the name of the caller, used to differentiate between programs/APIs.