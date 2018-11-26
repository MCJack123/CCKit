A class that controls a view inside a window.
## Constructor
CCViewController()
## Properties
* _[CCView](CCView.md)_ view: The inner view of the view controller
* _[CCWindow](CCWindow.md)_ pwindow: The window that this view controller is inside
* _[CCApplication](CCApplication.md)_ application: The application this view controller is registered to
## Methods
* *nil* loadView(_[CCWindow](CCWindow.md)_ win, _[CCApplication](CCApplication.md)_ app): Loads the view into the view controller.
    * win: The new `parentWindow`
    * app: The new `currentApplication`
* superLoadView = loadView
* *nil* viewDidLoad(): Called when the view is done loading. Put your code to add subviews here.
* *nil* dismiss(): Deregisters the view and its subviews to prepare for teardown.