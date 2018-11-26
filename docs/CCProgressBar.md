A progress bar that displays the progress of a task.
## Constructor
CCProgressBar(*number* x, *number* y, *number* width) <- [CCView](CCView.md)

* x: The X position of the bar
* y: The Y position of the bar
* width: The width of the bar
## Properties
* *color* foregroundColor: The color that shows completed progress
* __*color* backgroundColor__: The color that shows uncompleted progress (already defined by [CCView](CCView.md))
* *number* progress: How far the task is to completion as a decimal from 0.0 to 1.0
* *boolean* indeterminate: Whether the bar shows progress
## Methods
* *nil* setProgress(*number* progress): Sets the progress and redraws.
    * progress: The new progress to set
* *nil* setIndeterminate(*boolean* id): Sets whether the bar is indeterminate.
    * id: Whether the bar is indeterminate