-- Embedded FluentPro Library (Core Initialization and Elements)
-- Credit: Original author of FluentPro (StyearX)
local Fluent = {}
do
    local Root = Instance.new("ScreenGui")
    Root.Name = "FluentPro"
    Root.ResetOnSpawn = false
    Root.Parent = game.CoreGui

    function Fluent:Notify(data)
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Size = UDim2.new(0, 300, 0, 70)
        Notification.Position = UDim2.new(1, -310, 1, -80)
        Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Notification.BorderSizePixel = 0
        Notification.Parent = Root
        Notification.ClipsDescendants = true

        local Corner = Instance.new("UICorner", Notification)
        Corner.CornerRadius = UDim.new(0, 5)

        local Layout = Instance.new("UIListLayout", Notification)
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.Padding = UDim.new(0, 10)
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center

        local TypeIndicator = Instance.new("Frame", Notification)
        TypeIndicator.Size = UDim2.new(0, 5, 1, 0)
        TypeIndicator.BackgroundColor3 = data.Type == "Error" and Color3.fromRGB(255, 50, 50)
            or (data.Type == "Success" and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(100, 150, 255))
        TypeIndicator.BorderSizePixel = 0

        local ContentFrame = Instance.new("Frame", Notification)
        ContentFrame.Size = UDim2.new(1, -15, 1, 0)
        ContentFrame.BackgroundTransparency = 1

        local ContentLayout = Instance.new("UIListLayout", ContentFrame)
        ContentLayout.FillDirection = Enum.FillDirection.Vertical
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local TitleLabel = Instance.new("TextLabel", ContentFrame)
        TitleLabel.Size = UDim2.new(1, 0, 0, 20)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = data.Title or "Notification"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextScaled = true
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local ContentLabel = Instance.new("TextLabel", ContentFrame)
        ContentLabel.Size = UDim2.new(1, 0, 0, 15)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text = data.Content or ""
        ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ContentLabel.TextScaled = true
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left

        Notification.Position = UDim2.new(1, 0, 1, -80)
        game:GetService("TweenService"):Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, -310, 1, -80)
        }):Play()

        game:GetService("Debris"):AddItem(Notification, data.Duration or 3)
        task.wait(data.Duration or 3)
        game:GetService("TweenService"):Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 0, 1, -80)
        }):Play()
        task.wait(0.3)
        Notification:Destroy()
    end

    function Fluent:CreateWindow(config)
        local self = {}
        self.Config = config

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainWindow"
        MainFrame.Size = config.Size or UDim2.new(0, 600, 0, 400)
        MainFrame.Position = UDim2.new(0.5, -(config.Size and config.Size.X.Offset or 600) / 2, 0.5, -(config.Size and config.Size.Y.Offset or 400) / 2)
        MainFrame.BackgroundColor3 = config.CustomTheme and config.CustomTheme.Background or Color3.fromRGB(30, 30, 40)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Visible = true  -- ★ FIX: Explicitly set visible
        MainFrame.Parent = Root

        local Corner = Instance.new("UICorner", MainFrame)
        Corner.CornerRadius = UDim.new(0, 5)

        local TopBar = Instance.new("Frame", MainFrame)
        TopBar.Size = UDim2.new(1, 0, 0, 50)
        TopBar.BackgroundColor3 = config.CustomTheme and config.CustomTheme.Panel or Color3.fromRGB(20, 20, 30)
        TopBar.BorderSizePixel = 0

        local TopBarCorner = Instance.new("UICorner", TopBar)
        TopBarCorner.CornerRadius = UDim.new(0, 5)

        local TitleLabel = Instance.new("TextLabel", TopBar)
        TitleLabel.Size = UDim2.new(1, -120, 0.5, 0)
        TitleLabel.Position = UDim2.new(0, 10, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = config.Title or "Window"
        TitleLabel.TextColor3 = config.CustomTheme and config.CustomTheme.Text or Color3.fromRGB(255, 255, 255)
        TitleLabel.TextScaled = true
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local SubtitleLabel = Instance.new("TextLabel", TopBar)
        SubtitleLabel.Size = UDim2.new(1, -120, 0.5, 0)
        SubtitleLabel.Position = UDim2.new(0, 10, 0.5, 0)
        SubtitleLabel.BackgroundTransparency = 1
        SubtitleLabel.Text = config.SubTitle or "Subtitle"
        SubtitleLabel.TextColor3 = config.CustomTheme and config.CustomTheme.Muted or Color3.fromRGB(170, 170, 170)
        SubtitleLabel.TextScaled = true
        SubtitleLabel.Font = Enum.Font.Gotham
        SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local TabContainer = Instance.new("Frame", MainFrame)
        TabContainer.Size = UDim2.new(0, config.TabWidth or 120, 1, -50)
        TabContainer.Position = UDim2.new(0, 0, 0, 50)
        TabContainer.BackgroundColor3 = config.CustomTheme and config.CustomTheme.Panel or Color3.fromRGB(25, 25, 35)
        TabContainer.BorderSizePixel = 0

        local TabContainerCorner = Instance.new("UICorner", TabContainer)
        TabContainerCorner.CornerRadius = UDim.new(0, 5)

        local ContentContainer = Instance.new("Frame", MainFrame)
        ContentContainer.Size = UDim2.new(1, -(config.TabWidth or 120), 1, -50)
        ContentContainer.Position = UDim2.new(0, config.TabWidth or 120, 0, 50)
        ContentContainer.BackgroundColor3 = config.CustomTheme and config.CustomTheme.Panel or Color3.fromRGB(25, 25, 35)
        ContentContainer.BorderSizePixel = 0

        local ContentContainerCorner = Instance.new("UICorner", ContentContainer)
        ContentContainerCorner.CornerRadius = UDim.new(0, 5)

        local PageContainer = Instance.new("Frame", ContentContainer)
        PageContainer.Size = UDim2.new(1, 0, 1, 0)
        PageContainer.BackgroundTransparency = 1
        PageContainer.ClipsDescendants = true

        local Tabs = {}
        local CurrentPage = nil

        function self:CreateTab(name, icon)
            local TabButton = Instance.new("TextButton")
            TabButton.Size = UDim2.new(1, -10, 0, 40)
            TabButton.Position = UDim2.new(0, 5, 0, 5 + (#Tabs * 45))
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TabButton.BorderSizePixel = 0
            TabButton.Text = name
            TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            TabButton.TextScaled = true
            TabButton.Font = Enum.Font.Gotham
            TabButton.Parent = TabContainer

            local ButtonCorner = Instance.new("UICorner", TabButton)
            ButtonCorner.CornerRadius = UDim.new(0, 5)

            local PageFrame = Instance.new("ScrollingFrame")
            PageFrame.Size = UDim2.new(1, 0, 1, 0)
            PageFrame.BackgroundTransparency = 1
            PageFrame.BorderSizePixel = 0
            PageFrame.ScrollBarThickness = 5
            PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            PageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            PageFrame.Visible = false
            PageFrame.Parent = PageContainer

            local PageLayout = Instance.new("UIListLayout", PageFrame)
            PageLayout.FillDirection = Enum.FillDirection.Vertical
            PageLayout.Padding = UDim.new(0, 10)
            PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local TabData = {
                Name = name,
                Button = TabButton,
                Page = PageFrame,
                Sections = {}
            }

            TabButton.MouseButton1Click:Connect(function()
                if CurrentPage then
                    CurrentPage.Visible = false
                end
                PageFrame.Visible = true
                CurrentPage = PageFrame
                -- Highlight active tab
                for _, t in ipairs(Tabs) do
                    t.Button.BackgroundColor3 = (t == TabData) and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 40)
                end
            end)

            table.insert(Tabs, TabData)

            if #Tabs == 1 then
                PageFrame.Visible = true
                CurrentPage = PageFrame
                TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            end

            function TabData:CreatePage(pageName, pageIcon)
                return TabData
            end

            function TabData:AddSection(sectionName, sectionIcon)
                local SectionFrame = Instance.new("Frame", PageFrame)
                SectionFrame.Size = UDim2.new(1, -20, 0, 40)
                SectionFrame.BackgroundTransparency = 1
                SectionFrame.AutomaticSize = Enum.AutomaticSize.Y

                local SectionLayout = Instance.new("UIListLayout", SectionFrame)
                SectionLayout.FillDirection = Enum.FillDirection.Vertical
                SectionLayout.Padding = UDim.new(0, 5)
                SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local Header = Instance.new("TextLabel", SectionFrame)
                Header.Size = UDim2.new(1, 0, 0, 30)
                Header.BackgroundTransparency = 1
                Header.Text = sectionName
                Header.TextColor3 = config.CustomTheme and config.CustomTheme.Accent or Color3.fromRGB(100, 150, 255)
                Header.TextScaled = true
                Header.Font = Enum.Font.GothamBold
                Header.TextXAlignment = Enum.TextXAlignment.Left

                local ContentFrame = Instance.new("Frame", SectionFrame)
                ContentFrame.Size = UDim2.new(1, 0, 0, 10)
                ContentFrame.BackgroundTransparency = 1
                ContentFrame.AutomaticSize = Enum.AutomaticSize.Y

                local ContentLayout = Instance.new("UIListLayout", ContentFrame)
                ContentLayout.FillDirection = Enum.FillDirection.Vertical
                ContentLayout.Padding = UDim.new(0, 5)
                ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

                local SectionData = {
                    Name = sectionName,
                    Frame = SectionFrame,
                    ContentFrame = ContentFrame,

                    AddToggle = function(_, data)
                        local ToggleFrame = Instance.new("Frame", ContentFrame)
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                        ToggleFrame.BackgroundTransparency = 1

                        local ToggleLayout = Instance.new("UIListLayout", ToggleFrame)
                        ToggleLayout.FillDirection = Enum.FillDirection.Horizontal
                        ToggleLayout.Padding = UDim.new(0, 5)
                        ToggleLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                        local ToggleLabel = Instance.new("TextLabel", ToggleFrame)
                        ToggleLabel.Size = UDim2.new(1, -30, 1, 0)
                        ToggleLabel.BackgroundTransparency = 1
                        ToggleLabel.Text = data.Title
                        ToggleLabel.TextColor3 = config.CustomTheme and config.CustomTheme.Text or Color3.fromRGB(255, 255, 255)
                        ToggleLabel.TextScaled = true
                        ToggleLabel.Font = Enum.Font.Gotham
                        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

                        local ToggleButton = Instance.new("TextButton", ToggleFrame)
                        ToggleButton.Size = UDim2.new(0, 26, 0, 26)
                        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        ToggleButton.BorderSizePixel = 0
                        ToggleButton.Text = ""

                        local BtnCorner = Instance.new("UICorner", ToggleButton)
                        BtnCorner.CornerRadius = UDim.new(1, 0)

                        local Indicator = Instance.new("Frame", ToggleButton)
                        Indicator.Size = UDim2.new(0, 22, 0, 22)
                        Indicator.Position = UDim2.new(0, 2, 0, 2)
                        Indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
                        Indicator.BorderSizePixel = 0

                        local IndCorner = Instance.new("UICorner", Indicator)
                        IndCorner.CornerRadius = UDim.new(1, 0)

                        local State = data.Default or false

                        local function updateVisual()
                            if State then
                                Indicator.Position = UDim2.new(1, -24, 0, 2)
                                Indicator.BackgroundColor3 = config.CustomTheme and config.CustomTheme.Accent or Color3.fromRGB(100, 150, 255)
                            else
                                Indicator.Position = UDim2.new(0, 2, 0, 2)
                                Indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
                            end
                        end
                        updateVisual()

                        ToggleButton.MouseButton1Click:Connect(function()
                            State = not State
                            updateVisual()
                            if data.Callback then data.Callback(State) end
                        end)
                    end,

                    AddDropdown = function(_, data)
                        local DropdownFrame = Instance.new("Frame", ContentFrame)
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
                        DropdownFrame.BackgroundTransparency = 1
                        DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
                        DropdownFrame.ZIndex = 10

                        local DropdownLabel = Instance.new("TextLabel", DropdownFrame)
                        DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
                        DropdownLabel.BackgroundTransparency = 1
                        DropdownLabel.Text = data.Title
                        DropdownLabel.TextColor3 = config.CustomTheme and config.CustomTheme.Text or Color3.fromRGB(255, 255, 255)
                        DropdownLabel.TextScaled = true
                        DropdownLabel.Font = Enum.Font.Gotham
                        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

                        local DropdownButton = Instance.new("TextButton", DropdownFrame)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 30)
                        DropdownButton.Position = UDim2.new(0, 0, 0, 25)
                        DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        DropdownButton.BorderSizePixel = 0
                        DropdownButton.Text = "Select..."
                        DropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        DropdownButton.TextScaled = true
                        DropdownButton.Font = Enum.Font.Gotham
                        DropdownButton.ZIndex = 11

                        local BtnCorner = Instance.new("UICorner", DropdownButton)
                        BtnCorner.CornerRadius = UDim.new(0, 5)

                        local OptionList = Instance.new("ScrollingFrame", DropdownFrame)
                        OptionList.Size = UDim2.new(1, 0, 0, 100)
                        OptionList.Position = UDim2.new(0, 0, 0, 57)
                        OptionList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                        OptionList.BorderSizePixel = 0
                        OptionList.ScrollBarThickness = 5
                        OptionList.Visible = false
                        OptionList.ZIndex = 12

                        local OptLayout = Instance.new("UIListLayout", OptionList)
                        OptLayout.FillDirection = Enum.FillDirection.Vertical
                        OptLayout.Padding = UDim.new(0, 2)
                        OptLayout.SortOrder = Enum.SortOrder.LayoutOrder

                        local ListCorner = Instance.new("UICorner", OptionList)
                        ListCorner.CornerRadius = UDim.new(0, 5)

                        local SelectedOptions = {}

                        local function updateButtonText()
                            if data.MultiSelection then
                                local txt = table.concat(SelectedOptions, ", ")
                                DropdownButton.Text = (txt == "" and "None" or txt)
                            else
                                DropdownButton.Text = SelectedOptions[1] or "None"
                            end
                        end

                        for _, option in ipairs(data.Options) do
                            local OptionButton = Instance.new("TextButton", OptionList)
                            OptionButton.Size = UDim2.new(1, 0, 0, 25)
                            OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                            OptionButton.BorderSizePixel = 0
                            OptionButton.Text = option
                            OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                            OptionButton.TextScaled = true
                            OptionButton.Font = Enum.Font.Gotham
                            OptionButton.ZIndex = 13

                            local OptCorner = Instance.new("UICorner", OptionButton)
                            OptCorner.CornerRadius = UDim.new(0, 3)

                            OptionButton.MouseButton1Click:Connect(function()
                                if data.MultiSelection then
                                    local index = table.find(SelectedOptions, option)
                                    if index then
                                        table.remove(SelectedOptions, index)
                                    else
                                        table.insert(SelectedOptions, option)
                                    end
                                else
                                    SelectedOptions = {option}
                                    OptionList.Visible = false
                                end
                                updateButtonText()
                                if data.Callback then data.Callback(SelectedOptions) end
                            end)
                        end

                        DropdownButton.MouseButton1Click:Connect(function()
                            OptionList.Visible = not OptionList.Visible
                        end)

                        updateButtonText()
                    end,

                    AddSlider = function(_, data)
                        local SliderFrame = Instance.new("Frame", ContentFrame)
                        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                        SliderFrame.BackgroundTransparency = 1

                        local SliderLabel = Instance.new("TextLabel", SliderFrame)
                        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                        SliderLabel.BackgroundTransparency = 1
                        SliderLabel.Text = data.Title .. ": " .. tostring(data.Default)
                        SliderLabel.TextColor3 = config.CustomTheme and config.CustomTheme.Text or Color3.fromRGB(255, 255, 255)
                        SliderLabel.TextScaled = true
                        SliderLabel.Font = Enum.Font.Gotham
                        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

                        local SliderBarBG = Instance.new("Frame", SliderFrame)
                        SliderBarBG.Size = UDim2.new(1, 0, 0, 10)
                        SliderBarBG.Position = UDim2.new(0, 0, 0, 30)
                        SliderBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        SliderBarBG.BorderSizePixel = 0

                        local BarCorner = Instance.new("UICorner", SliderBarBG)
                        BarCorner.CornerRadius = UDim.new(1, 0)

                        local initFrac = (data.Default - data.Min) / (data.Max - data.Min)
                        local SliderBar = Instance.new("Frame", SliderBarBG)
                        SliderBar.Size = UDim2.new(initFrac, 0, 1, 0)
                        SliderBar.BackgroundColor3 = config.CustomTheme and config.CustomTheme.Accent or Color3.fromRGB(100, 150, 255)
                        SliderBar.BorderSizePixel = 0

                        local Handle = Instance.new("TextButton", SliderBar)
                        Handle.Size = UDim2.new(0, 16, 0, 16)
                        Handle.Position = UDim2.new(1, -8, 0.5, -8)
                        Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Handle.BorderSizePixel = 0
                        Handle.Text = ""

                        local HandleCorner = Instance.new("UICorner", Handle)
                        HandleCorner.CornerRadius = UDim.new(1, 0)

                        local Value = data.Default
                        local Dragging = false

                        local function UpdateSlider(mouseX)
                            local barAbsX = SliderBarBG.AbsolutePosition.X
                            local barAbsWidth = SliderBarBG.AbsoluteSize.X
                            if barAbsWidth == 0 then return end
                            local relativeX = math.clamp((mouseX - barAbsX) / barAbsWidth, 0, 1)
                            Value = data.Min + (data.Max - data.Min) * relativeX
                            Value = math.round(Value / data.Rounding) * data.Rounding
                            local frac = (Value - data.Min) / (data.Max - data.Min)
                            SliderBar.Size = UDim2.new(frac, 0, 1, 0)
                            SliderLabel.Text = data.Title .. ": " .. tostring(Value)
                            if data.Callback then data.Callback(Value) end
                        end

                        Handle.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                Dragging = true
                            end
                        end)
                        SliderBarBG.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                Dragging = true
                                UpdateSlider(input.Position.X)
                            end
                        end)
                        game:GetService("UserInputService").InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
                                UpdateSlider(input.Position.X)
                            end
                        end)
                        game:GetService("UserInputService").InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
                                Dragging = false
                            end
                        end)
                    end,

                    AddButton = function(_, data)
                        local ButtonFrame = Instance.new("Frame", ContentFrame)
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
                        ButtonFrame.BackgroundTransparency = 1

                        local Button = Instance.new("TextButton", ButtonFrame)
                        Button.Size = UDim2.new(1, 0, 1, 0)
                        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                        Button.BorderSizePixel = 0
                        Button.Text = data.Title
                        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Button.TextScaled = true
                        Button.Font = Enum.Font.Gotham

                        local BtnCorner = Instance.new("UICorner", Button)
                        BtnCorner.CornerRadius = UDim.new(0, 5)

                        Button.MouseButton1Click:Connect(function()
                            if data.Callback then data.Callback() end
                        end)
                    end,

                    AddTextbox = function(_, data)
                        local TextboxFrame = Instance.new("Frame", ContentFrame)
                        TextboxFrame.Size = UDim2.new(1, 0, 0, 55)
                        TextboxFrame.BackgroundTransparency = 1

                        local TextboxLabel = Instance.new("TextLabel", TextboxFrame)
                        TextboxLabel.Size = UDim2.new(1, 0, 0, 20)
                        TextboxLabel.BackgroundTransparency = 1
                        TextboxLabel.Text = data.Title
                        TextboxLabel.TextColor3 = config.CustomTheme and config.CustomTheme.Text or Color3.fromRGB(255, 255, 255)
                        TextboxLabel.TextScaled = true
                        TextboxLabel.Font = Enum.Font.Gotham
                        TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left

                        local Textbox = Instance.new("TextBox", TextboxFrame)
                        Textbox.Size = UDim2.new(1, 0, 0, 30)
                        Textbox.Position = UDim2.new(0, 0, 0, 25)
                        Textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        Textbox.BorderSizePixel = 0
                        Textbox.PlaceholderText = data.Placeholder or ""
                        Textbox.Text = ""
                        Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Textbox.TextScaled = true
                        Textbox.Font = Enum.Font.Gotham

                        local BoxCorner = Instance.new("UICorner", Textbox)
                        BoxCorner.CornerRadius = UDim.new(0, 5)

                        Textbox.FocusLost:Connect(function(enterPressed)
                            if enterPressed then
                                if data.Callback then data.Callback(Textbox.Text) end
                            end
                        end)
                    end,

                    AddLabel = function(_, text)
                        local LabelFrame = Instance.new("Frame", ContentFrame)
                        LabelFrame.Size = UDim2.new(1, 0, 0, 20)
                        LabelFrame.BackgroundTransparency = 1

                        local Label = Instance.new("TextLabel", LabelFrame)
                        Label.Size = UDim2.new(1, 0, 1, 0)
                        Label.BackgroundTransparency = 1
                        Label.Text = text
                        Label.TextColor3 = config.CustomTheme and config.CustomTheme.Text or Color3.fromRGB(200, 200, 200)
                        Label.TextScaled = true
                        Label.Font = Enum.Font.Gotham
                        Label.TextXAlignment = Enum.TextXAlignment.Left
                        Label.TextYAlignment = Enum.TextYAlignment.Top
                    end,

                    AddDivider = function(_)
                        local DividerFrame = Instance.new("Frame", ContentFrame)
                        DividerFrame.Size = UDim2.new(1, 0, 0, 5)
                        DividerFrame.BackgroundTransparency = 1

                        local Divider = Instance.new("Frame", DividerFrame)
                        Divider.Size = UDim2.new(1, 0, 0, 1)
                        Divider.Position = UDim2.new(0, 0, 0.5, 0)
                        Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        Divider.BorderSizePixel = 0
                    end
                }
                table.insert(TabData.Sections, SectionData)
                return SectionData
            end

            return TabData
        end

        return self
    end
end

-- ============================================
-- SERVICES & CORE VARIABLES  (★ FIX: removed trailing spaces)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ============================================
-- THEME & DESIGN SYSTEM  (★ FIX: Col or3 → Color3)
-- ============================================
local THEME = {
    Base      = Color3.fromRGB(15, 15, 18),
    Element   = Color3.fromRGB(22, 22, 26),
    Hover     = Color3.fromRGB(28, 28, 34),
    Accent    = Color3.fromRGB(190, 140, 255),
    AccentDark= Color3.fromRGB(140, 90, 200),
    Border    = Color3.fromRGB(35, 35, 42),
    Text      = Color3.fromRGB(240, 240, 245),
    SubText   = Color3.fromRGB(160, 160, 175),
    Danger    = Color3.fromRGB(220, 50, 50),
    Success   = Color3.fromRGB(50, 200, 100),
    Warning   = Color3.fromRGB(230, 180, 40)
}

-- ============================================
-- CONFIGURATION & CREDENTIALS  (★ FIX: removed trailing spaces)
-- ============================================
local HUB_KEY   = "EXOSTAKEOVERR19$"
local KEY_FILE  = "exo_key_v3.dat"
local BAN_FILE  = "exo_bans_v3.dat"
local MAINT_FILE= "exo_maint_v3.dat"
local OWNER_CREDS   = {username = "exo_blox", password = "03239461"}
local OPERATOR_CREDS= {username = "OP",       password = "0000"}
local currentUserRole = nil

-- ============================================
-- FILE I/O & STATE MANAGEMENT
-- ============================================
local function readFile(path)
    if isfile and readfile and isfile(path) then
        local success, result = pcall(readfile, path)
        if success then return result end
    end
    return nil
end

local function writeFile(path, data)
    if writefile then pcall(writefile, path, data) end
end

local function readJSON(path)
    local raw = readFile(path)
    if raw then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if success then return decoded end
    end
    return nil
end

local function writeJSON(path, data)
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if success then writeFile(path, encoded) end
end

local function getDeviceID()
    if gethwid then return gethwid() end
    return tostring(player.UserId) .. "_HWID_FALLBACK"
end

-- ============================================
-- PREMIUM KEY SYSTEM UI
-- ============================================
local function createKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZyronXKeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 480, 0, 340)
    card.Position = UDim2.new(0.5, -240, 0.5, -170)
    card.BackgroundColor3 = THEME.Base
    card.BorderSizePixel = 0
    card.Parent = gui

    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.Border
    stroke.Thickness = 1.5

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundColor3 = THEME.Element
    topbar.BorderSizePixel = 0
    topbar.Parent = card
    local topbarCorner = Instance.new("UICorner", topbar)
    topbarCorner.CornerRadius = UDim.new(0, 12)
    local topbarFix = Instance.new("Frame")
    topbarFix.Size = UDim2.new(1, 0, 0, 15)
    topbarFix.Position = UDim2.new(0, 0, 1, -15)
    topbarFix.BackgroundColor3 = THEME.Element
    topbarFix.BorderSizePixel = 0
    topbarFix.Parent = topbar

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, -20, 1, 0)
    logo.Position = UDim2.new(0, 20, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "ZyronX  |  Key Authentication"
    logo.TextColor3 = THEME.Text
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 14
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = topbar

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.BackgroundColor3 = THEME.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Parent = topbar

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 40)
    desc.Position = UDim2.new(0, 20, 0, 65)
    desc.BackgroundTransparency = 1
    desc.Text = "Enter your premium key to access the Power Tycoon Hub."
    desc.TextColor3 = THEME.SubText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = card

    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -40, 0, 48)
    inputBg.Position = UDim2.new(0, 20, 0, 125)
    inputBg.BackgroundColor3 = THEME.Element
    inputBg.BorderSizePixel = 0
    inputBg.Parent = card
    local inputCorner = Instance.new("UICorner", inputBg)
    inputCorner.CornerRadius = UDim.new(0, 8)
    local inputStroke = Instance.new("UIStroke", inputBg)
    inputStroke.Color = THEME.Border

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Paste your premium key here..."
    input.PlaceholderColor3 = THEME.SubText
    input.Text = ""
    input.TextColor3 = THEME.Text
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = inputBg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 48)
    btn.Position = UDim2.new(0, 20, 0, 195)
    btn.BackgroundColor3 = THEME.Accent
    btn.Text = "AUTHENTICATE & UNLOCK"
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = card
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 255)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = THEME.Danger
    status.Font = Enum.Font.GothamBold
    status.TextSize = 12
    status.Parent = card

    btn.MouseButton1Click:Connect(function()
        if input.Text == HUB_KEY then
            writeJSON(KEY_FILE, {key = HUB_KEY, time = os.time()})
            status.Text = "Authentication Successful. Loading Hub..."
            status.TextColor3 = THEME.Success
            btn.BackgroundColor3 = THEME.Success
            task.wait(1.2)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            status.Text = "Invalid Key. Please check your key and try again."
            input.Text = ""
        end
    end)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            btn.MouseButton1Click:Fire()
        end
    end)
end

-- ============================================
-- BAN & MAINTENANCE SCREENS
-- ============================================
local function checkBan()
    local data = readJSON(BAN_FILE) or {users = {}, devices = {}}
    local uid = tostring(player.UserId)
    local hwid = getDeviceID()
    for _, b in ipairs(data.users) do
        if b.id == uid then return true, b.reason end
    end
    for _, b in ipairs(data.devices) do
        if b.id == hwid then return true, b.reason end
    end
    return false, nil
end

local function createBanScreen(reason)
    local gui = Instance.new("ScreenGui")
    gui.Name = "BanScreen"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 5, 5)
    bg.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 500, 0, 280)
    card.Position = UDim2.new(0.5, -250, 0.5, -140)
    card.BackgroundColor3 = THEME.Base
    card.Parent = gui
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.Danger
    stroke.Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "ACCESS DENIED"
    title.TextColor3 = THEME.Danger
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28
    title.Parent = card

    local reasonLabel = Instance.new("TextLabel")
    reasonLabel.Size = UDim2.new(1, -40, 0, 60)
    reasonLabel.Position = UDim2.new(0, 20, 0, 120)
    reasonLabel.BackgroundTransparency = 1
    reasonLabel.Text = "Reason: " .. (reason or "Unknown")
    reasonLabel.TextColor3 = THEME.Text
    reasonLabel.Font = Enum.Font.GothamBold
    reasonLabel.TextSize = 16
    reasonLabel.TextWrapped = true
    reasonLabel.Parent = card

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 40)
    sub.Position = UDim2.new(0, 20, 0, 190)
    sub.BackgroundTransparency = 1
    sub.Text = "You have been permanently banned from using this hub."
    sub.TextColor3 = THEME.SubText
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.TextWrapped = true
    sub.Parent = card
end

local function createMaintScreen()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MaintScreen"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = THEME.Base
    bg.Parent = gui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 500, 0, 220)
    card.Position = UDim2.new(0.5, -250, 0.5, -110)
    card.BackgroundColor3 = THEME.Element
    card.Parent = gui
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.Warning

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "HUB DOWN FOR MAINTENANCE"
    title.TextColor3 = THEME.Warning
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = card

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 40)
    sub.Position = UDim2.new(0, 20, 0, 110)
    sub.BackgroundTransparency = 1
    sub.Text = "PLEASE WAIT A FEW MINUTES AND THEN REJOIN"
    sub.TextColor3 = THEME.SubText
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 14
    sub.TextWrapped = true
    sub.Parent = card
end

-- ============================================
-- HELPER: GET SERVER PLAYERS
-- ============================================
local function getServerPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(list, p.Name) end
    end
    return #list > 0 and list or {"No Players Available"}
end

-- ============================================
-- GAME LOGIC: STATE VARIABLES
-- ============================================
local DAMAGE_REMOTE = nil
local Aura = { Enabled = false, TargetList = {} }
local InstantKill = false
local AutoTools = false
local NoCooldown = false
local Reach = false
local ReachSize = 2
local FastRespawn = false
local AntiSpawnkill = false
local ToolFollow = { Enabled = false, Targets = {}, Connection = nil }
local AutoGetTools = false
local grabLoopConn = nil
local toolLoopConn = nil
local auraConn = nil
local AutoClaimMoney = false
local AutoBuild = false
local claimConn = nil
local buildConn = nil
local cachedTycoonType = nil
local AntiAura = { Enabled = false, GodMode = false, Dodge = false, Repel = false }
local antiAuraConn = nil

-- ============================================
-- GAME LOGIC: DAMAGE REMOTE DETECTION
-- ============================================
local function findDamageRemotes()
    local remotes = {}
    for _, container in ipairs({ReplicatedStorage, workspace}) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:match("damage") or n:match("hit") or n:match("attack") or n:match("deal") then
                    table.insert(remotes, obj)
                end
            end
        end
    end
    return remotes
end

local dmgRemotes = findDamageRemotes()
if #dmgRemotes > 0 then
    DAMAGE_REMOTE = dmgRemotes[1]
    print("Damage remote auto-detected:", DAMAGE_REMOTE:GetFullName())
else
    warn("No damage remote found – use Game Dumper to find it.")
end

-- ============================================
-- GAME LOGIC: TYCOON DETECTION & HELPERS  (★ FIX: all trailing spaces removed)
-- ============================================
local function getPlayerTycoonType()
    if cachedTycoonType and workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(cachedTycoonType) then
        return cachedTycoonType
    end
    local plot = workspace:FindFirstChild(player.Name)
    if plot then
        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("StringValue") then
                local n = child.Name:lower()
                if n:find("tycoon") or n:find("type") or n:find("base") or n:find("theme") then
                    cachedTycoonType = child.Value
                    return cachedTycoonType
                end
            end
        end
        for attrName, attrVal in pairs(plot:GetAttributes()) do
            local n = attrName:lower()
            if n:find("tycoon") or n:find("type") or n:find("base") or n:find("theme") then
                if type(attrVal) == "string" then
                    cachedTycoonType = attrVal
                    return cachedTycoonType
                end
            end
        end
    end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local closestTycoon = nil
        local minDist = math.huge
        local tycoonsFolder = workspace:FindFirstChild("Tycoons")
        if tycoonsFolder then
            for _, tycoonFolder in ipairs(tycoonsFolder:GetChildren()) do
                if tycoonFolder:IsA("Folder") then
                    local door = tycoonFolder:FindFirstChild("Door", true)
                    if door then
                        local doorPart = door:FindFirstChildWhichIsA("BasePart")
                        if doorPart then
                            local dist = (doorPart.Position - root.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestTycoon = tycoonFolder.Name
                            end
                        end
                    end
                end
            end
        end
        cachedTycoonType = closestTycoon
        return closestTycoon
    end
    return nil
end

player.CharacterAdded:Connect(function()
    cachedTycoonType = nil
end)

local function getTouchableParts(model)
    local parts = {}
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(parts, desc.Parent)
        end
    end
    if #parts == 0 then
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then
                table.insert(parts, desc)
                break
            end
        end
    end
    return parts
end

local function getPlayerCash()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local cash = ls:FindFirstChild("Cash") or ls:FindFirstChild("Money") or ls:FindFirstChild("Coins") or ls:FindFirstChild("Gold")
        if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then
            return cash.Value
        end
        for _, stat in ipairs(ls:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                return stat.Value
            end
        end
    end
    return 0
end

local function getCost(obj)
    local priceVal = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if priceVal and (priceVal:IsA("IntValue") or priceVal:IsA("NumberValue")) then
        return priceVal.Value
    end
    local attr = obj:GetAttribute("Price") or obj:GetAttribute("Cost")
    if type(attr) == "number" then return attr end
    for _, child in ipairs(obj:GetDescendants()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) then
            local n = child.Name:lower()
            if n:find("price") or n:find("cost") then
                return child.Value
            end
        end
    end
    return 0
end

-- ============================================
-- SMART AUTO BUILD: TIERED PRIORITY
-- ============================================
local function getPriority(modelName)
    local name = modelName:lower()
    if name:find("robux") then return 999 end
    local num = tonumber(name:match("%d+")) or 0
    if name:find("gen") and not name:find("gear") then
        if num == 0 then return 10 end
        if num == 1 then return 11 end
        if num == 2 then return 30 end
        if num == 3 then return 31 end
        if num == 4 then return 50 end
        if num == 5 then return 60 end
        if num >= 6 then return 70 + num end
    end
    if name:find("gear") or name:find("gun") then
        if num <= 1 then return 20 end
        if num == 2 then return 21 end
        if num == 3 then return 55 end
        if num == 4 then return 65 end
        if num == 5 then return 66 end
        if num >= 6 then return 67 + num end
    end
    if name:find("wall") or name:find("door") or name:find("ladder") or name:find("upstairs") then
        return 40 + num
    end
    if name:find("ultima") or name:find("effect") then return 80 end
    return 90 + num
end

-- ============================================
-- AUTO GET TOOLS SETUP
-- ============================================
local toolToBase = {["Energy Sword"] = "Stone", ["Staff"] = "Magic", ["Axe"] = "Storm", ["Fist"] = "Robotic"}
local allowedBases = {Stone=true, Magic=true, Storm=true, Robotic=true}
local excludedBases = {Insanity=true, Giant=true, Dark=true, Spike=true, Web=true, Strong=true}
local padsByBase = {}

local function registerPad(pad)
    local base = pad.Parent and pad.Parent.Parent
    if not base or excludedBases[base.Name] or not allowedBases[base.Name] then return end
    padsByBase[base.Name] = padsByBase[base.Name] or {}
    table.insert(padsByBase[base.Name], pad)
end

local Tycoons = workspace:FindFirstChild("Tycoons")
if Tycoons then
    for _, d in ipairs(Tycoons:GetDescendants()) do
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end
    Tycoons.DescendantAdded:Connect(function(d)
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent and d.Parent.Parent.Name:find("GearGiver1") then
            registerPad(d.Parent)
        end
    end)
end

-- ============================================
-- THREAT LEVEL DETECTION
-- ============================================
local ThreatLevel = 0
local LastThreatCheck = 0
local ThreatRadius = 50

function updateThreatLevel()
    if tick() - LastThreatCheck < 0.5 then return end
    LastThreatCheck = tick()
    ThreatLevel = 0
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < ThreatRadius then
                ThreatLevel = ThreatLevel + 1
            end
        end
    end
end

-- ============================================
-- AURA & INSTANT KILL
-- ============================================
local latencyEstimate = 0.1

function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not Aura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                local damagePart
                for _, obj in ipairs(tool:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then damagePart = obj.Parent; break end
                end
                if not damagePart then damagePart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") end
                if not damagePart then continue end
                local origCF = damagePart.CFrame
                for _, targetPlr in ipairs(Aura.TargetList) do
                    local tChar = targetPlr.Character
                    if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                        local root = tChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            local velocity = root.Velocity
                            local predictedPos = root.Position + velocity * latencyEstimate
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {myChar, tChar}
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            local rayResult = workspace:Raycast(damagePart.Position, (predictedPos - damagePart.Position).Unit * 50, rayParams)
                            if rayResult and rayResult.Instance and rayResult.Instance.Parent == root.Parent then
                                pcall(function() damagePart.CFrame = CFrame.new(rayResult.Position) * CFrame.new(0,2,0) end)
                            else
                                pcall(function() damagePart.CFrame = CFrame.new(predictedPos) * CFrame.new(0,2,0) end)
                            end
                            if DAMAGE_REMOTE then
                                pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end)
                            else
                                for _, p in ipairs(tChar:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        pcall(firetouchinterest, damagePart, p, 0)
                                        pcall(firetouchinterest, damagePart, p, 1)
                                    end
                                end
                            end
                            pcall(function() damagePart.CFrame = origCF end)
                        end
                    end
                end
            end
        end
        if InstantKill then
            for _, plr in ipairs(Aura.TargetList) do
                local tChar = plr.Character
                if tChar then
                    local hum = tChar:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        pcall(function() hum:TakeDamage(9e9) end)
                        pcall(function() hum.Health = 0 end)
                    end
                end
            end
        end
    end)
end

function stopAuraLoop()
    if auraConn then auraConn:Disconnect(); auraConn = nil end
end

-- ============================================
-- TOOL FOLLOW
-- ============================================
local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    if tool.PrimaryPart and tool.PrimaryPart:IsA("BasePart") then return tool.PrimaryPart end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local cachedToolParts = {}
local cachedTorso = {}

local function updateToolCache()
    table.clear(cachedToolParts)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then table.insert(cachedToolParts, part) end
        end
    end
end

local function getCachedTorso(char)
    if cachedTorso[char] and cachedTorso[char].Parent then return cachedTorso[char] end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    cachedTorso[char] = torso
    return torso
end

function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
    ToolFollow.Connection = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not ToolFollow.Enabled then return end
        if #ToolFollow.Targets == 0 then return end
        local myChar = player.Character
        if not myChar then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = getCachedTorso(tChar)
                if torso then
                    for _, part in ipairs(cachedToolParts) do
                        if part and part.Parent then
                            part.Position = torso.Position + Vector3.new(0, 0.6, 0.5)
                            part.CanCollide = false
                            part.Massless = true
                        end
                    end
                end
            end
        end
    end)
end

function stopToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    updateToolCache()
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait()
            updateToolCache()
            local part = getToolPart(child)
            if part then
                part.CanCollide = false
                part.Massless = true
            end
        end
    end)
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then
                part.CanCollide = false
                part.Massless = true
            end
        end
    end
end)
updateToolCache()
if player.Character then
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then part.CanCollide = false; part.Massless = true end
        end
    end
end

-- ============================================
-- AUTO CLAIM & SMART BUILD
-- ============================================
function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not AutoClaimMoney then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        local cashRegister = tycoonFolder:FindFirstChild("CashRegister", true)
        if cashRegister then
            local touchParts = getTouchableParts(cashRegister)
            for _, part in ipairs(touchParts) do
                pcall(firetouchinterest, root, part, 0)
                pcall(firetouchinterest, root, part, 1)
            end
        end
    end)
end

function stopClaimMoney()
    if claimConn then claimConn:Disconnect(); claimConn = nil end
end

local lastBuyTime = 0
local lastCashCheck = 0
local cashPerSecond = 0
local previousCash = 0

function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    buildConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not AutoBuild then return end
        if tick() - lastBuyTime < 0.5 then return end
        local currentTime = tick()
        if currentTime - lastCashCheck > 1 then
            local currentCash = getPlayerCash()
            cashPerSecond = (currentCash - previousCash) / (currentTime - lastCashCheck)
            previousCash = currentCash
            lastCashCheck = currentTime
        end
        local buyDelay = cashPerSecond < 100 and 0.2 or 0.05
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        local cash = getPlayerCash()
        local buttons = {}
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("button") or obj.Name:lower():find("btn") or obj.Name:lower():find("gen") or obj.Name:lower():find("wall") or obj.Name:lower():find("door") or obj.Name:lower():find("ladder") or obj.Name:lower():find("upstairs") or obj.Name:lower():find("gear") or obj.Name:lower():find("ultima")) then
                local cost = getCost(obj)
                if cost > 0 then
                    table.insert(buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                end
            end
        end
        table.sort(buttons, function(a, b)
            if a.Priority == b.Priority then return a.Cost < b.Cost end
            return a.Priority < b.Priority
        end)
        if ThreatLevel > 0 then
            for _, btnData in ipairs(buttons) do
                local mName = btnData.Model.Name:lower()
                if (mName:find("wall") or mName:find("door") or mName:find("ladder")) and cash >= btnData.Cost then
                    local touchParts = getTouchableParts(btnData.Model)
                    for _, part in ipairs(touchParts) do
                        pcall(firetouchinterest, root, part, 0)
                        pcall(firetouchinterest, root, part, 1)
                    end
                    lastBuyTime = tick()
                    break
                end
            end
        else
            for _, btnData in ipairs(buttons) do
                if cash >= btnData.Cost then
                    local touchParts = getTouchableParts(btnData.Model)
                    for _, part in ipairs(touchParts) do
                        pcall(firetouchinterest, root, part, 0)
                        pcall(firetouchinterest, root, part, 1)
                    end
                    lastBuyTime = tick()
                    break
                end
            end
        end
    end)
end

function stopAutoBuild()
    if buildConn then buildConn:Disconnect(); buildConn = nil end
end

-- ============================================
-- ANTI KILL AURA (DEFENSE)
-- ============================================
function startAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect() end
    antiAuraConn = RunService.Heartbeat:Connect(function()
        updateThreatLevel()
        if not AntiAura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar:FindFirstChild("Humanoid")
        if root then
            for _, part in ipairs(myChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part:SetNetworkOwner(player) end)
                end
            end
            if AntiAura.Dodge then
                local offset = Vector3.new(0, math.sin(tick() * 60) * 0.8, 0)
                root.CFrame = root.CFrame + offset
            end
            if AntiAura.Repel then
                for _, otherPlr in ipairs(Players:GetPlayers()) do
                    if otherPlr ~= player and otherPlr.Character then
                        for _, tool in ipairs(otherPlr.Character:GetChildren()) do
                            if tool:IsA("Tool") then
                                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                                if handle then
                                    local dist = (handle.Position - root.Position).Magnitude
                                    if dist < 12 then
                                        local direction = (root.Position - handle.Position).Unit
                                        local bodyMover = Instance.new("BodyVelocity")
                                        bodyMover.MaxForce = Vector3.new(4000, 4000, 4000)
                                        bodyMover.Velocity = direction * 80
                                        bodyMover.Parent = handle
                                        task.delay(0.1, function() bodyMover:Destroy() end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if hum and AntiAura.GodMode then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end)
end

function stopAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect(); antiAuraConn = nil end
end

-- ============================================
-- REACH
-- ============================================
local reachHL = {}

local function applyReach()
    local myChar = player.Character
    if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = nil
            for _, obj in ipairs(t:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
                    part = obj.Parent; break
                end
            end
            if not part then part = t:FindFirstChildWhichIsA("BasePart") end
            if part then
                part.Size = part.Size * ReachSize
                part.Massless = true
                if not reachHL[part] then
                    local hl = Instance.new("Highlight", part)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                    hl.OutlineTransparency = 0
                    reachHL[part] = hl
                end
            end
        end
    end
end

function startReach()
    applyReach()
    player.CharacterAdded:Connect(applyReach)
end

function stopReach()
    for part, hl in pairs(reachHL) do
        if hl and hl.Parent == part then hl:Destroy() end
    end
    table.clear(reachHL)
    local myChar = player.Character
    if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = nil
            for _, obj in ipairs(t:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
                    part = obj.Parent; break
                end
            end
            if not part then part = t:FindFirstChildWhichIsA("BasePart") end
            if part then
                part.Size = part.Size / ReachSize
            end
        end
    end
end

-- ============================================
-- FAST RESPAWN
-- ============================================
function startFastRespawn()
    local Guide = ReplicatedStorage:FindFirstChild("Guide")
    local last = 0
    local function respawn()
        if tick() - last < 0.05 then return end
        last = tick()
        pcall(function()
            if Guide then
                Guide:FireServer()
            else
                player:LoadCharacter()
            end
        end)
    end
    local function hook(c)
        local hum = c:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function(hp)
            if hp <= 0 then respawn() end
        end)
        hum.Died:Connect(respawn)
    end
    if player.Character then hook(player.Character) end
    player.CharacterAdded:Connect(hook)
end

-- ============================================
-- BUILD THE UI  (★ FIX: all trailing spaces removed from strings)
-- ============================================
local FluentWindow = Fluent:CreateWindow({
    Title = "Power Tycoon Hub",
    SubTitle = "Architectural Master Edition",
    Version = "v1.2",
    TabWidth = 150,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Custom",
    CustomTheme = {
        Background = THEME.Base,
        Panel = THEME.Element,
        Text = THEME.Text,
        Muted = THEME.SubText,
        Accent = THEME.Accent,
    },
})

local SPT_Tab     = FluentWindow:CreateTab("Super Power Tycoon", "solar/rocket-bold")
local MPT_Tab     = FluentWindow:CreateTab("Mega Power Tycoon",  "solar/bolt-bold")
local Updates_Tab = FluentWindow:CreateTab("Updates",            "solar/update-bold")
local Settings_Tab= FluentWindow:CreateTab("Settings",           "solar/setting-bold")

local SPT_Combat = SPT_Tab:CreatePage("Combat", "solar/fight-bold")
local SPT_Tycoon = SPT_Tab:CreatePage("Tycoon", "solar/building-bold")
local SPT_Misc   = SPT_Tab:CreatePage("Movement & Visuals", "solar/walk-bold")
local SPT_Utils  = SPT_Tab:CreatePage("Utilities", "solar/tool-bold")

local MPT_Page   = MPT_Tab:CreatePage("Omni-Kill Suite", "solar/star-bold")
local MPT_Tycoon = MPT_Tab:CreatePage("Tycoon Sovereign", "solar/cash-bold")
local MPT_Spawn  = MPT_Tab:CreatePage("Spawn Supremacy", "solar/refresh-bold")

local Updates_Page  = Updates_Tab:CreatePage("Changelog", "solar/list-check-bold")
local Settings_Page = Settings_Tab:CreatePage("Settings", "solar/settings-bold")

-- ========== SPT COMBAT ==========
local AuraSection = SPT_Combat:AddSection("Multi-Target Aura")
AuraSection:AddDropdown({
    Title = "Select Aura Targets",
    Options = getServerPlayers(),
    MultiSelection = true,
    Callback = function(selectedNames)
        table.clear(Aura.TargetList)
        if selectedNames then
            for _, name in ipairs(selectedNames) do  -- ★ FIX: "d o" → "do"
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(Aura.TargetList, plr) end
            end
        end
        Fluent:Notify({Title="Aura Targets Updated", Content="Targeting "..#Aura.TargetList.." players.", Type="Info", Duration=2})
    end
})
AuraSection:AddToggle({
    Title = "Enable Aura",
    Default = false,
    Callback = function(state)
        Aura.Enabled = state
        if state then startAuraLoop() else stopAuraLoop() end
    end
})
AuraSection:AddToggle({
    Title = "Instant Kill",
    Default = false,
    Callback = function(state)
        InstantKill = state
    end
})

local ToolFollowSection = SPT_Combat:AddSection("Tool Follow")
ToolFollowSection:AddDropdown({
    Title = "Select Tool Follow Targets",
    Options = getServerPlayers(),
    MultiSelection = true,
    Callback = function(selectedNames)
        table.clear(ToolFollow.Targets)
        if selectedNames then
            for _, name in ipairs(selectedNames) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(ToolFollow.Targets, plr) end
            end
        end
        Fluent:Notify({Title="Tool Targets Updated", Content="Following "..#ToolFollow.Targets.." players.", Type="Info", Duration=2})
    end
})
ToolFollowSection:AddToggle({
    Title = "Enable Tool Follow",
    Default = false,
    Callback = function(state)
        ToolFollow.Enabled = state
        if state then startToolFollow() else stopToolFollow() end
    end
})

local DefenseSection = SPT_Combat:AddSection("Defense / Anti-Aura")
DefenseSection:AddToggle({
    Title = "Enable Anti-Aura",
    Default = false,
    Callback = function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end
})
DefenseSection:AddToggle({
    Title = "God Mode (Anti-Damage)",
    Default = false,
    Callback = function(state) AntiAura.GodMode = state end
})
DefenseSection:AddToggle({
    Title = "Micro-Dodge (Blink)",
    Default = false,
    Callback = function(state) AntiAura.Dodge = state end
})
DefenseSection:AddToggle({
    Title = "Repel (Anti-Touch)",
    Default = false,
    Callback = function(state) AntiAura.Repel = state end
})

-- ========== SPT TYCOON ==========
local TycoonCoreSection = SPT_Tycoon:AddSection("Tycoon Automation")
TycoonCoreSection:AddToggle({
    Title = "Auto Claim Money",
    Default = false,
    Callback = function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end
})
TycoonCoreSection:AddToggle({
    Title = "Smart Auto Build",
    Default = false,
    Callback = function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end
})

local AutoToolsSection = SPT_Tycoon:AddSection("Auto Get Tools")
AutoToolsSection:AddToggle({
    Title = "Auto Grab Weapons",
    Default = false,
    Callback = function(state)
        AutoGetTools = state
        if state then
            if grabLoopConn then grabLoopConn:Disconnect() end
            grabLoopConn = RunService.PreSimulation:Connect(function()
                if not AutoGetTools then return end
                local myChar = player.Character
                if not myChar then return end
                local root = myChar:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for toolName, base in pairs(toolToBase) do
                    if player.Backpack:FindFirstChild(toolName) or myChar:FindFirstChild(toolName) then continue end
                    local pads = padsByBase[base]
                    if not pads then continue end
                    local closest, minDist = nil, 1000
                    for _, pad in ipairs(pads) do
                        local d = (pad.Position - root.Position).Magnitude
                        if d < minDist then minDist = d; closest = pad end
                    end
                    if closest then
                        for i = 1, 8 do
                            pcall(firetouchinterest, root, closest, 0)
                            pcall(firetouchinterest, root, closest, 1)
                        end
                    end
                end
            end)
        else
            if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
        end
    end
})

local CooldownSection = SPT_Tycoon:AddSection("Tools & Cooldown")
CooldownSection:AddToggle({
    Title = "Auto Use Tools (0 delay)",
    Default = false,
    Callback = function(state)
        AutoTools = state
        if state then
            toolLoopConn = RunService.RenderStepped:Connect(function()
                if not AutoTools then return end
                local myChar = player.Character
                if not myChar or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end
                for _, t in ipairs(myChar:GetChildren()) do
                    if t:IsA("Tool") then pcall(function() t:Activate() end) end
                end
                for _, t in ipairs(player.Backpack:GetChildren()) do  -- ★ FIX: "for  , t" → "for _, t"
                    if t:IsA("Tool") then
                        t.Parent = myChar
                        pcall(function() t:Activate() end)
                    end
                end
            end)
        else
            if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end
        end
    end
})
CooldownSection:AddToggle({  -- ★ FIX: "AddTog gle" → "AddToggle"
    Title = "No Cooldown (arms stick)",
    Default = false,
    Callback = function(state)
        NoCooldown = state
        if state then
            if not getgenv().NoCooldownHooked then
                hookfunction(wait, function() return RunService.PostSimulation:Wait() end)  -- ★ FIX: "PostSimulatio n"
                hookfunction(task.wait, function() return RunService.PostSimulation:Wait() end)
                hookfunction(delay, function(_, func) task.spawn(func) end)  -- ★ FIX: "( , func)" → "(_, func)"
                hookfunction(spawn, function(func) task.spawn(func) end)
                getgenv().NoCooldownHooked = true
            end
            task.spawn(function()
                while NoCooldown do
                    local myChar = player.Character
                    if myChar then
                        for _, t in ipairs(myChar:GetChildren()) do
                            if t:IsA("Tool") and t:FindFirstChild("Handle") then
                                pcall(function() t.Enabled = true end)
                                local handle = t.Handle
                                if handle:IsA("BasePart") then
                                    handle.CanCollide = false
                                end
                            end
                        end
                    end
                    RunService.RenderStepped:Wait()
                end
            end)
        end
    end
})

-- ========== SPT MISC ==========
local ReachSection = SPT_Misc:AddSection("Reach")
ReachSection:AddSlider({
    Title = "Reach Size",
    Min = 1,
    Max = 10,
    Default = ReachSize,
    Rounding = 1,
    Callback = function(value)
        ReachSize = value
        if Reach then
            stopReach()
            startReach()
        end
    end
})
ReachSection:AddToggle({
    Title = "Reach (hitbox + outline)",
    Default = false,
    Callback = function(state)
        Reach = state
        if state then startReach() else stopReach() end
    end
})

local RespawnSection = SPT_Misc:AddSection("Respawn & Protection")
RespawnSection:AddToggle({
    Title = "Fast Respawn",
    Default = false,
    Callback = function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end
})
RespawnSection:AddToggle({
    Title = "Anti Spawnkill (invincible 3s)",
    Default = false,
    Callback = function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9
                hum.Health = 9e9
                local ff = Instance.new("ForceField", c)
                ff.Visible = false
                task.delay(3, function()
                    if hum and hum.Parent then
                        hum.MaxHealth = 100
                        hum.Health = 100
                    end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end
})

-- ========== SPT UTILITIES ==========
local UtilsSection = SPT_Utils:AddSection("Tools")
UtilsSection:AddButton({
    Title = "Open Game Dumper",
    Callback = function()
        if CoreGui:FindFirstChild("DumperGUI") then return end
        local dGui = Instance.new("ScreenGui", CoreGui)
        dGui.Name = "DumperGUI"
        dGui.ResetOnSpawn = false
        local frame = Instance.new("Frame", dGui)
        frame.Size = UDim2.new(0, 650, 0, 500)
        frame.Position = UDim2.new(0.5, -325, 0.5, -250)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.Active = true
        frame.Draggable = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        title.Text = "FULL GAME SCANNER"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18

        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(1, -10, 1, -80)
        scroll.Position = UDim2.new(0, 5, 0, 40)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 8
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.BorderSizePixel = 0

        local list = Instance.new("UIListLayout", scroll)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 2)

        local copyBtn = Instance.new("TextButton", frame)
        copyBtn.Size = UDim2.new(0, 120, 0, 30)
        copyBtn.Position = UDim2.new(0.5, -160, 1, -40)
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
        copyBtn.Text = "Copy Log"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 14

        local closeBtn = Instance.new("TextButton", frame)
        closeBtn.Size = UDim2.new(0, 100, 0, 30)
        closeBtn.Position = UDim2.new(0.5, 30, 1, -40)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.MouseButton1Click:Connect(function() dGui:Destroy() end)

        local logLines = {}
        local function addLog(text, color)
            table.insert(logLines, text)
            local lbl = Instance.new("TextLabel", scroll)
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
        end

        copyBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(table.concat(logLines, "\n")) end)
            addLog("Copied to clipboard!", Color3.fromRGB(100, 255, 100))
        end)

        addLog("SCANNING ALL GAME OBJECTS...", Color3.fromRGB(255, 200, 50))

        local function scan(container, depth)
            for _, child in ipairs(container:GetChildren()) do
                local indent = string.rep("  ", depth)
                local icon = ""
                if child:IsA("Folder") then icon = "[Folder] "
                elseif child:IsA("Tool") then icon = "[Tool] "
                elseif child:IsA("Model") then icon = "[Model] "
                elseif child:IsA("RemoteEvent") then icon = "[RemoteEvent] "
                elseif child:IsA("RemoteFunction") then icon = "[RemoteFunction] "
                elseif child:IsA("BindableEvent") or child:IsA("BindableFunction") then icon = "["..child.ClassName.."] "
                end
                if icon ~= "" then
                    addLog(indent .. icon .. child.Name, Color3.fromRGB(200, 200, 255))
                    if child:IsA("Folder") then scan(child, depth + 1) end
                end
            end
        end

        addLog("--- WORKSPACE ---", Color3.fromRGB(100, 200, 255)); scan(workspace, 0)
        addLog("--- REPLICATEDSTORAGE ---", Color3.fromRGB(100, 200, 255)); scan(ReplicatedStorage, 0)
        addLog("--- REPLICATEDFIRST ---", Color3.fromRGB(100, 200, 255)); scan(game:GetService("ReplicatedFirst"), 0)
        addLog("--- LIGHTING ---", Color3.fromRGB(100, 200, 255)); scan(game:GetService("Lighting"), 0)
        if player:FindFirstChild("Backpack") then
            addLog("--- PLAYER BACKPACK ---", Color3.fromRGB(100, 200, 255)); scan(player.Backpack, 0)
        end
        if player.Character then
            addLog("--- PLAYER CHARACTER ---", Color3.fromRGB(100, 200, 255)); scan(player.Character, 0)
        end
        addLog("SCAN COMPLETE!", Color3.fromRGB(100, 255, 255))
    end
})

UtilsSection:AddTextbox({
    Title = "Set Damage Remote",
    Placeholder = "game.ReplicatedStorage.DealDamage",
    Callback = function(text)
        if text and text ~= "" then
            local success, remote = pcall(function() return loadstring("return " .. text)() end)
            if success and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                print("Damage remote set to:", DAMAGE_REMOTE:GetFullName())
                Fluent:Notify({Title="Remote Set", Content="Damage remote updated successfully.", Type="Info", Duration=3})
            else
                warn("Invalid remote path.")
                Fluent:Notify({Title="Error", Content="Invalid remote path.", Type="Error", Duration=3})
            end
        end
    end
})

-- ========== MPT: OMNI-KILL SUITE ==========
local MPT_CombatSec = MPT_Page:AddSection("Omni-Kill Engine")
MPT_CombatSec:AddToggle({
    Title = "Enable Omni-Kill",
    Default = false,
    Callback = function(state)
        Aura.Enabled = state
        InstantKill = state
        if state then startAuraLoop() else stopAuraLoop() end
    end
})
MPT_CombatSec:AddSlider({
    Title = "Kill Priority (Prediction)",
    Min = 0.05,
    Max = 0.2,
    Default = 0.1,
    Rounding = 0.01,
    Callback = function(value)
        latencyEstimate = value
    end
})
MPT_CombatSec:AddButton({
    Title = "Manual Omni-Kill Burst",
    Callback = function()
        local originalEnabled = Aura.Enabled
        Aura.Enabled = true
        task.wait(0.1)
        Aura.Enabled = originalEnabled
    end
})

-- ========== MPT: TYCOON SOVEREIGN ==========
local MPT_TycoonSec = MPT_Tycoon:AddSection("Sovereign Economy")
MPT_TycoonSec:AddToggle({
    Title = "Enable Sovereign Economy",
    Default = false,
    Callback = function(state)
        AutoClaimMoney = state
        AutoBuild = state
        if state then
            startClaimMoney()
            startAutoBuild()
        else
            stopClaimMoney()
            stopAutoBuild()
        end
    end
})
MPT_TycoonSec:AddSlider({
    Title = "Defense Threshold (Threat Radius)",
    Min = 20,
    Max = 100,
    Default = ThreatRadius,
    Rounding = 1,
    Callback = function(value)
        ThreatRadius = value
    end
})
MPT_TycoonSec:AddLabel("Current Threat Level: " .. ThreatLevel)

-- ========== MPT: SPAWN SUPREMACY ==========
local MPT_UtilsSec = MPT_Spawn:AddSection("Spawn Supremacy")
MPT_UtilsSec:AddToggle({
    Title = "Enable Supremacy Mode",
    Default = false,
    Callback = function(state)
        AntiSpawnkill = state
    end
})
MPT_UtilsSec:AddSlider({
    Title = "Decoy Lifespan (seconds)",
    Min = 1, Max = 10, Default = 5, Rounding = 1,
    Callback = function(value) end
})
MPT_UtilsSec:AddSlider({
    Title = "Teleport Offset Distance",
    Min = 1, Max = 10, Default = 3, Rounding = 1,
    Callback = function(value) end
})

-- ========== UP
