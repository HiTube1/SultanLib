-- We13ideLib Source Code for Xeno Executor
-- Elite Neon Night UI, Glowing Tabs, Smart Search, Animated Stars, Configs, Notifications, Deletion
-- Smooth Animations, Splash Screen, Mobile Support, Keybinds, Multi-Dropdowns, Dynamic Creation

local We13ideLib = {
    Version = "2.9.0",
    Themes = {
        NeonNight = {
            MainBackground = Color3.fromRGB(18, 14, 28),
            Sidebar = Color3.fromRGB(14, 11, 22),
            Section = Color3.fromRGB(24, 20, 36),
            Accent = Color3.fromRGB(190, 60, 255),
            TextPrimary = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(140, 130, 160),
            ElementBg = Color3.fromRGB(30, 25, 45),
            Outline = Color3.fromRGB(0, 0, 0),
            MainTrans = 0.75,
            SectionTrans = 0
        }
    },
    ActiveTheme = nil,
    ThemedElements = {}
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- File System Setup
local LibPath = "We13ideLib"
local ConfigPath = LibPath .. "/config"

if isfolder and makefolder then
    if not isfolder(LibPath) then makefolder(LibPath) end
    if not isfolder(ConfigPath) then makefolder(ConfigPath) end
end

local function GetParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = CoreGui
        return gui
    end
    return CoreGui
end

function We13ideLib:ResolveIcon(icon, windowName)
    if not icon or icon == "" then return "" end
    local strIcon = tostring(icon)
    if strIcon:match("^rbxassetid://") or strIcon:match("^rbxthumb://") then return strIcon end
    
    local IconsFolder = windowName .. "/Icons"
    if isfolder and makefolder then
        if not isfolder(windowName) then makefolder(windowName) end
        if not isfolder(IconsFolder) then makefolder(IconsFolder) end
    end

    if strIcon:match("^http") then
        if request and writefile and getcustomasset then
            local hash = 0
            for i = 1, #strIcon do 
                hash = (hash * 31 + string.byte(strIcon, i)) % 4294967296 
            end
            local fileName = IconsFolder .. "/" .. tostring(hash) .. ".png"
            if isfile and isfile(fileName) then return getcustomasset(fileName) end
            local success, res = pcall(function() return request({Url = strIcon, Method = "GET"}) end)
            if success and res and res.Success then 
                writefile(fileName, res.Body) 
                return getcustomasset(fileName)
            end
        end
        return ""
    end
    local num = strIcon:gsub("%D", "")
    if num ~= "" then return "rbxassetid://" .. num end
    return ""
end

function We13ideLib:Tween(obj, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Back
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.4, style, direction), properties)
    tween:Play()
    return tween
end

-- [ФИКС]: Явно приводим isTrans к false, если он не передан
function We13ideLib:RegisterTheme(obj, prop, role, isTrans)
    isTrans = isTrans or false 
    table.insert(self.ThemedElements, {Obj = obj, Prop = prop, Role = role, IsTrans = isTrans})
    if isTrans then
        obj[prop] = self.ActiveTheme[role] or 0
    else
        obj[prop] = self.ActiveTheme[role] or Color3.new(1,1,1)
    end
end

--[ФИКС]: Теперь проверки цвета и прозрачности работают 100% стабильно
function We13ideLib:UpdateTheme(role, value, isTrans)
    isTrans = isTrans or false
    self.ActiveTheme[role] = value
    for i = #self.ThemedElements, 1, -1 do
        local item = self.ThemedElements[i]
        if item.Obj and item.Obj.Parent then
            if item.Role == role and item.IsTrans == isTrans then
                item.Obj[item.Prop] = value 
            end
        else
            table.remove(self.ThemedElements, i)
        end
    end
end

function We13ideLib:CreateWindow(options)
    local Theme = self.Themes.NeonNight
    self.ActiveTheme = Theme
    local WindowName = options.Title or "WEXSIDE"
    
    local WindowObj = { Tabs = {}, SearchableSections = {}, IsLoaded = false }

    local ScreenGui = Instance.new("ScreenGui", GetParent())
    ScreenGui.Name = "We13ideCore_" .. WindowName
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 850, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -280)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false 
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    self:RegisterTheme(MainFrame, "BackgroundColor3", "MainBackground")
    self:RegisterTheme(MainFrame, "BackgroundTransparency", "MainTrans", true)
    
    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0

    local isVisible = true

    -- ================= ВОТЕРМАРКА (SPLASH SCREEN) =================
    local SplashFrame = Instance.new("Frame", ScreenGui)
    SplashFrame.Size = UDim2.new(0, 300, 0, 150)
    SplashFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    SplashFrame.BackgroundTransparency = 1
    SplashFrame.ZIndex = 200

    local SplashIcon = Instance.new("ImageLabel", SplashFrame)
    SplashIcon.Size = UDim2.new(0, 80, 0, 80)
    SplashIcon.Position = UDim2.new(0.5, -40, 0, 10)
    SplashIcon.BackgroundTransparency = 1
    SplashIcon.ImageTransparency = 1
    local resolvedLogoForSplash = We13ideLib:ResolveIcon(options.LogoIcon, WindowName)
    if resolvedLogoForSplash ~= "" then SplashIcon.Image = resolvedLogoForSplash end
    self:RegisterTheme(SplashIcon, "ImageColor3", "Accent")
    
    local SplashText = Instance.new("TextLabel", SplashFrame)
    SplashText.Size = UDim2.new(1, 0, 0, 40)
    SplashText.Position = UDim2.new(0, 0, 0, 100)
    SplashText.BackgroundTransparency = 1
    SplashText.Text = "We13ideLib"
    SplashText.Font = Enum.Font.GothamBold
    SplashText.TextSize = 32
    SplashText.TextTransparency = 1
    self:RegisterTheme(SplashText, "TextColor3", "Accent")

    local SplashScale = Instance.new("UIScale", SplashFrame)
    SplashScale.Scale = 0.5

    task.spawn(function()
        We13ideLib:Tween(SplashScale, {Scale = 1}, 0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        We13ideLib:Tween(SplashIcon, {ImageTransparency = 0}, 0.5)
        We13ideLib:Tween(SplashText, {TextTransparency = 0}, 0.5)

        task.wait(2) 

        We13ideLib:Tween(SplashScale, {Scale = 1.2}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        We13ideLib:Tween(SplashIcon, {ImageTransparency = 1}, 0.5)
        local twn = We13ideLib:Tween(SplashText, {TextTransparency = 1}, 0.5)
        twn.Completed:Wait()

        SplashFrame:Destroy()
        
        WindowObj.IsLoaded = true
        if isVisible then
            MainFrame.Visible = true
            We13ideLib:Tween(MainScale, {Scale = 1}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        
        if UserInputService.TouchEnabled then
            local MobileBtn = Instance.new("ImageButton", ScreenGui)
            MobileBtn.Size = UDim2.new(0, 46, 0, 46)
            MobileBtn.Position = UDim2.new(0.5, -23, 0, 10)
            MobileBtn.AutoButtonColor = false
            MobileBtn.ZIndex = 300
            Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(1, 0)
            We13ideLib:RegisterTheme(MobileBtn, "BackgroundColor3", "MainBackground")
            
            local MScale = Instance.new("UIScale", MobileBtn)
            MScale.Scale = 0
            
            local MStroke = Instance.new("UIStroke", MobileBtn)
            MStroke.Thickness = 1.5
            We13ideLib:RegisterTheme(MStroke, "Color", "Accent")

            if options.LogoIcon and options.LogoIcon ~= "" then
                local MIcon = Instance.new("ImageLabel", MobileBtn)
                MIcon.Size = UDim2.new(0, 24, 0, 24)
                MIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                MIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
                MIcon.BackgroundTransparency = 1
                MIcon.Image = We13ideLib:ResolveIcon(options.LogoIcon, WindowName)
                We13ideLib:RegisterTheme(MIcon, "ImageColor3", "Accent")
            end

            We13ideLib:Tween(MScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            local mDragging, mDragStart, mStartPos, dragMoved
            MobileBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mDragging = true
                    dragMoved = false
                    mDragStart = input.Position
                    mStartPos = MobileBtn.Position
                    We13ideLib:Tween(MScale, {Scale = 0.9}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if mDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                    local delta = input.Position - mDragStart
                    if delta.Magnitude > 5 then dragMoved = true end
                    MobileBtn.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mDragging = false
                    We13ideLib:Tween(MScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    if not dragMoved and WindowObj.IsLoaded then
                        isVisible = not isVisible
                        if isVisible then
                            MainFrame.Visible = true
                            We13ideLib:Tween(MainScale, {Scale = 1}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        else
                            We13ideLib:Tween(MainScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
                                if not isVisible then MainFrame.Visible = false end
                            end)
                        end
                    end
                end
            end)
        end
    end)
    -- ===============================================================
    
    local StarsFrame = Instance.new("Frame", MainFrame)
    StarsFrame.Size = UDim2.new(1, 0, 1, 0)
    StarsFrame.BackgroundTransparency = 1
    StarsFrame.ZIndex = 0
    StarsFrame.ClipsDescendants = true
    Instance.new("UICorner", StarsFrame).CornerRadius = UDim.new(0, 12)

    for i = 1, 35 do
        local star = Instance.new("ImageLabel", StarsFrame)
        star.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundTransparency = 1
        star.Image = "rbxassetid://11686550304"
        self:RegisterTheme(star, "ImageColor3", "Accent")
        star.ImageTransparency = math.random(30, 90) / 100
        star.ZIndex = 0
        
        task.spawn(function()
            while star and star.Parent do
                We13ideLib:Tween(star, {ImageTransparency = math.random(10, 40)/100}, math.random(2, 4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(math.random(2, 4))
                if not star or not star.Parent then break end
                We13ideLib:Tween(star, {ImageTransparency = math.random(70, 100)/100}, math.random(2, 4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(math.random(2, 4))
            end
        end)
    end
    
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < MainFrame.AbsolutePosition.Y + 60 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            We13ideLib:Tween(MainScale, {Scale = 0.98}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            We13ideLib:Tween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
            We13ideLib:Tween(MainScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.BackgroundTransparency = 0
    Sidebar.ZIndex = 2
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    self:RegisterTheme(Sidebar, "BackgroundColor3", "Sidebar")
    
    local HideCorner = Instance.new("Frame", Sidebar)
    HideCorner.Size = UDim2.new(0, 15, 1, 0)
    HideCorner.Position = UDim2.new(1, -15, 0, 0)
    HideCorner.BackgroundTransparency = 0
    HideCorner.BorderSizePixel = 0
    HideCorner.ZIndex = 2
    self:RegisterTheme(HideCorner, "BackgroundColor3", "Sidebar")

    local LogoIcon = Instance.new("ImageLabel", Sidebar)
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 20, 0, 20)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.ImageColor3 = Theme.Accent
    LogoIcon.ZIndex = 3
    if resolvedLogoForSplash ~= "" then LogoIcon.Image = resolvedLogoForSplash end
    self:RegisterTheme(LogoIcon, "ImageColor3", "Accent")

    local LogoText = Instance.new("TextLabel", Sidebar)
    LogoText.Text = string.upper(WindowName)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 18
    LogoText.BackgroundTransparency = 1
    LogoText.Position = UDim2.new(0, 55, 0, 22)
    LogoText.Size = UDim2.new(1, -75, 0, 20)
    LogoText.TextXAlignment = Enum.TextXAlignment.Left
    LogoText.ZIndex = 3
    self:RegisterTheme(LogoText, "TextColor3", "TextPrimary")

    local ProfileFrame = Instance.new("Frame", Sidebar)
    ProfileFrame.Size = UDim2.new(1, -40, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 20, 0, 70)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.ZIndex = 3

    local Avatar = Instance.new("ImageLabel", ProfileFrame)
    Avatar.Size = UDim2.new(0, 30, 0, 30)
    Avatar.Position = UDim2.new(0, 0, 0.5, -15)
    Avatar.BackgroundTransparency = 1
    Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    Avatar.ZIndex = 3
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    local UserName = Instance.new("TextLabel", ProfileFrame)
    UserName.Text = LocalPlayer.DisplayName
    UserName.Font = Enum.Font.GothamBold
    UserName.TextSize = 13
    UserName.BackgroundTransparency = 1
    UserName.Position = UDim2.new(0, 40, 0, 2)
    UserName.Size = UDim2.new(1, -40, 0, 15)
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.ZIndex = 3
    self:RegisterTheme(UserName, "TextColor3", "TextPrimary")

    local SubRole = Instance.new("TextLabel", ProfileFrame)
    SubRole.Text = options.ProfileSub or "Elite User"
    SubRole.Font = Enum.Font.Gotham
    SubRole.TextSize = 11
    SubRole.BackgroundTransparency = 1
    SubRole.Position = UDim2.new(0, 40, 0, 18)
    SubRole.Size = UDim2.new(1, -40, 0, 15)
    SubRole.TextXAlignment = Enum.TextXAlignment.Left
    SubRole.ZIndex = 3
    self:RegisterTheme(SubRole, "TextColor3", "TextSecondary")

    local TabsContainer = Instance.new("ScrollingFrame", Sidebar)
    TabsContainer.Size = UDim2.new(1, 0, 1, -170)
    TabsContainer.Position = UDim2.new(0, 0, 0, 130)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.ScrollBarThickness = 0
    TabsContainer.ZIndex = 3
    local TabsListLayout = Instance.new("UIListLayout", TabsContainer)
    
    TabsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabsContainer.CanvasSize = UDim2.new(0, 0, 0, TabsListLayout.AbsoluteContentSize.Y + 10)
    end)

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, -220, 0, 60)
    TopBar.Position = UDim2.new(0, 220, 0, 0)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 2

    local SearchBoxBg = Instance.new("Frame", TopBar)
    SearchBoxBg.Size = UDim2.new(0, 200, 0, 32)
    SearchBoxBg.Position = UDim2.new(1, -220, 0.5, -16)
    SearchBoxBg.ZIndex = 3
    Instance.new("UICorner", SearchBoxBg).CornerRadius = UDim.new(0, 6)
    self:RegisterTheme(SearchBoxBg, "BackgroundColor3", "ElementBg")
    
    local SearchScale = Instance.new("UIScale", SearchBoxBg)

    local SearchIcon = Instance.new("ImageLabel", SearchBoxBg)
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://10014844383"
    SearchIcon.ZIndex = 3
    self:RegisterTheme(SearchIcon, "ImageColor3", "TextSecondary")

    local SearchInput = Instance.new("TextBox", SearchBoxBg)
    SearchInput.Size = UDim2.new(1, -35, 1, 0)
    SearchInput.Position = UDim2.new(0, 30, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search features..."
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ZIndex = 3
    self:RegisterTheme(SearchInput, "TextColor3", "TextPrimary")
    self:RegisterTheme(SearchInput, "PlaceholderColor3", "TextSecondary")

    SearchInput.Focused:Connect(function() We13ideLib:Tween(SearchScale, {Scale = 1.05}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end)
    SearchInput.FocusLost:Connect(function() We13ideLib:Tween(SearchScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end)

    local PagesContainer = Instance.new("Frame", MainFrame)
    PagesContainer.Size = UDim2.new(1, -220, 1, -60)
    PagesContainer.Position = UDim2.new(0, 220, 0, 60)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ZIndex = 2

    -- ================= НОВАЯ СИСТЕМА УВЕДОМЛЕНИЙ =================
    local NotifContainer = Instance.new("Frame", ScreenGui)
    NotifContainer.Size = UDim2.new(0, 280, 1, -40)
    NotifContainer.Position = UDim2.new(1, -300, 0, 20)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.ZIndex = 100
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)

    function WindowObj:Notify(nInfo)
        local NTitle = nInfo.Title or "Notification"
        local NText = nInfo.Content or ""
        local NDuration = nInfo.Duration or 3

        local NFrame = Instance.new("Frame", NotifContainer)
        NFrame.Size = UDim2.new(1, 0, 0, 60)
        NFrame.BackgroundTransparency = 0.3
        NFrame.Position = UDim2.new(1, 300, 0, 0)
        Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 8)
        We13ideLib:RegisterTheme(NFrame, "BackgroundColor3", "ElementBg")
        
        local NScale = Instance.new("UIScale", NFrame)
        NScale.Scale = 0.5

        local NAccent = Instance.new("Frame", NFrame)
        NAccent.Size = UDim2.new(0, 4, 1, -12)
        NAccent.Position = UDim2.new(0, 6, 0, 6)
        Instance.new("UICorner", NAccent).CornerRadius = UDim.new(1, 0)
        We13ideLib:RegisterTheme(NAccent, "BackgroundColor3", "Accent")

        local NIcon = Instance.new("ImageLabel", NFrame)
        NIcon.Size = UDim2.new(0, 20, 0, 20)
        NIcon.Position = UDim2.new(0, 18, 0, 10)
        NIcon.BackgroundTransparency = 1
        NIcon.Image = "rbxassetid://10014844383" 
        if nInfo.Icon then NIcon.Image = We13ideLib:ResolveIcon(nInfo.Icon, WindowName) end
        We13ideLib:RegisterTheme(NIcon, "ImageColor3", "Accent")

        local NTitleLabel = Instance.new("TextLabel", NFrame)
        NTitleLabel.Size = UDim2.new(1, -50, 0, 20)
        NTitleLabel.Position = UDim2.new(0, 45, 0, 10)
        NTitleLabel.BackgroundTransparency = 1
        NTitleLabel.Text = NTitle
        NTitleLabel.Font = Enum.Font.GothamBold
        NTitleLabel.TextSize = 13
        NTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        We13ideLib:RegisterTheme(NTitleLabel, "TextColor3", "TextPrimary")

        local NContentLabel = Instance.new("TextLabel", NFrame)
        NContentLabel.Size = UDim2.new(1, -50, 0, 20)
        NContentLabel.Position = UDim2.new(0, 45, 0, 30)
        NContentLabel.BackgroundTransparency = 1
        NContentLabel.Text = NText
        NContentLabel.Font = Enum.Font.Gotham
        NContentLabel.TextSize = 11
        NContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        NContentLabel.TextWrapped = true
        We13ideLib:RegisterTheme(NContentLabel, "TextColor3", "TextSecondary")

        We13ideLib:Tween(NScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        We13ideLib:Tween(NFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        task.spawn(function()
            task.wait(NDuration)
            if NFrame and NFrame.Parent then
                We13ideLib:Tween(NScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                local outTween = We13ideLib:Tween(NFrame, {Position = UDim2.new(1, 300, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                outTween.Completed:Wait()
                NFrame:Destroy()
            end
        end)
    end

    function WindowObj:SetTitle(newTitle)
        LogoText.Text = string.upper(newTitle)
        WindowName = newTitle
    end

    function WindowObj:Close()
        if ScreenGui then
            local twn = We13ideLib:Tween(MainScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            twn.Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        end
    end

    local function CreatePageFrame()
        local Page = Instance.new("ScrollingFrame", PagesContainer)
        Page.Size = UDim2.new(1, 0, 1, -20)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.ZIndex = 2
        
        local PageScale = Instance.new("UIScale", Page)
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 15)
        PageLayout.FillDirection = Enum.FillDirection.Horizontal
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local LeftCol = Instance.new("Frame", Page)
        LeftCol.Size = UDim2.new(0.5, -20, 0, 0)
        LeftCol.BackgroundTransparency = 1
        local LeftLayout = Instance.new("UIListLayout", LeftCol)
        LeftLayout.Padding = UDim.new(0, 15)

        local RightCol = Instance.new("Frame", Page)
        RightCol.Size = UDim2.new(0.5, -20, 0, 0)
        RightCol.BackgroundTransparency = 1
        local RightLayout = Instance.new("UIListLayout", RightCol)
        RightLayout.Padding = UDim.new(0, 15)

        local function UpdateCanvas()
            local maxY = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
            Page.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
            We13ideLib:Tween(LeftCol, {Size = UDim2.new(0.5, -15, 0, LeftLayout.AbsoluteContentSize.Y)}, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            We13ideLib:Tween(RightCol, {Size = UDim2.new(0.5, -15, 0, RightLayout.AbsoluteContentSize.Y)}, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        return Page, PageScale, LeftCol, RightCol
    end

    -- GLOBAL SEARCH LOGIC
    local SearchPage, SearchPageScale, SearchLeftCol, SearchRightCol = CreatePageFrame()
    SearchPage.Name = "GlobalSearchPage"

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower():gsub("%s+", "")
        if query == "" then
            SearchPage.Visible = false
            for _, sec in pairs(WindowObj.SearchableSections) do
                if not sec.IsDestroyed then
                    sec.Frame.Parent = sec.OriginalParent
                    sec.Frame.Visible = true
                    for _, item in pairs(sec.Items) do 
                        if not item.IsDestroyed then item.Frame.Visible = true end
                    end
                end
            end
            for _, t in pairs(WindowObj.Tabs) do
                if not t.IsDestroyed and t.Active then t.Page.Visible = true end
            end
        else
            for _, t in pairs(WindowObj.Tabs) do 
                if not t.IsDestroyed then t.Page.Visible = false end 
            end
            SearchPage.Visible = true
            
            local toggleSearchSide = false
            for _, sec in pairs(WindowObj.SearchableSections) do
                if not sec.IsDestroyed then
                    local secMatches = string.find(sec.CleanTitle, query) ~= nil
                    local hasVisibleItems = false
                    for _, item in pairs(sec.Items) do
                        if not item.IsDestroyed then
                            if secMatches or string.find(item.CleanTitle, query) then
                                item.Frame.Visible = true
                                hasVisibleItems = true
                            else
                                item.Frame.Visible = false
                            end
                        end
                    end
                    
                    if hasVisibleItems or secMatches then
                        sec.Frame.Visible = true
                        if toggleSearchSide then
                            sec.Frame.Parent = SearchRightCol
                        else
                            sec.Frame.Parent = SearchLeftCol
                        end
                        toggleSearchSide = not toggleSearchSide
                    else
                        sec.Frame.Visible = false
                        sec.Frame.Parent = SearchLeftCol
                    end
                end
            end
        end
    end)

    -- CORE UI BUILDER LOGIC
    local function BuildSectionElements(SectionFrame, SectionObj)
        
        local function BindDestroy(itemObj)
            function itemObj:Destroy()
                if self.Frame then self.Frame:Destroy() end
                self.IsDestroyed = true
            end
        end

        -- PARAGRAPH
        function SectionObj:CreateParagraph(pInfo)
            local PFrame = Instance.new("Frame", SectionFrame)
            PFrame.BackgroundTransparency = 1
            PFrame.Size = UDim2.new(1, 0, 0, 0)
            PFrame.AutomaticSize = Enum.AutomaticSize.Y

            local itemObj = {Frame = PFrame, CleanTitle = (pInfo.Title or ""):lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local PLayout = Instance.new("UIListLayout", PFrame)
            PLayout.SortOrder = Enum.SortOrder.LayoutOrder
            PLayout.Padding = UDim.new(0, 4)

            local PTitle = Instance.new("TextLabel", PFrame)
            PTitle.BackgroundTransparency = 1
            PTitle.Size = UDim2.new(1, 0, 0, 14)
            PTitle.Font = Enum.Font.GothamBold
            PTitle.TextSize = 12
            PTitle.TextXAlignment = Enum.TextXAlignment.Left
            PTitle.Text = pInfo.Title or ""
            We13ideLib:RegisterTheme(PTitle, "TextColor3", "TextPrimary")
            if not pInfo.Title or pInfo.Title == "" then PTitle.Visible = false end

            local PContent = Instance.new("TextLabel", PFrame)
            PContent.BackgroundTransparency = 1
            PContent.Size = UDim2.new(1, 0, 0, 0)
            PContent.AutomaticSize = Enum.AutomaticSize.Y
            PContent.Font = Enum.Font.Gotham
            PContent.TextSize = 11
            PContent.TextXAlignment = Enum.TextXAlignment.Left
            PContent.TextYAlignment = Enum.TextYAlignment.Top
            PContent.TextWrapped = true
            PContent.Text = pInfo.Content or ""
            We13ideLib:RegisterTheme(PContent, "TextColor3", "TextSecondary")

            BindDestroy(itemObj)
            itemObj.SetText = function(self, newTitle, newContent)
                if newTitle then PTitle.Text = newTitle; PTitle.Visible = true end
                if newContent then PContent.Text = newContent end
            end
            return itemObj
        end

        -- DIVIDER
        function SectionObj:CreateDivider()
            local DFrame = Instance.new("Frame", SectionFrame)
            DFrame.Size = UDim2.new(1, 0, 0, 14)
            DFrame.BackgroundTransparency = 1
            local itemObj = {Frame = DFrame, CleanTitle = "divider", IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local Line = Instance.new("Frame", DFrame)
            Line.Size = UDim2.new(0.9, 0, 0, 2)
            Line.Position = UDim2.new(0.05, 0, 0.5, -1)
            Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)
            We13ideLib:RegisterTheme(Line, "BackgroundColor3", "ElementBg")

            BindDestroy(itemObj)
            return itemObj
        end

        -- LABEL
        function SectionObj:CreateLabel(lInfo)
            local LabelFrame = Instance.new("Frame", SectionFrame)
            LabelFrame.Size = UDim2.new(1, 0, 0, 20)
            LabelFrame.BackgroundTransparency = 1
            local itemObj = {Frame = LabelFrame, CleanTitle = lInfo.Text:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local LText = Instance.new("TextLabel", LabelFrame)
            LText.Text = lInfo.Text
            LText.Font = Enum.Font.GothamMedium
            LText.TextSize = 12
            LText.BackgroundTransparency = 1
            LText.Size = UDim2.new(1, 0, 1, 0)
            LText.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(LText, "TextColor3", "TextSecondary")

            BindDestroy(itemObj)
            itemObj.SetText = function(self, newText) LText.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- BUTTON
        function SectionObj:CreateButton(bInfo)
            local BtnFrame = Instance.new("Frame", SectionFrame)
            BtnFrame.Size = UDim2.new(1, 0, 0, 32)
            BtnFrame.BackgroundTransparency = 1
            local itemObj = {Frame = BtnFrame, CleanTitle = bInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local Button = Instance.new("TextButton", BtnFrame)
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Text = bInfo.Title
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 12
            Button.AutoButtonColor = false
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            We13ideLib:RegisterTheme(Button, "BackgroundColor3", "ElementBg")
            We13ideLib:RegisterTheme(Button, "TextColor3", "TextPrimary")

            local BtnScale = Instance.new("UIScale", Button)
            Button.MouseEnter:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 1.03}, 0.3, Enum.EasingStyle.Back) end)
            Button.MouseLeave:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
            Button.MouseButton1Down:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 0.92}, 0.1, Enum.EasingStyle.Quad) end)
            Button.MouseButton1Up:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 1.03}, 0.4, Enum.EasingStyle.Back) end)
            
            Button.MouseButton1Click:Connect(function()
                if bInfo.Callback then task.spawn(bInfo.Callback) end
            end)

            BindDestroy(itemObj)
            itemObj.SetText = function(self, newText) Button.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- KEYBIND
        function SectionObj:CreateKeybind(kInfo)
            local KeybindFrame = Instance.new("Frame", SectionFrame)
            KeybindFrame.Size = UDim2.new(1, 0, 0, 30)
            KeybindFrame.BackgroundTransparency = 1
            local itemObj = {Frame = KeybindFrame, CleanTitle = kInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local KTitle = Instance.new("TextLabel", KeybindFrame)
            KTitle.Text = kInfo.Title
            KTitle.Font = Enum.Font.Gotham
            KTitle.TextSize = 12
            KTitle.BackgroundTransparency = 1
            KTitle.Size = UDim2.new(0.6, 0, 1, 0)
            KTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(KTitle, "TextColor3", "TextSecondary")

            local KBtn = Instance.new("TextButton", KeybindFrame)
            KBtn.Size = UDim2.new(0.4, 0, 0, 22)
            KBtn.Position = UDim2.new(0.6, 0, 0.5, -11)
            KBtn.Text = "[ " .. (kInfo.Default and kInfo.Default.Name or "None") .. " ]"
            KBtn.Font = Enum.Font.GothamMedium
            KBtn.TextSize = 11
            KBtn.AutoButtonColor = false
            Instance.new("UICorner", KBtn).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(KBtn, "BackgroundColor3", "ElementBg")
            We13ideLib:RegisterTheme(KBtn, "TextColor3", "Accent")

            local KScale = Instance.new("UIScale", KBtn)
            KeybindFrame.MouseEnter:Connect(function() We13ideLib:Tween(KScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
            KeybindFrame.MouseLeave:Connect(function() We13ideLib:Tween(KScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
            
            local binding = false
            local currentKey = kInfo.Default
            
            KBtn.MouseButton1Click:Connect(function()
                binding = true
                KBtn.Text = "[ ... ]"
                We13ideLib:Tween(KScale, {Scale = 0.95}, 0.1, Enum.EasingStyle.Quad)
                task.wait(0.1)
                We13ideLib:Tween(KScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    if input.KeyCode.Name ~= "Unknown" then
                        currentKey = input.KeyCode
                        KBtn.Text = "[ " .. currentKey.Name .. " ]"
                        if kInfo.KeyChangedCallback then task.spawn(kInfo.KeyChangedCallback, currentKey) end
                    else
                        KBtn.Text = "[ " .. (currentKey and currentKey.Name or "None") .. " ]"
                    end
                elseif not binding and currentKey and input.KeyCode == currentKey and not gameProcessed then
                    if kInfo.Callback then task.spawn(kInfo.Callback, currentKey) end
                end
            end)

            BindDestroy(itemObj)
            itemObj.SetValue = function(self, keycode) currentKey = keycode; KBtn.Text = "[ " .. keycode.Name .. " ]" end
            itemObj.GetValue = function() return currentKey end
            itemObj.SetTitle = function(self, newText) KTitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- TOGGLE
        function SectionObj:CreateToggle(tInfo)
            local ToggleFrame = Instance.new("Frame", SectionFrame)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
            ToggleFrame.BackgroundTransparency = 1
            local itemObj = {Frame = ToggleFrame, CleanTitle = tInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local TTitle = Instance.new("TextLabel", ToggleFrame)
            TTitle.Text = tInfo.Title
            TTitle.Font = Enum.Font.Gotham
            TTitle.TextSize = 12
            TTitle.BackgroundTransparency = 1
            TTitle.Size = UDim2.new(1, -40, 1, 0)
            TTitle.TextXAlignment = Enum.TextXAlignment.Left

            local TBtn = Instance.new("TextButton", ToggleFrame)
            TBtn.Size = UDim2.new(0, 28, 0, 14)
            TBtn.Position = UDim2.new(1, -28, 0.5, -7)
            TBtn.Text = ""
            TBtn.AutoButtonColor = false
            Instance.new("UICorner", TBtn).CornerRadius = UDim.new(1, 0)
            
            local TCircle = Instance.new("Frame", TBtn)
            TCircle.Size = UDim2.new(0, 10, 0, 10)
            TCircle.Position = UDim2.new(0, 2, 0.5, -5)
            Instance.new("UICorner", TCircle).CornerRadius = UDim.new(1, 0)

            local state = tInfo.Default or false

            ToggleFrame.MouseEnter:Connect(function() We13ideLib:Tween(TTitle, {Position = UDim2.new(0, 4, 0, 0)}, 0.3, Enum.EasingStyle.Back) end)
            ToggleFrame.MouseLeave:Connect(function() We13ideLib:Tween(TTitle, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back) end)

            local function Update()
                TCircle.Size = UDim2.new(0, 14, 0, 6)
                We13ideLib:Tween(TBtn, {BackgroundColor3 = state and We13ideLib.ActiveTheme.Accent or We13ideLib.ActiveTheme.ElementBg}, 0.3, Enum.EasingStyle.Quad)
                
                We13ideLib:Tween(TCircle, {
                    Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                    BackgroundColor3 = state and Color3.new(1,1,1) or We13ideLib.ActiveTheme.TextSecondary,
                    Size = UDim2.new(0, 10, 0, 10)
                }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                
                We13ideLib:Tween(TTitle, {TextColor3 = state and We13ideLib.ActiveTheme.TextPrimary or We13ideLib.ActiveTheme.TextSecondary}, 0.3, Enum.EasingStyle.Quad)
                if tInfo.Callback then task.spawn(tInfo.Callback, state) end
            end

            TBtn.MouseButton1Click:Connect(function() state = not state; Update() end)
            Update()
            We13ideLib:RegisterTheme(TBtn, "BorderColor3", "MainBackground")
            
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, val) state = val; Update() end
            itemObj.SetTitle = function(self, newText) TTitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- SLIDER
        function SectionObj:CreateSlider(sInfo)
            local SliderFrame = Instance.new("Frame", SectionFrame)
            SliderFrame.Size = UDim2.new(1, 0, 0, 24)
            SliderFrame.BackgroundTransparency = 1
            local itemObj = {Frame = SliderFrame, CleanTitle = sInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local STitle = Instance.new("TextLabel", SliderFrame)
            STitle.Text = sInfo.Title
            STitle.Font = Enum.Font.Gotham
            STitle.TextSize = 12
            STitle.BackgroundTransparency = 1
            STitle.Size = UDim2.new(0.4, 0, 1, 0)
            STitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(STitle, "TextColor3", "TextSecondary")

            local SValue = Instance.new("TextLabel", SliderFrame)
            SValue.Font = Enum.Font.Gotham
            SValue.TextSize = 11
            SValue.BackgroundTransparency = 1
            SValue.Size = UDim2.new(0.2, 0, 1, 0)
            SValue.Position = UDim2.new(0.8, 0, 0, 0)
            SValue.TextXAlignment = Enum.TextXAlignment.Right
            We13ideLib:RegisterTheme(SValue, "TextColor3", "TextSecondary")

            local STrack = Instance.new("Frame", SliderFrame)
            STrack.Size = UDim2.new(0.4, 0, 0, 3)
            STrack.Position = UDim2.new(0.4, 0, 0.5, -1)
            Instance.new("UICorner", STrack).CornerRadius = UDim.new(1, 0)
            We13ideLib:RegisterTheme(STrack, "BackgroundColor3", "ElementBg")

            local SFill = Instance.new("Frame", STrack)
            SFill.Size = UDim2.new(0.5, 0, 1, 0)
            Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)
            We13ideLib:RegisterTheme(SFill, "BackgroundColor3", "Accent")

            local SBtn = Instance.new("TextButton", STrack)
            SBtn.Size = UDim2.new(1, 0, 1, 12)
            SBtn.Position = UDim2.new(0, 0, 0, -6)
            SBtn.BackgroundTransparency = 1
            SBtn.Text = ""

            local SCircle = Instance.new("Frame", STrack)
            SCircle.Size = UDim2.new(0, 8, 0, 8)
            SCircle.Position = UDim2.new(0.5, -4, 0.5, -4)
            Instance.new("UICorner", SCircle).CornerRadius = UDim.new(1, 0)
            We13ideLib:RegisterTheme(SCircle, "BackgroundColor3", "Accent")

            local SliderScale = Instance.new("UIScale", STrack)
            SliderFrame.MouseEnter:Connect(function() We13ideLib:Tween(SliderScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
            SliderFrame.MouseLeave:Connect(function() We13ideLib:Tween(SliderScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)

            local min, max, val, rounding = sInfo.Min or 0, sInfo.Max or 100, sInfo.Default or 0, sInfo.Rounding or 1

            local function SetValue(v)
                val = math.clamp(math.round(v / rounding) * rounding, min, max)
                local percent = (val - min) / (max - min)
                We13ideLib:Tween(SFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                We13ideLib:Tween(SCircle, {Position = UDim2.new(percent, -4, 0.5, -4)}, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                local fmtStr = string.find(tostring(rounding), "%.") and string.format("%%.%df", string.len(tostring(rounding):match("%.(%d+)"))) or "%d"
                SValue.Text = string.format(fmtStr, val)
                if sInfo.Callback then task.spawn(sInfo.Callback, val) end
            end

            local isDragging = false
            SBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    SCircle.Size = UDim2.new(0,16,0,8)
                    We13ideLib:Tween(SCircle, {Size = UDim2.new(0,14,0,14), Position = UDim2.new(SCircle.Position.X.Scale, -7, 0.5, -7)}, 0.4, Enum.EasingStyle.Back)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if isDragging then
                        isDragging = false
                        SCircle.Size = UDim2.new(0,6,0,14)
                        We13ideLib:Tween(SCircle, {Size = UDim2.new(0,8,0,8), Position = UDim2.new(SCircle.Position.X.Scale, -4, 0.5, -4)}, 0.4, Enum.EasingStyle.Back)
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((UserInputService:GetMouseLocation().X - STrack.AbsolutePosition.X) / STrack.AbsoluteSize.X, 0, 1)
                    SetValue(min + ((max - min) * percent))
                end
            end)

            SetValue(val)
            
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, v) SetValue(v) end
            itemObj.GetValue = function() return val end
            itemObj.SetTitle = function(self, newText) STitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- DROPDOWN 
        function SectionObj:CreateDropdown(dInfo)
            local DropdownFrame = Instance.new("Frame", SectionFrame)
            DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.ClipsDescendants = true
            local itemObj = {Frame = DropdownFrame, CleanTitle = dInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local DTitle = Instance.new("TextLabel", DropdownFrame)
            DTitle.Text = dInfo.Title
            DTitle.Font = Enum.Font.Gotham
            DTitle.TextSize = 12
            DTitle.BackgroundTransparency = 1
            DTitle.Size = UDim2.new(0.5, 0, 0, 30)
            DTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(DTitle, "TextColor3", "TextSecondary")

            local DButton = Instance.new("TextButton", DropdownFrame)
            DButton.Size = UDim2.new(0.5, 0, 0, 22)
            DButton.Position = UDim2.new(0.5, 0, 0, 4)
            DButton.Text = tostring(dInfo.Default or "Select...")
            DButton.Font = Enum.Font.Gotham
            DButton.TextSize = 11
            DButton.AutoButtonColor = false
            DButton.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", DButton).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(DButton, "BackgroundColor3", "ElementBg")
            We13ideLib:RegisterTheme(DButton, "TextColor3", "TextPrimary")

            local DropScale = Instance.new("UIScale", DButton)
            DButton.MouseEnter:Connect(function() We13ideLib:Tween(DropScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
            DButton.MouseLeave:Connect(function() We13ideLib:Tween(DropScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
            DButton.MouseButton1Down:Connect(function() We13ideLib:Tween(DropScale, {Scale = 0.9}, 0.1, Enum.EasingStyle.Quad) end)
            DButton.MouseButton1Up:Connect(function() We13ideLib:Tween(DropScale, {Scale = 1.05}, 0.4, Enum.EasingStyle.Back) end)
            local ListFrame = Instance.new("Frame", DropdownFrame)
            ListFrame.Size = UDim2.new(0.5, 0, 0, 0)
            ListFrame.Position = UDim2.new(0.5, 0, 0, 30)
            Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
            local ListLayout = Instance.new("UIListLayout", ListFrame)
            We13ideLib:RegisterTheme(ListFrame, "BackgroundColor3", "ElementBg")

            local expanded = false
            local values = dInfo.Values or {}
            
            local function Select(val)
                DButton.Text = tostring(val)
                if dInfo.Callback then task.spawn(dInfo.Callback, val) end
            end

            local function Populate(newValues)
                for _, child in ipairs(ListFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, v in ipairs(newValues) do
                    local Item = Instance.new("TextButton", ListFrame)
                    Item.Size = UDim2.new(1, 0, 0, 20)
                    Item.BackgroundTransparency = 1
                    Item.Text = tostring(v)
                    Item.Font = Enum.Font.Gotham
                    Item.TextSize = 11
                    Item.TextColor3 = We13ideLib.ActiveTheme.TextSecondary
                    
                    Item.MouseEnter:Connect(function() We13ideLib:Tween(Item, {TextColor3 = We13ideLib.ActiveTheme.Accent, TextSize = 12}, 0.2, Enum.EasingStyle.Quad) end)
                    Item.MouseLeave:Connect(function() We13ideLib:Tween(Item, {TextColor3 = We13ideLib.ActiveTheme.TextSecondary, TextSize = 11}, 0.2, Enum.EasingStyle.Quad) end)

                    Item.MouseButton1Click:Connect(function()
                        Select(v)
                        expanded = false
                        We13ideLib:Tween(ListFrame, {Size = UDim2.new(0.5, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        We13ideLib:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end)
                end
            end
            
            Populate(values)

            DButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    local h = ListLayout.AbsoluteContentSize.Y
                    ListFrame.Size = UDim2.new(0.5, 0, 0, 0)
                    We13ideLib:Tween(ListFrame, {Size = UDim2.new(0.5, 0, 0, h)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    We13ideLib:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 30 + h)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    We13ideLib:Tween(ListFrame, {Size = UDim2.new(0.5, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    We13ideLib:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
            end)

            if dInfo.Default then Select(dInfo.Default) end
            
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, v) Select(v) end
            itemObj.Refresh = function(self, newVals) Populate(newVals) end
            itemObj.GetValue = function() return DButton.Text end
            itemObj.SetTitle = function(self, newText) DTitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- MULTI-DROPDOWN
        function SectionObj:CreateMultiDropdown(dInfo)
            local DropdownFrame = Instance.new("Frame", SectionFrame)
            DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.ClipsDescendants = true
            local itemObj = {Frame = DropdownFrame, CleanTitle = dInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local DTitle = Instance.new("TextLabel", DropdownFrame)
            DTitle.Text = dInfo.Title
            DTitle.Font = Enum.Font.Gotham
            DTitle.TextSize = 12
            DTitle.BackgroundTransparency = 1
            DTitle.Size = UDim2.new(0.5, 0, 0, 30)
            DTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(DTitle, "TextColor3", "TextSecondary")

            local DButton = Instance.new("TextButton", DropdownFrame)
            DButton.Size = UDim2.new(0.5, 0, 0, 22)
            DButton.Position = UDim2.new(0.5, 0, 0, 4)
            DButton.Font = Enum.Font.Gotham
            DButton.TextSize = 11
            DButton.AutoButtonColor = false
            DButton.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", DButton).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(DButton, "BackgroundColor3", "ElementBg")
            We13ideLib:RegisterTheme(DButton, "TextColor3", "TextPrimary")

            local selected = type(dInfo.Default) == "table" and dInfo.Default or {}

            local function UpdateBtnText()
                if #selected == 0 then DButton.Text = "None Selected"
                elseif #selected == 1 then DButton.Text = tostring(selected[1])
                else DButton.Text = "Selected: " .. #selected end
            end
            UpdateBtnText()

            local DropScale = Instance.new("UIScale", DButton)
            DButton.MouseEnter:Connect(function() We13ideLib:Tween(DropScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
            DButton.MouseLeave:Connect(function() We13ideLib:Tween(DropScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
            DButton.MouseButton1Down:Connect(function() We13ideLib:Tween(DropScale, {Scale = 0.9}, 0.1, Enum.EasingStyle.Quad) end)
            DButton.MouseButton1Up:Connect(function() We13ideLib:Tween(DropScale, {Scale = 1.05}, 0.4, Enum.EasingStyle.Back) end)

            local ListFrame = Instance.new("Frame", DropdownFrame)
            ListFrame.Size = UDim2.new(0.5, 0, 0, 0)
            ListFrame.Position = UDim2.new(0.5, 0, 0, 30)
            Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
            local ListLayout = Instance.new("UIListLayout", ListFrame)
            We13ideLib:RegisterTheme(ListFrame, "BackgroundColor3", "ElementBg")

            local expanded = false

            local function Populate(newValues)
                for _, child in ipairs(ListFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, v in ipairs(newValues) do
                    local Item = Instance.new("TextButton", ListFrame)
                    Item.Size = UDim2.new(1, 0, 0, 20)
                    Item.BackgroundTransparency = 1
                    Item.Text = tostring(v)
                    Item.Font = Enum.Font.Gotham
                    Item.TextSize = 11
                    
                    local isSelected = table.find(selected, v) ~= nil
                    Item.TextColor3 = isSelected and We13ideLib.ActiveTheme.Accent or We13ideLib.ActiveTheme.TextSecondary
                    
                    Item.MouseEnter:Connect(function() We13ideLib:Tween(Item, {TextSize = 12}, 0.2, Enum.EasingStyle.Quad) end)
                    Item.MouseLeave:Connect(function() We13ideLib:Tween(Item, {TextSize = 11}, 0.2, Enum.EasingStyle.Quad) end)

                    Item.MouseButton1Click:Connect(function()
                        local idx = table.find(selected, v)
                        if idx then
                            table.remove(selected, idx)
                            We13ideLib:Tween(Item, {TextColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.3)
                        else
                            table.insert(selected, v)
                            We13ideLib:Tween(Item, {TextColor3 = We13ideLib.ActiveTheme.Accent}, 0.3)
                        end
                        UpdateBtnText()
                        if dInfo.Callback then task.spawn(dInfo.Callback, selected) end
                    end)
                end
            end
            
            Populate(dInfo.Values or {})

            DButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    local h = ListLayout.AbsoluteContentSize.Y
                    ListFrame.Size = UDim2.new(0.5, 0, 0, 0)
                    We13ideLib:Tween(ListFrame, {Size = UDim2.new(0.5, 0, 0, h)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    We13ideLib:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 30 + h)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    We13ideLib:Tween(ListFrame, {Size = UDim2.new(0.5, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    We13ideLib:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
            end)
            
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, valTable) selected = valTable; UpdateBtnText(); Populate(dInfo.Values or {}) end
            itemObj.Refresh = function(self, newVals) Populate(newVals) end
            itemObj.GetValue = function() return selected end
            itemObj.SetTitle = function(self, newText) DTitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- INPUT
        function SectionObj:CreateInput(iInfo)
            local InputFrame = Instance.new("Frame", SectionFrame)
            InputFrame.Size = UDim2.new(1, 0, 0, 30)
            InputFrame.BackgroundTransparency = 1
            local itemObj = {Frame = InputFrame, CleanTitle = iInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local ITitle = Instance.new("TextLabel", InputFrame)
            ITitle.Text = iInfo.Title
            ITitle.Font = Enum.Font.Gotham
            ITitle.TextSize = 12
            ITitle.BackgroundTransparency = 1
            ITitle.Size = UDim2.new(0.5, 0, 1, 0)
            ITitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(ITitle, "TextColor3", "TextSecondary")

            local TextBoxBg = Instance.new("Frame", InputFrame)
            TextBoxBg.Size = UDim2.new(0.5, 0, 0, 22)
            TextBoxBg.Position = UDim2.new(0.5, 0, 0.5, -11)
            Instance.new("UICorner", TextBoxBg).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(TextBoxBg, "BackgroundColor3", "ElementBg")

            local TextBox = Instance.new("TextBox", TextBoxBg)
            TextBox.Size = UDim2.new(1, -10, 1, 0)
            TextBox.Position = UDim2.new(0, 5, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Text = iInfo.Default or ""
            TextBox.PlaceholderText = iInfo.Placeholder or "Type here..."
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 11
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.ClearTextOnFocus = false
            We13ideLib:RegisterTheme(TextBox, "TextColor3", "TextPrimary")
            We13ideLib:RegisterTheme(TextBox, "PlaceholderColor3", "TextSecondary")

            local InputScale = Instance.new("UIScale", TextBoxBg)
            InputFrame.MouseEnter:Connect(function() We13ideLib:Tween(InputScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
            InputFrame.MouseLeave:Connect(function() We13ideLib:Tween(InputScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
            TextBox.Focused:Connect(function() We13ideLib:Tween(InputScale, {Scale = 1.08}, 0.4, Enum.EasingStyle.Back) end)

            TextBox.FocusLost:Connect(function()
                We13ideLib:Tween(InputScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back)
                if iInfo.Callback then task.spawn(iInfo.Callback, TextBox.Text) end
            end)
            
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, v) TextBox.Text = tostring(v) end
            itemObj.GetValue = function() return TextBox.Text end
            itemObj.SetTitle = function(self, newText) ITitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end

        -- COLOR PICKER
        function SectionObj:CreateColorPicker(cInfo)
            local CPFrame = Instance.new("Frame", SectionFrame)
            CPFrame.Size = UDim2.new(1, 0, 0, 30)
            CPFrame.BackgroundTransparency = 1
            CPFrame.ClipsDescendants = true
            local itemObj = {Frame = CPFrame, CleanTitle = cInfo.Title:lower():gsub("%s+",""), IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local CTitle = Instance.new("TextLabel", CPFrame)
            CTitle.Text = cInfo.Title
            CTitle.Font = Enum.Font.Gotham
            CTitle.TextSize = 12
            CTitle.BackgroundTransparency = 1
            CTitle.Size = UDim2.new(0.5, 0, 0, 30)
            CTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(CTitle, "TextColor3", "TextSecondary")

            local CBtn = Instance.new("TextButton", CPFrame)
            CBtn.Size = UDim2.new(0.5, 0, 0, 22)
            CBtn.Position = UDim2.new(0.5, 0, 0, 4)
            CBtn.Text = ""
            Instance.new("UICorner", CBtn).CornerRadius = UDim.new(0, 4)
            
            local defColor = cInfo.Default or Color3.new(1,1,1)
            CBtn.BackgroundColor3 = defColor

            local h, s, v = defColor:ToHSV()
            local expanded = false

            local ColorMapFrame = Instance.new("Frame", CPFrame)
            ColorMapFrame.Size = UDim2.new(1, 0, 0, 140)
            ColorMapFrame.Position = UDim2.new(0, 0, 0, 35)
            ColorMapFrame.BackgroundTransparency = 1

            local SVMap = Instance.new("Frame", ColorMapFrame)
            SVMap.Size = UDim2.new(1, 0, 1, -20)
            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Instance.new("UICorner", SVMap).CornerRadius = UDim.new(0, 4)
            
            local WhiteGrad = Instance.new("UIGradient", SVMap)
            WhiteGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
            WhiteGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            
            local BlackOverlay = Instance.new("Frame", SVMap)
            BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
            BlackOverlay.BackgroundColor3 = Color3.new(0,0,0)
            Instance.new("UICorner", BlackOverlay).CornerRadius = UDim.new(0, 4)
            local BlackGrad = Instance.new("UIGradient", BlackOverlay)
            BlackGrad.Rotation = 90
            BlackGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})

            local SVDot = Instance.new("Frame", BlackOverlay)
            SVDot.Size = UDim2.new(0, 10, 0, 10)
            SVDot.AnchorPoint = Vector2.new(0.5, 0.5)
            SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
            SVDot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", SVDot).CornerRadius = UDim.new(1, 0)
            local SVDotStroke = Instance.new("UIStroke", SVDot)
            SVDotStroke.Color = Color3.new(0,0,0)

            local HueStrip = Instance.new("Frame", ColorMapFrame)
            HueStrip.Size = UDim2.new(1, 0, 0, 12)
            HueStrip.Position = UDim2.new(0, 0, 1, -12)
            HueStrip.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", HueStrip).CornerRadius = UDim.new(0, 4)

            local HueGrad = Instance.new("UIGradient", HueStrip)
            HueGrad.Rotation = 0 
            local colors = {}
            for i = 0, 10 do table.insert(colors, ColorSequenceKeypoint.new(i/10, Color3.fromHSV(i/10, 1, 1))) end
            HueGrad.Color = ColorSequence.new(colors)

            local HueDot = Instance.new("Frame", HueStrip)
            HueDot.Size = UDim2.new(0, 6, 1, 4)
            HueDot.AnchorPoint = Vector2.new(0.5, 0.5)
            HueDot.Position = UDim2.new(h, 0, 0.5, 0)
            HueDot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", HueDot).CornerRadius = UDim.new(0, 2)
            local HueStroke = Instance.new("UIStroke", HueDot)
            HueStroke.Color = Color3.new(0,0,0)

            local function UpdateColor()
                local color = Color3.fromHSV(h, s, v)
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                CBtn.BackgroundColor3 = color
                if cInfo.Callback then task.spawn(cInfo.Callback, color) end
            end

            local draggingSV, draggingHue = false, false
            local function handleSV(input)
                s = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                We13ideLib:Tween(SVDot, {Position = UDim2.new(s, 0, 1 - v, 0)}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                UpdateColor()
            end

            local function handleHue(input)
                h = math.clamp((input.Position.X - HueStrip.AbsolutePosition.X) / HueStrip.AbsoluteSize.X, 0, 1)
                We13ideLib:Tween(HueDot, {Position = UDim2.new(h, 0, 0.5, 0)}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                UpdateColor()
            end

            SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true; handleSV(input) end end)
            HueStrip.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; handleHue(input) end end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingHue = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingSV then handleSV(input) elseif draggingHue then handleHue(input) end
                end
            end)

            CBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    We13ideLib:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 180)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    We13ideLib:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
            end)

            BindDestroy(itemObj)
            itemObj.SetValue = function(self, color) 
                h, s, v = color:ToHSV()
                SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                HueDot.Position = UDim2.new(h, 0, 0.5, 0)
                UpdateColor()
            end
            itemObj.SetTitle = function(self, newText) CTitle.Text = newText; self.CleanTitle = newText:lower():gsub("%s+","") end
            return itemObj
        end
    end

    function WindowObj:CreateTab(tabInfo, isPinned)
        local ParentFrame = isPinned and Sidebar or TabsContainer
        local TabBtn = Instance.new("TextButton", ParentFrame)
        TabBtn.Size = UDim2.new(1, 0, 0, 42)
        if isPinned then TabBtn.Position = UDim2.new(0, 0, 1, -50) end
        TabBtn.BackgroundTransparency = 1 
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 4
        We13ideLib:RegisterTheme(TabBtn, "BackgroundColor3", "Section")

        local TabScale = Instance.new("UIScale", TabBtn)

        local TabGlow = Instance.new("ImageLabel", TabBtn)
        TabGlow.Size = UDim2.new(1, 0, 1, 0)
        TabGlow.BackgroundTransparency = 1
        TabGlow.Image = "rbxassetid://5028857472"
        TabGlow.ScaleType = Enum.ScaleType.Slice
        TabGlow.SliceCenter = Rect.new(24, 24, 276, 276)
        TabGlow.ImageTransparency = 1
        TabGlow.ZIndex = 3
        We13ideLib:RegisterTheme(TabGlow, "ImageColor3", "Accent")

        local TabIcon = nil
        local resolvedIcon = We13ideLib:ResolveIcon(tabInfo.Icon, WindowName)
        if resolvedIcon ~= "" then
            TabIcon = Instance.new("ImageLabel", TabBtn)
            TabIcon.Size = UDim2.new(0, 18, 0, 18)
            TabIcon.Position = UDim2.new(0, 25, 0.5, -9)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = resolvedIcon
            TabIcon.ZIndex = 5
            We13ideLib:RegisterTheme(TabIcon, "ImageColor3", "TextSecondary")
        end

        local TabText = Instance.new("TextLabel", TabBtn)
        TabText.Size = UDim2.new(1, -60, 1, 0)
        TabText.Position = UDim2.new(0, TabIcon and 55 or 25, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabInfo.Title
        TabText.Font = Enum.Font.GothamMedium
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.ZIndex = 5
        We13ideLib:RegisterTheme(TabText, "TextColor3", "TextSecondary")

        local Page, PageScale, LeftCol, RightCol = CreatePageFrame()

        TabBtn.MouseEnter:Connect(function()
            if TabBtn.BackgroundTransparency > 0.6 then We13ideLib:Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.3, Enum.EasingStyle.Quad) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBtn.BackgroundTransparency > 0.6 then We13ideLib:Tween(TabBtn, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad) end
        end)

        local TabObj = {Page = Page, Btn = TabBtn, Text = TabText, Icon = TabIcon, Glow = TabGlow, Left = LeftCol, Right = RightCol, ToggleSide = false, Active = false, IsDestroyed = false}
        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:Destroy()
            if self.Btn then self.Btn:Destroy() end
            if self.Page then self.Page:Destroy() end
            self.IsDestroyed = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            if SearchPage.Visible then
                SearchPage.Visible = false
                SearchInput.Text = ""
            end

            TabScale.Scale = 0.9
            We13ideLib:Tween(TabScale, {Scale = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            for _, t in pairs(WindowObj.Tabs) do
                if not t.IsDestroyed then
                    t.Page.Visible = false
                    t.Active = false
                    We13ideLib:Tween(t.Btn, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
                    We13ideLib:Tween(t.Text, {TextColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.3, Enum.EasingStyle.Quad)
                    We13ideLib:Tween(t.Glow, {ImageTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
                    if t.Icon then We13ideLib:Tween(t.Icon, {ImageColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.3, Enum.EasingStyle.Quad) end
                end
            end
            
            Page.Visible = true
            TabObj.Active = true
            PageScale.Scale = 0.95
            We13ideLib:Tween(PageScale, {Scale = 1}, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

            We13ideLib:Tween(TabBtn, {BackgroundTransparency = 0.6}, 0.3, Enum.EasingStyle.Quad)
            We13ideLib:Tween(TabText, {TextColor3 = We13ideLib.ActiveTheme.TextPrimary}, 0.3, Enum.EasingStyle.Quad)
            We13ideLib:Tween(TabGlow, {ImageTransparency = 0.7}, 0.3, Enum.EasingStyle.Quad)
            if TabIcon then We13ideLib:Tween(TabIcon, {ImageColor3 = We13ideLib.ActiveTheme.Accent}, 0.3, Enum.EasingStyle.Quad) end
        end)
        
        if #WindowObj.Tabs == 1 and not isPinned then
            TabBtn.BackgroundTransparency = 0.6
            TabText.TextColor3 = We13ideLib.ActiveTheme.TextPrimary
            TabGlow.ImageTransparency = 0.7
            if TabIcon then TabIcon.ImageColor3 = We13ideLib.ActiveTheme.Accent end
            Page.Visible = true
            TabObj.Active = true
        end

        function TabObj:CreateSection(secInfo)
            local targetCol = self.ToggleSide and self.Right or self.Left
            self.ToggleSide = not self.ToggleSide

            local SectionFrame = Instance.new("Frame", targetCol)
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 8)
            SectionFrame.ClipsDescendants = true
            We13ideLib:RegisterTheme(SectionFrame, "BackgroundColor3", "Section")
            We13ideLib:RegisterTheme(SectionFrame, "BackgroundTransparency", "SectionTrans", true)

            local SecLayout = Instance.new("UIListLayout", SectionFrame)
            SecLayout.Padding = UDim.new(0, 8)

            local SecPadding = Instance.new("UIPadding", SectionFrame)
            SecPadding.PaddingTop = UDim.new(0, 12)
            SecPadding.PaddingBottom = UDim.new(0, 12)
            SecPadding.PaddingLeft = UDim.new(0, 15)
            SecPadding.PaddingRight = UDim.new(0, 15)

            local SecTitle = Instance.new("TextLabel", SectionFrame)
            SecTitle.Text = secInfo.Title
            SecTitle.Font = Enum.Font.GothamMedium
            SecTitle.TextSize = 13
            SecTitle.BackgroundTransparency = 1
            SecTitle.Size = UDim2.new(1, 0, 0, 15)
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(SecTitle, "TextColor3", "TextPrimary")

            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                We13ideLib:Tween(SectionFrame, {Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 24)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end)

            local SectionObj = { Frame = SectionFrame, OriginalParent = targetCol, CleanTitle = secInfo.Title:lower():gsub("%s+",""), Items = {}, IsDestroyed = false }
            if not secInfo.Unsearchable then
                table.insert(WindowObj.SearchableSections, SectionObj)
            end

            BuildSectionElements(SectionFrame, SectionObj)

            function SectionObj:SetTitle(newTitle)
                SecTitle.Text = newTitle
                self.CleanTitle = newTitle:lower():gsub("%s+","")
            end

            function SectionObj:Destroy()
                if self.Frame then self.Frame:Destroy() end
                self.IsDestroyed = true
                for _, i in pairs(self.Items) do i.IsDestroyed = true end
            end

            return SectionObj
        end
        return TabObj
    end

    -- ================= НАСТРОЙКИ (ЗАКРЕПЛЕННАЯ ВКЛАДКА) =================
    local SettingsTab = WindowObj:CreateTab({Title = "UI Settings", Icon = "rbxassetid://10734950309"}, true)
    
    local ThemeSec = SettingsTab:CreateSection({Title = "Theme Colors"})
    local function AddColorOpt(name, role)
        ThemeSec:CreateColorPicker({Title = name, Default = Theme[role], Callback = function(color)
            We13ideLib:UpdateTheme(role, color, false)
        end})
    end
    AddColorOpt("Main Background", "MainBackground")
    AddColorOpt("Sidebar", "Sidebar")
    AddColorOpt("Section", "Section")
    AddColorOpt("Accent", "Accent")
    AddColorOpt("Text Primary", "TextPrimary")
    AddColorOpt("Text Secondary", "TextSecondary")
    AddColorOpt("Element Background", "ElementBg")

    local TransSec = SettingsTab:CreateSection({Title = "UI Transparency"})
    TransSec:CreateSlider({Title = "Main Background", Min = 0, Max = 1, Default = Theme.MainTrans, Rounding = 0.05, Callback = function(val)
        We13ideLib:UpdateTheme("MainTrans", val, true)
    end})
    TransSec:CreateSlider({Title = "Section Background", Min = 0, Max = 1, Default = Theme.SectionTrans, Rounding = 0.05, Callback = function(val)
        We13ideLib:UpdateTheme("SectionTrans", val, true)
    end})

    local function LoadCfg(name)
        if readfile and isfile and isfile(ConfigPath .. "/" .. name .. ".json") then
            local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigPath .. "/" .. name .. ".json")) end)
            if success and decoded and decoded.Colors then
                for k, v in pairs(decoded.Colors) do
                    if type(v) == "table" and v[1] and v[2] and v[3] then
                        We13ideLib:UpdateTheme(k, Color3.new(v[1], v[2], v[3]), false)
                    elseif type(v) == "number" then
                        We13ideLib:UpdateTheme(k, v, true)
                    end
                end
            end
        end
    end

    local ConfigSec = SettingsTab:CreateSection({Title = "Config Manager"})
    local function GetConfigsList()
        local list = {}
        if listfiles then
            for _, file in ipairs(listfiles(ConfigPath)) do
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
        return #list > 0 and list or {"None"}
    end

    local ConfigDropdown = ConfigSec:CreateDropdown({Title = "Available Configs", Values = GetConfigsList()})
    
    ConfigSec:CreateButton({Title = "Refresh Configs List", Callback = function()
        ConfigDropdown:Refresh(GetConfigsList())
    end})

    local CfgNameInput = ConfigSec:CreateInput({Title = "Config Name", Placeholder = "my_theme"})

    ConfigSec:CreateButton({Title = "Save Config", Callback = function()
        if writefile then
            local name = CfgNameInput:GetValue()
            if name == "" then name = "default" end
            local saveColors = {}
            for k,v in pairs(We13ideLib.ActiveTheme) do
                if typeof(v) == "Color3" then
                    saveColors[k] = {v.R, v.G, v.B}
                else
                    saveColors[k] = v
                end
            end
            local data = HttpService:JSONEncode({Colors = saveColors})
            writefile(ConfigPath .. "/" .. name .. ".json", data)
            ConfigDropdown:Refresh(GetConfigsList())
            WindowObj:Notify({Title = "Config Saved", Content = "Saved " .. name .. ".json successfully!", Duration = 3})
        end
    end})

    ConfigSec:CreateButton({Title = "Load Config", Callback = function()
        local selected = ConfigDropdown:GetValue()
        if selected and selected ~= "None" and selected ~= "Select..." then
            LoadCfg(selected)
            WindowObj:Notify({Title = "Config Loaded", Content = "Loaded " .. selected .. " successfully!", Duration = 3})
        end
    end})

    local AutoLoadSec = SettingsTab:CreateSection({Title = "Auto-Load Settings"})
    local autoLoadFile = LibPath .. "/autoload.txt"
    local currentAuto = (readfile and isfile and isfile(autoLoadFile)) and readfile(autoLoadFile) or ""
    local isAutoLoad = currentAuto ~= ""

    AutoLoadSec:CreateToggle({Title = "Auto-Load Selected", Default = isAutoLoad, Callback = function(state)
        if writefile then
            if state then
                local selected = ConfigDropdown:GetValue()
                if selected and selected ~= "None" and selected ~= "Select..." then
                    writefile(autoLoadFile, selected)
                end
            else
                writefile(autoLoadFile, "")
            end
        end
    end})

    if isAutoLoad and currentAuto ~= "" then task.spawn(function() LoadCfg(currentAuto) end) end

    -- ================= КРАСИВОЕ CONFIRMATION MENU (JELLY BOUNCE) =================
    local isConfirming = false
    
    local ConfirmOverlay = Instance.new("Frame", ScreenGui)
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    ConfirmOverlay.BackgroundTransparency = 1
    ConfirmOverlay.ZIndex = 48
    ConfirmOverlay.Visible = false

    local ConfirmFrame = Instance.new("Frame", ScreenGui)
    ConfirmFrame.Size = UDim2.new(0, 340, 0, 170)
    ConfirmFrame.Position = UDim2.new(0.5, -170, 0.5, -85)
    ConfirmFrame.Visible = false
    ConfirmFrame.ZIndex = 50
    Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 12)
    We13ideLib:RegisterTheme(ConfirmFrame, "BackgroundColor3", "Section")
    
    local ConfirmStroke = Instance.new("UIStroke", ConfirmFrame)
    ConfirmStroke.Thickness = 1.5
    We13ideLib:RegisterTheme(ConfirmStroke, "Color", "Accent")

    local ConfirmScale = Instance.new("UIScale", ConfirmFrame)
    ConfirmScale.Scale = 0

    local ConfirmShadow = Instance.new("ImageLabel", ConfirmFrame)
    ConfirmShadow.Size = UDim2.new(1, 60, 1, 60)
    ConfirmShadow.Position = UDim2.new(0, -30, 0, -30)
    ConfirmShadow.BackgroundTransparency = 1
    ConfirmShadow.Image = "rbxassetid://5028857472"
    ConfirmShadow.ScaleType = Enum.ScaleType.Slice
    ConfirmShadow.SliceCenter = Rect.new(24, 24, 276, 276)
    ConfirmShadow.ImageTransparency = 0.4
    ConfirmShadow.ZIndex = 49
    We13ideLib:RegisterTheme(ConfirmShadow, "ImageColor3", "Accent")

    local ConfirmIcon = Instance.new("ImageLabel", ConfirmFrame)
    ConfirmIcon.Size = UDim2.new(0, 35, 0, 35)
    ConfirmIcon.Position = UDim2.new(0.5, -17.5, 0, 15)
    ConfirmIcon.BackgroundTransparency = 1
    ConfirmIcon.Image = "rbxassetid://10014844383" 
    ConfirmIcon.ZIndex = 51
    We13ideLib:RegisterTheme(ConfirmIcon, "ImageColor3", "Accent")

    local ConfirmTitle = Instance.new("TextLabel", ConfirmFrame)
    ConfirmTitle.Size = UDim2.new(1, 0, 0, 30)
    ConfirmTitle.Position = UDim2.new(0, 0, 0, 60)
    ConfirmTitle.BackgroundTransparency = 1
    ConfirmTitle.Text = "Do you want to close the cheat?"
    ConfirmTitle.Font = Enum.Font.GothamBold
    ConfirmTitle.TextSize = 15
    ConfirmTitle.ZIndex = 51
    We13ideLib:RegisterTheme(ConfirmTitle, "TextColor3", "TextPrimary")

    local YesBtn = Instance.new("TextButton", ConfirmFrame)
    YesBtn.Size = UDim2.new(0, 120, 0, 38)
    YesBtn.Position = UDim2.new(0.5, -130, 0.5, 25)
    YesBtn.Text = "YES, CLOSE"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 13
    YesBtn.AutoButtonColor = false
    YesBtn.ZIndex = 51
    Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)
    We13ideLib:RegisterTheme(YesBtn, "BackgroundColor3", "ElementBg")
    We13ideLib:RegisterTheme(YesBtn, "TextColor3", "Accent")
    local YesStroke = Instance.new("UIStroke", YesBtn)
    YesStroke.Thickness = 1
    We13ideLib:RegisterTheme(YesStroke, "Color", "Accent")
    local YesScale = Instance.new("UIScale", YesBtn)

    local NoBtn = Instance.new("TextButton", ConfirmFrame)
    NoBtn.Size = UDim2.new(0, 120, 0, 38)
    NoBtn.Position = UDim2.new(0.5, 10, 0.5, 25)
    NoBtn.Text = "CANCEL"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 13
    NoBtn.AutoButtonColor = false
    NoBtn.ZIndex = 51
    Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)
    We13ideLib:RegisterTheme(NoBtn, "BackgroundColor3", "ElementBg")
    We13ideLib:RegisterTheme(NoBtn, "TextColor3", "TextSecondary")
    local NoStroke = Instance.new("UIStroke", NoBtn)
    NoStroke.Thickness = 1
    We13ideLib:RegisterTheme(NoStroke, "Color", "TextSecondary")
    local NoScale = Instance.new("UIScale", NoBtn)

    YesBtn.MouseEnter:Connect(function() We13ideLib:Tween(YesBtn, {BackgroundColor3 = We13ideLib.ActiveTheme.MainBackground}, 0.2); We13ideLib:Tween(YesScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
    YesBtn.MouseLeave:Connect(function() We13ideLib:Tween(YesBtn, {BackgroundColor3 = We13ideLib.ActiveTheme.ElementBg}, 0.2); We13ideLib:Tween(YesScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
    YesBtn.MouseButton1Down:Connect(function() We13ideLib:Tween(YesScale, {Scale = 0.95}, 0.1) end)
    
    NoBtn.MouseEnter:Connect(function() We13ideLib:Tween(NoBtn, {BackgroundColor3 = We13ideLib.ActiveTheme.MainBackground}, 0.2); We13ideLib:Tween(NoScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back) end)
    NoBtn.MouseLeave:Connect(function() We13ideLib:Tween(NoBtn, {BackgroundColor3 = We13ideLib.ActiveTheme.ElementBg}, 0.2); We13ideLib:Tween(NoScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) end)
    NoBtn.MouseButton1Down:Connect(function() We13ideLib:Tween(NoScale, {Scale = 0.95}, 0.1) end)

    YesBtn.MouseButton1Click:Connect(function()
        We13ideLib:Tween(ConfirmOverlay, {BackgroundTransparency = 1}, 0.4)
        We13ideLib:Tween(MainScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        We13ideLib:Tween(ConfirmScale, {Scale = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)

    NoBtn.MouseButton1Click:Connect(function()
        We13ideLib:Tween(ConfirmOverlay, {BackgroundTransparency = 1}, 0.4)
        We13ideLib:Tween(ConfirmScale, {Scale = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
            ConfirmFrame.Visible = false
            ConfirmOverlay.Visible = false
            isConfirming = false
        end)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not WindowObj.IsLoaded then return end
        
        if input.KeyCode == Enum.KeyCode.RightShift then
            if isConfirming then return end
            isVisible = not isVisible
            if isVisible then
                MainFrame.Visible = true
                We13ideLib:Tween(MainScale, {Scale = 1}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                We13ideLib:Tween(MainScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
                    if not isVisible then MainFrame.Visible = false end
                end)
            end
        elseif input.KeyCode == Enum.KeyCode.RightAlt then
            if not isVisible or isConfirming then return end
            isConfirming = true
            ConfirmOverlay.Visible = true
            We13ideLib:Tween(ConfirmOverlay, {BackgroundTransparency = 0.5}, 0.4)
            ConfirmFrame.Visible = true
            ConfirmScale.Scale = 0.5
            We13ideLib:Tween(ConfirmScale, {Scale = 1}, 0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        end
    end)

    return WindowObj
end

return We13ideLib
