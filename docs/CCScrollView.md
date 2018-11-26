A view that allows displaying subviews that are taller than the window -- basically a "porthole" into a larger view.
## Constructor
CCScrollView(*number* x, *number* y, *number* width, *number* height, *number* innerHeight) <- [CCView](CCView.md), [CCEventHandler](CCEventHandler.md)

* x: The X position of the scroll view
* y: The Y position of the scroll view
* width: The width of the scroll view
* height: The height of the scroll view
* innerHeight: The height of the inner content view
## Properties
* *number* contentHeight: The height of the content view
* *number* currentOffset: The number of lines the content has been scrolled down
## Methods
* *nil* scroll(*number* direction, *number* px, *number* py): Scrolls the view by one in a direction. Set px and py to a value inside the view's frame.
    * direction: 1 for down, -1 for up
    * px: The X position of the scroll (set to frame.absoluteX)
    * py: The Y position of the scroll (set to frame.absoluteY)