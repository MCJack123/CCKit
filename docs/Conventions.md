This page documents the conventions of how information is displayed.
# Colors
Types are denoted in italics, with a *green* <span>coloring</span>. These are used to show the types of properties, parameters, and return values.  
After the type, the name will be colored depending on what it is.

* If it's a property or parameter, it will be colored as a <span class="name">name</span>.
* If it's a function, it will be colored as a <span class="func">function</span>.  
# Sections
Here, each section will be described. It will also be paired with what type of file the section will appear in, and if it's optional.
## Header
First, a brief description of what the file does is written at the top.
## Constructor (Classes)
This provides how to create a new instance of the class. Below, a description of each parameter is listed in an unordered list.
  
Class(*type* param1, *type* param2)

* <span class="name_desc">param1</span>: The first parameter
* <span class="name_desc">param2</span>: The second parameter
## Properties (Classes)
Each property is listed showing the type and name, as well as a description.

* *type* propertyName: Description of the property
## Methods (Classes)
The methods are listed giving the return type, the name, and each argument with its expected type. After, a brief description of what the method does is given. Below it, each argument is described. Methods must be called with `object:method()` instead of `object.method()`.

* *type* methodName(*type* arg1, *type* arg2): A sample method.
    * arg1: The first argument
    * arg2: The second argument
    * Returns: A value
## Events (Classes, optional)
This section describes what events the class can send.

* <span class="name">event_name</span>: An event this class can send.
    * *type*: The first parameter
    * *type*: The second parameter
## Constants (APIs, optional)
These are listed like properties, but are instead under the scope of the API.

* *type* constantName: A description of the constant
## Functions (APIs)
These are also listed like methods, but are called with `API.func()` instead.

* *type* functionName(*type* arg1, *type* arg2): A sample function.
    * arg1: The first argument
    * arg2: The second argument
    * Returns: A value