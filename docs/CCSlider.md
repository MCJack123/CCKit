A view that allows users to control an analog value.
## Constructor
CCSlider(*number* x, *number* y, *number* width) <- [CCControl](CCControl.md)

* x: The X position of the slider
* y: The Y position of the slider
* width: The width of the slider
## Properties
* *number* value: The current value of the slider
* *number* minimumValue: The minimum value of the slider
* *number* maximumValue: The maximum value of the slider
* *color* minimumColor: The color of the left side of the slider
* *color* maximumColor: The color of the right side of the slider
* *color* buttonColor: The color of the button on the slider
## Methods
* *nil* setValue(*number* value): Sets the value of the slider.
    * value: The value of the slider
## Events
* slider_dragged: Fired when the slider changes values.
    * *string*: The name of the slider's event handler
    * *number*: The value of the slider