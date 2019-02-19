--if not os.loadAPI("CCKit/CCKitAmalgamated.lua") then error("could not load CCKit") end
--CCKit = CCKitAmalgamated
if not os.loadAPI("CCKit/CCKitGlobals.lua") then error("could not load CCKitGlobals") end
if not loadAPI("CCOSKit") then error("could not load CCOSKit") end

function MyViewController()
    local retval = multipleInheritance(CCKit.CCViewController(), CCKit.CCEventHandler("MyViewController"))
    retval.toggleName = nil
    retval.sliderName = nil
    retval.button = CCKit.CCButton(4, 9, 8, 1)
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
        self.application.menuBarClient:updateServer()
        local newwin = CCKit.CCAlertWindow(20, 5, 20, 8, "Alert", "This is a long string of text to test if the text view works right.", self.application)
        self.window:present(newwin)
    end
    function retval:viewDidLoad()
        self.application.menuBarClient = CCOSKit.CCOSMenuBarClient(self.application)
        self.application.menuBarClient:addMenu("Menu")
        self.application.menuBarClient:addAction("Menu", "Open Alert", self.alert, self)
        local loader = CCKit.CCImageLoader()
        local res
        if _G._bundlePath ~= nil then res = loader:setHandle(CCOSKit.CCOSBundle.current():openResource("testimage.lon"))
        else res = loader:open("CCKit/testimage.lon") end
        if res == 1 then loader.type = CCImageType.ccg
        elseif res == -1 then self.application.log:error("Could not open image file") end
        local image = loader:read()
        if image.termWidth == 0 then self.application.log:error("Error reading file")
        return end
        loader:close()
        local imview = CCKit.CCImageView(1, 1, image)
        self.view:addSubview(imview)

        local label = CCKit.CCLabel(1, 0, "Image:")
        self.view:addSubview(label)

        local slider = CCKit.CCSlider(1, 6, 14)
        slider.maximumValue = 99
        self.sliderName = slider.name
        self.view:addSubview(slider)
        self.view:addSubview(self.counter)

        local checkbox = CCKit.CCCheckbox(1, 8, "Enabled")
        checkbox.isOn = true
        self.toggleName = checkbox.name
        self.view:addSubview(checkbox)

        self.button:setText("Alert")
        self.button:setAction(self.alert, self)
        self.view:addSubview(self.button)

        local group = CCKit.CCRadioGroup(12, 1, 10, 3)
        self.view:addSubview(group)
        local opt1 = CCKit.CCRadioButton(0, 0, "Option 1")
        local opt2 = CCKit.CCRadioButton(0, 1, "Option 2")
        local opt3 = CCKit.CCRadioButton(0, 2, "Option 3")
        group:addSubview(opt1)
        group:addSubview(opt2)
        group:addSubview(opt3)

        local scrollView = CCKit.CCScrollView(16, 5, 18, 5, 10)
        self.view:addSubview(scrollView)
        local longText = CCKit.CCTextView(0, 0, 17, 10)
        longText.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras vitae nisl a turpis tincidunt posuere."
        scrollView:addSubview(longText)

        local textBox = CCKit.CCTextField(24, 1, 10)
        textBox.placeholderText = "Text..."
        self.view:addSubview(textBox)

        if CCKernel ~= nil then
            local forkButton = CCKit.CCButton(24, 2, 10, 1)
            forkButton.text = "Start New"
            local target = "/CCKit/applicationtest.lua"
            if _G._bundlePath ~= nil then target = CCOSKit.CCOSBundle.current().path .. "/Executables/applicationtest.lua" end
            forkButton:setAction(CCKernel.exec, target)
            self.view:addSubview(forkButton)
        end

        self:addEvent("checkbox_toggled", self.toggle)
        self:addEvent("slider_dragged", self.dragged)
        self.window:registerObject(self)
    end
    return retval
end

CCKit.CCMain(5, 2, 35, 12, "CCKit Demo", MyViewController, colors.blue, "applicationtest")