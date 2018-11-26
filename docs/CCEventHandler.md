A protocol/interface that [CCApplication](CCApplication.md) uses to handle events.
## Constructor
CCEventHandler(*string* class)

* class: The name of the class of object
## Properties
* *string* name: A unique name for the object
* *string* class: The name of the class of object
* *boolean* hasEvents: Set to true for compatibility with [CCView](CCView.md)
* *table* events: The events this object listens to
    * *table* `<event name>`: The actions and objects to call on each event. See all events [on the CC wiki](http://www.computercraft.info/wiki/Os.pullEvent#Event_types).
        * *function* func: The function to call
        * *string* self: The name of this object
## Methods
* *nil* addEvent(*string* name, *function* func): Adds an event handler to the object's list of events.
    * name: The name of the event
    * func: The function to call