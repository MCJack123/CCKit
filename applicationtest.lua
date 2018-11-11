--if not os.loadAPI("CCKit/CCKitAmalgamated.lua") then error("could not load CCKit") end
--CCKit = CCKitAmalgamated
if not os.loadAPI("CCKit/CCKit.lua") then error("could not load CCKit") end

function AlertViewController()
    local retval = CCKit.CCViewController()
    retval.button2 = CCKit.CCButton(7, 5, 4, 1)
    function retval:close()
        --print("Closing")
        self.view:deregisterSubview(self.button2)
        os.queueEvent("closed_window", self.parentWindow.name)
    end
    function retval:viewDidLoad()
        local label = CCKit.CCTextView(1, 1, 18, 4)
        label:setText("This is a long string of text to test if the text view works right.")
        self.view:addSubview(label)
        self.button2:setText("OK")
        self.button2:setAction(self.close, self)
        self.view:addSubview(self.button2)
    end
    return retval
end

function MyViewController()
    local retval = CCKit.CCViewController()
    function retval:alert()
        --print("Button clicked")
        newwin = CCKit.CCWindow(20, 5, 20, 8)
        newwin:setTitle("Alert")
        local newvc = AlertViewController()
        newwin:setViewController(newvc, self.currentApplication)
        newwin:redraw()
        self.currentApplication:registerObject(newwin, newwin.name)
    end
    function retval:viewDidLoad()
        local file = fs.open("CCKit/testimage.lon", "r")
        local image = textutils.unserialize(file.readAll())
        file.close()
        local imview = CCKit.CCImageView(1, 1, image)
        self.view:addSubview(imview)
        local label = CCKit.CCLabel(1, 0, "Image:")
        self.view:addSubview(label)
        local button = CCKit.CCButton(2, 5, 8, 1)
        button:setText("Alert")
        button:setAction(self.alert, self)
        self.view:addSubview(button)
    end
    return retval
end

CCKit.CCMain(5, 2, 12, 8, "Picture", MyViewController, colors.blue, "applicationtest")