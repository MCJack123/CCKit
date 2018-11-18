--if not os.loadAPI("CCKit/CCKitAmalgamated.lua") then error("could not load CCKit") end
--CCKit = CCKitAmalgamated
if not os.loadAPI("CCKit/CCKit.lua") then error("could not load CCKit") end

function AlertViewController()
    local retval = CCKit.CCViewController()
    retval.button2 = CCKit.CCButton(7, 5, 4, 1)
    function retval:close()
        --print("Closing")
        --CCLog.default:debug("applicationtest", textutils.serialize(self))
        self.window:close()
    end
    function retval:viewDidLoad()
        local label = CCKit.CCTextView(1, 1, 18, 4)
        label:setText("This is a long string of text to test if the text view works right.")
        self.view:addSubview(label)
        self.button2:setText("OK")
        self.button2:setAction(self.close, self)
        self.button2:setHighlighted(true)
        self.view:addSubview(self.button2)
    end
    return retval
end

function MyViewController()
    local retval = table.combine(CCKit.CCViewController(), CCEventHandler.CCEventHandler("MyViewController"))
    retval.toggleName = nil
    retval.sliderName = nil
    retval.button = CCKit.CCButton(2, 8, 8, 1)
    retval.counter = CCKit.CCLabel(13, 5, " 0")
    function retval:toggle(name, value)
        if name == self.toggleName then 
            self.button:setEnabled(value) 
            return true
        end
        return false
    end
    function retval:dragged(name, value)
        if name == self.sliderName then
            if value < 10 then self.counter.text = " " else self.counter.text = "" end
            self.counter.text = self.counter.text .. tostring(math.floor(value))
            self.counter:draw()
            return true
        end
        return false
    end
    function retval:alert()
        --print("Button clicked")
        newwin = CCKit.CCWindow(20, 5, 20, 8)
        newwin.maximizable = false
        newwin:setTitle("Alert")
        local newvc = AlertViewController()
        newwin:setViewController(newvc, self.application)
        newwin:redraw()
        self.application:registerObject(newwin, newwin.name)
    end
    function retval:viewDidLoad()
        local loader = CCKit.CCImageLoader()
        local res = loader:open("CCKit/testimage.lon")
        if res == 1 then loader.type = CCImageType.ccg
        elseif res == -1 then self.application.log:error("Could not open image file") end
        local image = loader:read()
        if image.termWidth == 0 then error("Error reading file") end
        loader:close()
        --self.application.log:debug(textutils.serialize(image))
        local imview = CCKit.CCImageView(1, 1, image)
        self.view:addSubview(imview)
        local label = CCKit.CCLabel(1, 0, "Image:")
        self.view:addSubview(label)
        self.view:addSubview(self.counter)
        local slider = CCKit.CCSlider(1, 6, 14)
        slider.maximumValue = 99
        self.sliderName = slider.name
        self.view:addSubview(slider)
        local checkbox = CCKit.CCCheckbox(1, 7, "Enabled")
        checkbox.isOn = true
        self.toggleName = checkbox.name
        self.view:addSubview(checkbox)
        self.button:setText("Alert")
        self.button:setAction(self.alert, self)
        self.view:addSubview(self.button)
        self:addEvent("checkbox_toggled", self.toggle)
        self:addEvent("slider_dragged", self.dragged)
        self.window:registerObject(self)
        --self.application.log:debug("Button events: " .. textutils.serialize(button.events))
        --self.application.log:debug("Name: " .. button.name)
    end
    return retval
end

CCKit.CCMain(5, 2, 16, 11, "Picture", MyViewController, colors.blue, "applicationtest")