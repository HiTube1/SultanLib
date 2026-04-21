-- We13ideLib Source Code for Xeno Executor (Updated & Optimized)
-- Elite Neon Night UI, Glowing Tabs, Smart Search, Animated Stars, Configs, Notifications, Deletion
-- Тултипы, Саб-табы, Ресайз, Контекстные меню, Скроллбары, Редактор, Консоль, Вотермарка, Оптимизация

local We13ideLib = {
    Version = "3.0.0",
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
            MainTrans = 0.85,
            SectionTrans = 0
        }
    },
    ActiveTheme = nil,
    ThemedElements = {}
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
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

function We13ideLib:RegisterTheme(obj, prop, role, isTrans)
    isTrans = isTrans or false 
    table.insert(self.ThemedElements, {Obj = obj, Prop = prop, Role = role, IsTrans = isTrans})
    if isTrans then
        obj[prop] = self.ActiveTheme[role] or 0
    else
        obj[prop] = self.ActiveTheme[role] or Color3.new(1,1,1)
    end
end

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
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
    local resolvedLogo = We13ideLib:ResolveIcon(options.LogoIcon, WindowName)

    -- ================= ВОТЕРМАРКА (SPLASH И GLOBAL) =================
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
    if resolvedLogo ~= "" then SplashIcon.Image = resolvedLogo end
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

    local splashConnection
    splashConnection = RunService.RenderStepped:Connect(function(dt)
        if SplashIcon.Parent then
            SplashIcon.Rotation = SplashIcon.Rotation + (120 * dt)
        else
            splashConnection:Disconnect()
        end
    end)

    -- Static Watermark
    local WMFrame = Instance.new("Frame", ScreenGui)
    WMFrame.Size = UDim2.new(0, 220, 0, 30)
    WMFrame.Position = UDim2.new(0, 20, 0, 20)
    Instance.new("UICorner", WMFrame).CornerRadius = UDim.new(0, 6)
    self:RegisterTheme(WMFrame, "BackgroundColor3", "Section")
    local WMStroke = Instance.new("UIStroke", WMFrame)
    WMStroke.Thickness = 1.5
    self:RegisterTheme(WMStroke, "Color", "Accent")
    
    local WMIcon = Instance.new("ImageLabel", WMFrame)
    WMIcon.Size = UDim2.new(0, 18, 0, 18)
    WMIcon.Position = UDim2.new(0, 8, 0.5, -9)
    WMIcon.BackgroundTransparency = 1
    if resolvedLogo ~= "" then WMIcon.Image = resolvedLogo else WMIcon.Image = "rbxassetid://10014844383" end
    self:RegisterTheme(WMIcon, "ImageColor3", "Accent")

    local WMText = Instance.new("TextLabel", WMFrame)
    WMText.Size = UDim2.new(1, -35, 1, 0)
    WMText.Position = UDim2.new(0, 32, 0, 0)
    WMText.BackgroundTransparency = 1
    WMText.Font = Enum.Font.GothamBold
    WMText.TextSize = 12
    WMText.TextXAlignment = Enum.TextXAlignment.Left
    self:RegisterTheme(WMText, "TextColor3", "TextPrimary")

    RunService.RenderStepped:Connect(function(dt)
        WMIcon.Rotation = WMIcon.Rotation + (90 * dt)
        local fps = math.floor(1/dt)
        local ping = 0
        pcall(function() ping = string.split(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1] end)
        WMText.Text = "We13ideLib | FPS: " .. fps .. " | Ping: " .. (ping or 0) .. "ms"
    end)

    -- Tooltips
    local TooltipFrame = Instance.new("Frame", ScreenGui)
    TooltipFrame.Size = UDim2.new(0, 100, 0, 24)
    TooltipFrame.Visible = false
    TooltipFrame.ZIndex = 100
    Instance.new("UICorner", TooltipFrame).CornerRadius = UDim.new(0, 4)
    self:RegisterTheme(TooltipFrame, "BackgroundColor3", "ElementBg")
    local TooltipStroke = Instance.new("UIStroke", TooltipFrame)
    self:RegisterTheme(TooltipStroke, "Color", "Accent")
    
    local TooltipText = Instance.new("TextLabel", TooltipFrame)
    TooltipText.Size = UDim2.new(1, -10, 1, 0)
    TooltipText.Position = UDim2.new(0, 5, 0, 0)
    TooltipText.BackgroundTransparency = 1
    TooltipText.Font = Enum.Font.GothamMedium
    TooltipText.TextSize = 11
    self:RegisterTheme(TooltipText, "TextColor3", "TextPrimary")

    -- Context Menu
    local ContextMenu = Instance.new("Frame", ScreenGui)
    ContextMenu.Size = UDim2.new(0, 120, 0, 0)
    ContextMenu.Visible = false
    ContextMenu.ZIndex = 150
    ContextMenu.ClipsDescendants = true
    Instance.new("UICorner", ContextMenu).CornerRadius = UDim.new(0, 6)
    self:RegisterTheme(ContextMenu, "BackgroundColor3", "Section")
    local ContextStroke = Instance.new("UIStroke", ContextMenu)
    self:RegisterTheme(ContextStroke, "Color", "Accent")
    local ContextLayout = Instance.new("UIListLayout", ContextMenu)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ContextMenu.Visible = false
        end
    end)

    local function BindContextMenu(widget, actions)
        widget.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                for _, c in ipairs(ContextMenu:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                local y = 0
                for _, action in ipairs(actions) do
                    local btn = Instance.new("TextButton", ContextMenu)
                    btn.Size = UDim2.new(1, 0, 0, 24)
                    btn.BackgroundTransparency = 1
                    btn.Text = action.Name
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 11
                    self:RegisterTheme(btn, "TextColor3", "TextSecondary")
                    btn.MouseEnter:Connect(function() We13ideLib:Tween(btn, {TextColor3 = We13ideLib.ActiveTheme.Accent}, 0.2) end)
                    btn.MouseLeave:Connect(function() We13ideLib:Tween(btn, {TextColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.2) end)
                    btn.MouseButton1Click:Connect(function() action.Callback(); ContextMenu.Visible = false end)
                    y = y + 24
                end
                ContextMenu.Size = UDim2.new(0, 120, 0, y)
                ContextMenu.Position = UDim2.new(0, UserInputService:GetMouseLocation().X, 0, UserInputService:GetMouseLocation().Y - 36)
                ContextMenu.Visible = true
            end
        end)
    end

    local function ApplyTooltip(itemObj, widget, text)
        if not text or text == "" then return end
        table.insert(itemObj.Connections, widget.MouseEnter:Connect(function()
            TooltipText.Text = text
            TooltipFrame.Size = UDim2.new(0, TooltipText.TextBounds.X + 16, 0, 24)
            TooltipFrame.Visible = true
        end))
        table.insert(itemObj.Connections, widget.MouseLeave:Connect(function() TooltipFrame.Visible = false end))
        table.insert(itemObj.Connections, widget.MouseMoved:Connect(function(x, y)
            TooltipFrame.Position = UDim2.new(0, x + 15, 0, y + 15)
        end))
    end

    task.spawn(function()
        We13ideLib:Tween(SplashScale, {Scale = 1}, 0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        We13ideLib:Tween(SplashIcon, {ImageTransparency = 0}, 0.5)
        We13ideLib:Tween(SplashText, {TextTransparency = 0}, 0.5)
        task.wait(2.5) 
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
    end)
    
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
    
    -- Window Dragger
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < MainFrame.AbsolutePosition.Y + 60 and input.Position.X < MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X - 30 then
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; We13ideLib:Tween(MainScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
    end)

    -- Window Resizer
    local Resizer = Instance.new("TextButton", MainFrame)
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, -20, 1, -20)
    Resizer.BackgroundTransparency = 1
    Resizer.Text = "◢"
    Resizer.Font = Enum.Font.GothamBold
    Resizer.TextSize = 12
    Resizer.ZIndex = 50
    self:RegisterTheme(Resizer, "TextColor3", "TextSecondary")

    local resizing, resizeStart, sizeStart
    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; resizeStart = input.Position; sizeStart = MainFrame.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newX = math.clamp(sizeStart.X.Offset + delta.X, 600, 1200)
            local newY = math.clamp(sizeStart.Y.Offset + delta.Y, 400, 800)
            MainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.ZIndex = 2
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    self:RegisterTheme(Sidebar, "BackgroundColor3", "Sidebar")
    
    local HideCorner = Instance.new("Frame", Sidebar)
    HideCorner.Size = UDim2.new(0, 15, 1, 0)
    HideCorner.Position = UDim2.new(1, -15, 0, 0)
    HideCorner.BorderSizePixel = 0
    HideCorner.ZIndex = 2
    self:RegisterTheme(HideCorner, "BackgroundColor3", "Sidebar")

    local LogoIcon = Instance.new("ImageLabel", Sidebar)
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 20, 0, 20)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.ZIndex = 3
    if resolvedLogo ~= "" then LogoIcon.Image = resolvedLogo end
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

    local TabsContainer = Instance.new("ScrollingFrame", Sidebar)
    TabsContainer.Size = UDim2.new(1, 0, 1, -170)
    TabsContainer.Position = UDim2.new(0, 0, 0, 130)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.ScrollBarThickness = 3
    self:RegisterTheme(TabsContainer, "ScrollBarImageColor3", "Accent")
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

    local SearchInput = Instance.new("TextBox", SearchBoxBg)
    SearchInput.Size = UDim2.new(1, -35, 1, 0)
    SearchInput.Position = UDim2.new(0, 30, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.PlaceholderText = "Search features..."
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    self:RegisterTheme(SearchInput, "TextColor3", "TextPrimary")

    local PagesContainer = Instance.new("Frame", MainFrame)
    PagesContainer.Size = UDim2.new(1, -220, 1, -60)
    PagesContainer.Position = UDim2.new(0, 220, 0, 60)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ZIndex = 2

    -- Notifications System
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
        local NFrame = Instance.new("Frame", NotifContainer)
        NFrame.Size = UDim2.new(1, 0, 0, 60)
        NFrame.Position = UDim2.new(1, 300, 0, 0)
        Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 8)
        We13ideLib:RegisterTheme(NFrame, "BackgroundColor3", "ElementBg")
        local NScale = Instance.new("UIScale", NFrame)
        NScale.Scale = 0.5
        local NTitleLabel = Instance.new("TextLabel", NFrame)
        NTitleLabel.Size = UDim2.new(1, -20, 0, 20)
        NTitleLabel.Position = UDim2.new(0, 10, 0, 10)
        NTitleLabel.BackgroundTransparency = 1
        NTitleLabel.Text = nInfo.Title or "Notification"
        NTitleLabel.Font = Enum.Font.GothamBold
        NTitleLabel.TextSize = 13
        NTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        We13ideLib:RegisterTheme(NTitleLabel, "TextColor3", "TextPrimary")
        local NContentLabel = Instance.new("TextLabel", NFrame)
        NContentLabel.Size = UDim2.new(1, -20, 0, 20)
        NContentLabel.Position = UDim2.new(0, 10, 0, 30)
        NContentLabel.BackgroundTransparency = 1
        NContentLabel.Text = nInfo.Content or ""
        NContentLabel.Font = Enum.Font.Gotham
        NContentLabel.TextSize = 11
        NContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        We13ideLib:RegisterTheme(NContentLabel, "TextColor3", "TextSecondary")
        
        We13ideLib:Tween(NScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        We13ideLib:Tween(NFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.spawn(function()
            task.wait(nInfo.Duration or 3)
            if NFrame and NFrame.Parent then
                We13ideLib:Tween(NScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                We13ideLib:Tween(NFrame, {Position = UDim2.new(1, 300, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
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
            We13ideLib:Tween(MainScale, {Scale = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        end
    end

    local function CreatePageFrame(parent)
        local Page = Instance.new("ScrollingFrame", parent)
        Page.Size = UDim2.new(1, 0, 1, -20)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        We13ideLib:RegisterTheme(Page, "ScrollBarImageColor3", "Accent")
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
            We13ideLib:Tween(LeftCol, {Size = UDim2.new(0.5, -15, 0, LeftLayout.AbsoluteContentSize.Y)}, 0.4)
            We13ideLib:Tween(RightCol, {Size = UDim2.new(0.5, -15, 0, RightLayout.AbsoluteContentSize.Y)}, 0.4)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        return Page, PageScale, LeftCol, RightCol
    end

    local SearchPage, SearchPageScale, SearchLeftCol, SearchRightCol = CreatePageFrame(PagesContainer)
    SearchPage.Name = "GlobalSearchPage"

    local function BuildSectionElements(SectionFrame, SectionObj)
        local function BindDestroy(itemObj)
            function itemObj:Destroy()
                if self.Connections then
                    for _, c in pairs(self.Connections) do if c.Disconnect then c:Disconnect() end end
                end
                if self.Frame then self.Frame:Destroy() end
                self.IsDestroyed = true
            end
        end

        function SectionObj:CreateLabel(lInfo)
            local LabelFrame = Instance.new("Frame", SectionFrame)
            LabelFrame.Size = UDim2.new(1, 0, 0, 20)
            LabelFrame.BackgroundTransparency = 1
            local itemObj = {Frame = LabelFrame, CleanTitle = lInfo.Text:lower(), Connections = {}, IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local LText = Instance.new("TextLabel", LabelFrame)
            LText.Text = lInfo.Text
            LText.Font = Enum.Font.GothamMedium
            LText.TextSize = 12
            LText.BackgroundTransparency = 1
            LText.Size = UDim2.new(1, 0, 1, 0)
            LText.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(LText, "TextColor3", "TextSecondary")
            
            ApplyTooltip(itemObj, LabelFrame, lInfo.Tooltip)
            BindDestroy(itemObj)
            itemObj.SetText = function(self, newText) LText.Text = newText end
            return itemObj
        end

        function SectionObj:CreateButton(bInfo)
            local BtnFrame = Instance.new("Frame", SectionFrame)
            BtnFrame.Size = UDim2.new(1, 0, 0, 32)
            BtnFrame.BackgroundTransparency = 1
            local itemObj = {Frame = BtnFrame, CleanTitle = bInfo.Title:lower(), Connections = {}, IsDestroyed = false}
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
            table.insert(itemObj.Connections, Button.MouseEnter:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 1.03}, 0.3) end))
            table.insert(itemObj.Connections, Button.MouseLeave:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 1}, 0.3) end))
            table.insert(itemObj.Connections, Button.MouseButton1Down:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 0.92}, 0.1) end))
            table.insert(itemObj.Connections, Button.MouseButton1Up:Connect(function() We13ideLib:Tween(BtnScale, {Scale = 1.03}, 0.4) end))
            table.insert(itemObj.Connections, Button.MouseButton1Click:Connect(function() if bInfo.Callback then task.spawn(bInfo.Callback) end end))

            ApplyTooltip(itemObj, Button, bInfo.Tooltip)
            BindDestroy(itemObj)
            return itemObj
        end

        function SectionObj:CreateToggle(tInfo)
            local ToggleFrame = Instance.new("Frame", SectionFrame)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
            ToggleFrame.BackgroundTransparency = 1
            local itemObj = {Frame = ToggleFrame, CleanTitle = tInfo.Title:lower(), Connections = {}, IsDestroyed = false}
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

            local function Update()
                TCircle.Size = UDim2.new(0, 14, 0, 6)
                We13ideLib:Tween(TBtn, {BackgroundColor3 = state and We13ideLib.ActiveTheme.Accent or We13ideLib.ActiveTheme.ElementBg}, 0.3)
                We13ideLib:Tween(TCircle, {Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = state and Color3.new(1,1,1) or We13ideLib.ActiveTheme.TextSecondary, Size = UDim2.new(0, 10, 0, 10)}, 0.5)
                We13ideLib:Tween(TTitle, {TextColor3 = state and We13ideLib.ActiveTheme.TextPrimary or We13ideLib.ActiveTheme.TextSecondary}, 0.3)
                if tInfo.Callback then task.spawn(tInfo.Callback, state) end
            end

            table.insert(itemObj.Connections, TBtn.MouseButton1Click:Connect(function() state = not state; Update() end))
            Update()
            
            ApplyTooltip(itemObj, ToggleFrame, tInfo.Tooltip)
            BindContextMenu(ToggleFrame, {{Name = "Reset", Callback = function() state = tInfo.Default or false; Update() end}})
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, val) state = val; Update() end
            return itemObj
        end

        function SectionObj:CreateSlider(sInfo)
            local SliderFrame = Instance.new("Frame", SectionFrame)
            SliderFrame.Size = UDim2.new(1, 0, 0, 24)
            SliderFrame.BackgroundTransparency = 1
            local itemObj = {Frame = SliderFrame, CleanTitle = sInfo.Title:lower(), Connections = {}, IsDestroyed = false}
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

            local min, max, val, rounding = sInfo.Min or 0, sInfo.Max or 100, sInfo.Default or 0, sInfo.Rounding or 1

            local function SetValue(v)
                val = math.clamp(math.round(v / rounding) * rounding, min, max)
                local percent = (val - min) / (max - min)
                We13ideLib:Tween(SFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.2)
                We13ideLib:Tween(SCircle, {Position = UDim2.new(percent, -4, 0.5, -4)}, 0.2)
                local fmtStr = string.find(tostring(rounding), "%.") and string.format("%%.%df", string.len(tostring(rounding):match("%.(%d+)"))) or "%d"
                SValue.Text = string.format(fmtStr, val)
                if sInfo.Callback then task.spawn(sInfo.Callback, val) end
            end

            local isDragging = false
            table.insert(itemObj.Connections, SBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    We13ideLib:Tween(SCircle, {Size = UDim2.new(0,14,0,14), Position = UDim2.new(SCircle.Position.X.Scale, -7, 0.5, -7)}, 0.4)
                end
            end))
            table.insert(itemObj.Connections, UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
                    isDragging = false
                    We13ideLib:Tween(SCircle, {Size = UDim2.new(0,8,0,8), Position = UDim2.new(SCircle.Position.X.Scale, -4, 0.5, -4)}, 0.4)
                end
            end))
            table.insert(itemObj.Connections, UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((UserInputService:GetMouseLocation().X - STrack.AbsolutePosition.X) / STrack.AbsoluteSize.X, 0, 1)
                    SetValue(min + ((max - min) * percent))
                end
            end))

            SetValue(val)
            ApplyTooltip(itemObj, SliderFrame, sInfo.Tooltip)
            BindContextMenu(SliderFrame, {{Name = "Reset", Callback = function() SetValue(sInfo.Default or min) end}, {Name = "Max", Callback = function() SetValue(max) end}})
            BindDestroy(itemObj)
            itemObj.SetValue = function(self, v) SetValue(v) end
            return itemObj
        end

        function SectionObj:CreateKeybind(kInfo)
            local KeybindFrame = Instance.new("Frame", SectionFrame)
            KeybindFrame.Size = UDim2.new(1, 0, 0, 30)
            KeybindFrame.BackgroundTransparency = 1
            local itemObj = {Frame = KeybindFrame, CleanTitle = kInfo.Title:lower(), Connections = {}, IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local KTitle = Instance.new("TextLabel", KeybindFrame)
            KTitle.Text = kInfo.Title
            KTitle.Font = Enum.Font.Gotham
            KTitle.TextSize = 12
            KTitle.BackgroundTransparency = 1
            KTitle.Size = UDim2.new(0.5, 0, 1, 0)
            KTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(KTitle, "TextColor3", "TextSecondary")

            local KBtn = Instance.new("TextButton", KeybindFrame)
            KBtn.Size = UDim2.new(0.3, 0, 0, 22)
            KBtn.Position = UDim2.new(0.7, 0, 0.5, -11)
            KBtn.Text = "[ " .. (kInfo.Default and kInfo.Default.Name or "None") .. " ]"
            KBtn.Font = Enum.Font.GothamMedium
            KBtn.TextSize = 11
            KBtn.AutoButtonColor = false
            Instance.new("UICorner", KBtn).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(KBtn, "BackgroundColor3", "ElementBg")
            We13ideLib:RegisterTheme(KBtn, "TextColor3", "Accent")

            local ModeBtn = Instance.new("TextButton", KeybindFrame)
            ModeBtn.Size = UDim2.new(0.18, 0, 0, 22)
            ModeBtn.Position = UDim2.new(0.5, 0, 0.5, -11)
            ModeBtn.Text = "Toggle"
            ModeBtn.Font = Enum.Font.Gotham
            ModeBtn.TextSize = 10
            ModeBtn.AutoButtonColor = false
            Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(ModeBtn, "BackgroundColor3", "ElementBg")
            We13ideLib:RegisterTheme(ModeBtn, "TextColor3", "TextSecondary")

            local binding = false
            local currentKey = kInfo.Default
            local modes = {"Toggle", "Hold", "Always"}
            local currentModeIdx = 1
            local holdActive = false

            table.insert(itemObj.Connections, ModeBtn.MouseButton1Click:Connect(function()
                currentModeIdx = currentModeIdx >= #modes and 1 or (currentModeIdx + 1)
                ModeBtn.Text = modes[currentModeIdx]
            end))

            table.insert(itemObj.Connections, KBtn.MouseButton1Click:Connect(function()
                binding = true
                KBtn.Text = "[ ... ]"
            end))

            table.insert(itemObj.Connections, UserInputService.InputBegan:Connect(function(input, gp)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    currentKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or nil
                    KBtn.Text = "[ " .. (currentKey and currentKey.Name or "None") .. " ]"
                    if kInfo.KeyChangedCallback then task.spawn(kInfo.KeyChangedCallback, currentKey) end
                elseif not binding and currentKey and input.KeyCode == currentKey and not gp then
                    local mode = modes[currentModeIdx]
                    if mode == "Toggle" or mode == "Always" then
                        if kInfo.Callback then task.spawn(kInfo.Callback, currentKey, mode, true) end
                    elseif mode == "Hold" then
                        holdActive = true
                        if kInfo.Callback then task.spawn(kInfo.Callback, currentKey, mode, true) end
                    end
                end
            end))

            table.insert(itemObj.Connections, UserInputService.InputEnded:Connect(function(input, gp)
                if not binding and currentKey and input.KeyCode == currentKey and not gp then
                    if modes[currentModeIdx] == "Hold" and holdActive then
                        holdActive = false
                        if kInfo.Callback then task.spawn(kInfo.Callback, currentKey, "Hold", false) end
                    end
                end
            end))

            ApplyTooltip(itemObj, KeybindFrame, kInfo.Tooltip)
            BindDestroy(itemObj)
            return itemObj
        end

        function SectionObj:CreateColorPicker(cInfo)
            local CPFrame = Instance.new("Frame", SectionFrame)
            CPFrame.Size = UDim2.new(1, 0, 0, 30)
            CPFrame.BackgroundTransparency = 1
            CPFrame.ClipsDescendants = true
            local itemObj = {Frame = CPFrame, CleanTitle = cInfo.Title:lower(), Connections = {}, IsDestroyed = false}
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
            ColorMapFrame.Size = UDim2.new(1, 0, 0, 160)
            ColorMapFrame.Position = UDim2.new(0, 0, 0, 35)
            ColorMapFrame.BackgroundTransparency = 1

            local SVMap = Instance.new("Frame", ColorMapFrame)
            SVMap.Size = UDim2.new(1, 0, 1, -40)
            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Instance.new("UICorner", SVMap).CornerRadius = UDim.new(0, 4)
            local WhiteGrad = Instance.new("UIGradient", SVMap)
            WhiteGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
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

            local HueStrip = Instance.new("Frame", ColorMapFrame)
            HueStrip.Size = UDim2.new(1, 0, 0, 12)
            HueStrip.Position = UDim2.new(0, 0, 1, -34)
            Instance.new("UICorner", HueStrip).CornerRadius = UDim.new(0, 4)
            local HueGrad = Instance.new("UIGradient", HueStrip)
            local colors = {}
            for i = 0, 10 do table.insert(colors, ColorSequenceKeypoint.new(i/10, Color3.fromHSV(i/10, 1, 1))) end
            HueGrad.Color = ColorSequence.new(colors)

            local HueDot = Instance.new("Frame", HueStrip)
            HueDot.Size = UDim2.new(0, 6, 1, 4)
            HueDot.AnchorPoint = Vector2.new(0.5, 0.5)
            HueDot.Position = UDim2.new(h, 0, 0.5, 0)
            HueDot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", HueDot).CornerRadius = UDim.new(0, 2)

            local HexBg = Instance.new("Frame", ColorMapFrame)
            HexBg.Size = UDim2.new(1, 0, 0, 20)
            HexBg.Position = UDim2.new(0, 0, 1, -20)
            Instance.new("UICorner", HexBg).CornerRadius = UDim.new(0, 4)
            We13ideLib:RegisterTheme(HexBg, "BackgroundColor3", "ElementBg")
            local HexInput = Instance.new("TextBox", HexBg)
            HexInput.Size = UDim2.new(1, -10, 1, 0)
            HexInput.Position = UDim2.new(0, 5, 0, 0)
            HexInput.BackgroundTransparency = 1
            HexInput.Font = Enum.Font.Gotham
            HexInput.TextSize = 11
            HexInput.TextXAlignment = Enum.TextXAlignment.Left
            HexInput.Text = "#" .. defColor:ToHex()
            We13ideLib:RegisterTheme(HexInput, "TextColor3", "TextPrimary")

            local function UpdateColor()
                local color = Color3.fromHSV(h, s, v)
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                CBtn.BackgroundColor3 = color
                HexInput.Text = "#" .. color:ToHex()
                if cInfo.Callback then task.spawn(cInfo.Callback, color) end
            end

            table.insert(itemObj.Connections, HexInput.FocusLost:Connect(function()
                local success, color = pcall(function() return Color3.fromHex(HexInput.Text:gsub("#", "")) end)
                if success then
                    h, s, v = color:ToHSV()
                    SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueDot.Position = UDim2.new(h, 0, 0.5, 0)
                    UpdateColor()
                end
            end))

            local draggingSV, draggingHue = false, false
            local function handleSV(input)
                s = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                We13ideLib:Tween(SVDot, {Position = UDim2.new(s, 0, 1 - v, 0)}, 0.05)
                UpdateColor()
            end
            local function handleHue(input)
                h = math.clamp((input.Position.X - HueStrip.AbsolutePosition.X) / HueStrip.AbsoluteSize.X, 0, 1)
                We13ideLib:Tween(HueDot, {Position = UDim2.new(h, 0, 0.5, 0)}, 0.05)
                UpdateColor()
            end

            table.insert(itemObj.Connections, SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true; handleSV(input) end end))
            table.insert(itemObj.Connections, HueStrip.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; handleHue(input) end end))
            table.insert(itemObj.Connections, UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingHue = false end end))
            table.insert(itemObj.Connections, UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingSV then handleSV(input) elseif draggingHue then handleHue(input) end
                end
            end))

            table.insert(itemObj.Connections, CBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                We13ideLib:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, expanded and 200 or 30)}, 0.5)
            end))

            ApplyTooltip(itemObj, CPFrame, cInfo.Tooltip)
            BindDestroy(itemObj)
            return itemObj
        end

        function SectionObj:CreateEditor(eInfo)
            local EdFrame = Instance.new("Frame", SectionFrame)
            EdFrame.Size = UDim2.new(1, 0, 0, eInfo.Height or 150)
            EdFrame.BackgroundTransparency = 1
            local itemObj = {Frame = EdFrame, CleanTitle = "editor", Connections = {}, IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local EdBg = Instance.new("Frame", EdFrame)
            EdBg.Size = UDim2.new(1, 0, 1, 0)
            Instance.new("UICorner", EdBg).CornerRadius = UDim.new(0, 6)
            We13ideLib:RegisterTheme(EdBg, "BackgroundColor3", "ElementBg")

            local LineScroller = Instance.new("ScrollingFrame", EdBg)
            LineScroller.Size = UDim2.new(0, 30, 1, -10)
            LineScroller.Position = UDim2.new(0, 5, 0, 5)
            LineScroller.BackgroundTransparency = 1
            LineScroller.ScrollBarThickness = 0
            
            local LineText = Instance.new("TextLabel", LineScroller)
            LineText.Size = UDim2.new(1, 0, 1, 0)
            LineText.BackgroundTransparency = 1
            LineText.Font = Enum.Font.Code
            LineText.TextSize = 12
            LineText.Text = "1"
            LineText.TextYAlignment = Enum.TextYAlignment.Top
            LineText.TextXAlignment = Enum.TextXAlignment.Right
            We13ideLib:RegisterTheme(LineText, "TextColor3", "TextSecondary")

            local TextScroller = Instance.new("ScrollingFrame", EdBg)
            TextScroller.Size = UDim2.new(1, -45, 1, -10)
            TextScroller.Position = UDim2.new(0, 40, 0, 5)
            TextScroller.BackgroundTransparency = 1
            TextScroller.ScrollBarThickness = 3
            We13ideLib:RegisterTheme(TextScroller, "ScrollBarImageColor3", "Accent")

            local TextBox = Instance.new("TextBox", TextScroller)
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.MultiLine = true
            TextBox.ClearTextOnFocus = false
            TextBox.Font = Enum.Font.Code
            TextBox.TextSize = 12
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.TextYAlignment = Enum.TextYAlignment.Top
            TextBox.Text = eInfo.Default or ""
            We13ideLib:RegisterTheme(TextBox, "TextColor3", "TextPrimary")

            table.insert(itemObj.Connections, TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local _, count = TextBox.Text:gsub("\n", "")
                local lines = ""
                for i = 1, count + 1 do lines = lines .. i .. "\n" end
                LineText.Text = lines
                TextBox.Size = UDim2.new(1, 0, 0, (count + 1) * 14)
                LineText.Size = UDim2.new(1, 0, 0, (count + 1) * 14)
                TextScroller.CanvasSize = UDim2.new(0, 0, 0, (count + 1) * 14)
                LineScroller.CanvasSize = UDim2.new(0, 0, 0, (count + 1) * 14)
            end))

            table.insert(itemObj.Connections, TextScroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                LineScroller.CanvasPosition = TextScroller.CanvasPosition
            end))

            BindDestroy(itemObj)
            itemObj.GetValue = function() return TextBox.Text end
            return itemObj
        end

        function SectionObj:CreateConsole(cInfo)
            local ConFrame = Instance.new("Frame", SectionFrame)
            ConFrame.Size = UDim2.new(1, 0, 0, cInfo.Height or 150)
            ConFrame.BackgroundTransparency = 1
            local itemObj = {Frame = ConFrame, CleanTitle = "console", Connections = {}, IsDestroyed = false}
            table.insert(self.Items, itemObj)

            local ConBg = Instance.new("Frame", ConFrame)
            ConBg.Size = UDim2.new(1, 0, 1, 0)
            Instance.new("UICorner", ConBg).CornerRadius = UDim.new(0, 6)
            We13ideLib:RegisterTheme(ConBg, "BackgroundColor3", "ElementBg")

            local Scroller = Instance.new("ScrollingFrame", ConBg)
            Scroller.Size = UDim2.new(1, -10, 1, -10)
            Scroller.Position = UDim2.new(0, 5, 0, 5)
            Scroller.BackgroundTransparency = 1
            Scroller.ScrollBarThickness = 3
            We13ideLib:RegisterTheme(Scroller, "ScrollBarImageColor3", "Accent")
            
            local ConLayout = Instance.new("UIListLayout", Scroller)
            ConLayout.SortOrder = Enum.SortOrder.LayoutOrder

            table.insert(itemObj.Connections, ConLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Scroller.CanvasSize = UDim2.new(0, 0, 0, ConLayout.AbsoluteContentSize.Y)
                Scroller.CanvasPosition = Vector2.new(0, ConLayout.AbsoluteContentSize.Y)
            end))

            BindDestroy(itemObj)
            itemObj.Log = function(self, text, color)
                local msg = Instance.new("TextLabel", Scroller)
                msg.Size = UDim2.new(1, 0, 0, 14)
                msg.BackgroundTransparency = 1
                msg.Font = Enum.Font.Code
                msg.TextSize = 11
                msg.TextXAlignment = Enum.TextXAlignment.Left
                msg.Text = "[LOG] " .. text
                if color then msg.TextColor3 = color else We13ideLib:RegisterTheme(msg, "TextColor3", "TextPrimary") end
            end
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
        TabBtn.ZIndex = 4

        local TabGlow = Instance.new("ImageLabel", TabBtn)
        TabGlow.Size = UDim2.new(1, 0, 1, 0)
        TabGlow.BackgroundTransparency = 1
        TabGlow.Image = "rbxassetid://5028857472"
        TabGlow.ScaleType = Enum.ScaleType.Slice
        TabGlow.SliceCenter = Rect.new(24, 24, 276, 276)
        TabGlow.ImageTransparency = 1
        We13ideLib:RegisterTheme(TabGlow, "ImageColor3", "Accent")

        local resolvedIcon = We13ideLib:ResolveIcon(tabInfo.Icon, WindowName)
        local TabIcon
        if resolvedIcon ~= "" then
            TabIcon = Instance.new("ImageLabel", TabBtn)
            TabIcon.Size = UDim2.new(0, 18, 0, 18)
            TabIcon.Position = UDim2.new(0, 25, 0.5, -9)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = resolvedIcon
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
        We13ideLib:RegisterTheme(TabText, "TextColor3", "TextSecondary")

        local Page, PageScale, LeftCol, RightCol = CreatePageFrame(PagesContainer)

        local TabObj = {Page = Page, Btn = TabBtn, Text = TabText, Icon = TabIcon, Glow = TabGlow, Left = LeftCol, Right = RightCol, ToggleSide = false, Active = false, IsDestroyed = false, HasSubTabs = false, SubTabs = {}}
        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:Destroy()
            if self.Btn then self.Btn:Destroy() end
            if self.Page then self.Page:Destroy() end
            self.IsDestroyed = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            if SearchPage.Visible then SearchPage.Visible = false; SearchInput.Text = "" end
            for _, t in pairs(WindowObj.Tabs) do
                if not t.IsDestroyed then
                    t.Page.Visible = false; t.Active = false
                    We13ideLib:Tween(t.Btn, {BackgroundTransparency = 1}, 0.3)
                    We13ideLib:Tween(t.Text, {TextColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.3)
                    We13ideLib:Tween(t.Glow, {ImageTransparency = 1}, 0.3)
                    if t.Icon then We13ideLib:Tween(t.Icon, {ImageColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.3) end
                end
            end
            Page.Visible = true; TabObj.Active = true
            We13ideLib:Tween(TabBtn, {BackgroundTransparency = 0.6}, 0.3)
            We13ideLib:Tween(TabText, {TextColor3 = We13ideLib.ActiveTheme.TextPrimary}, 0.3)
            We13ideLib:Tween(TabGlow, {ImageTransparency = 0.7}, 0.3)
            if TabIcon then We13ideLib:Tween(TabIcon, {ImageColor3 = We13ideLib.ActiveTheme.Accent}, 0.3) end
        end)
        
        if #WindowObj.Tabs == 1 and not isPinned then TabBtn.BackgroundTransparency = 0.6; TabText.TextColor3 = We13ideLib.ActiveTheme.TextPrimary; TabGlow.ImageTransparency = 0.7; if TabIcon then TabIcon.ImageColor3 = We13ideLib.ActiveTheme.Accent end; Page.Visible = true; TabObj.Active = true end

        -- SubTabs Feature
        function TabObj:CreateSubTab(stInfo)
            if not self.HasSubTabs then
                self.HasSubTabs = true
                self.Left:Destroy() self.Right:Destroy()
                
                self.SubTabTop = Instance.new("Frame", self.Page)
                self.SubTabTop.Size = UDim2.new(1, -30, 0, 36)
                self.SubTabTop.BackgroundTransparency = 1
                
                local STLayout = Instance.new("UIListLayout", self.SubTabTop)
                STLayout.FillDirection = Enum.FillDirection.Horizontal
                STLayout.Padding = UDim.new(0, 10)
                
                self.SubPages = Instance.new("Frame", self.Page)
                self.SubPages.Size = UDim2.new(1, 0, 1, -40)
                self.SubPages.BackgroundTransparency = 1
            end

            local STBtn = Instance.new("TextButton", self.SubTabTop)
            STBtn.Size = UDim2.new(0, 120, 1, 0)
            STBtn.Text = stInfo.Title
            STBtn.Font = Enum.Font.GothamMedium
            STBtn.TextSize = 12
            Instance.new("UICorner", STBtn).CornerRadius = UDim.new(0, 6)
            We13ideLib:RegisterTheme(STBtn, "BackgroundColor3", "Section")
            We13ideLib:RegisterTheme(STBtn, "TextColor3", "TextSecondary")

            local SPage, SScale, SLeft, SRight = CreatePageFrame(self.SubPages)
            SPage.Size = UDim2.new(1, 0, 1, 0)

            local SubTabObj = {Btn = STBtn, Page = SPage, Left = SLeft, Right = SRight, ToggleSide = false, IsDestroyed = false}
            table.insert(self.SubTabs, SubTabObj)

            STBtn.MouseButton1Click:Connect(function()
                for _, st in pairs(self.SubTabs) do
                    st.Page.Visible = false
                    We13ideLib:Tween(st.Btn, {TextColor3 = We13ideLib.ActiveTheme.TextSecondary}, 0.3)
                end
                SPage.Visible = true
                We13ideLib:Tween(STBtn, {TextColor3 = We13ideLib.ActiveTheme.Accent}, 0.3)
            end)

            if #self.SubTabs == 1 then SPage.Visible = true; STBtn.TextColor3 = We13ideLib.ActiveTheme.Accent end

            function SubTabObj:CreateSection(secInfo)
                return TabObj.CreateSection(self, secInfo) 
            end
            return SubTabObj
        end

        function TabObj:CreateSection(secInfo)
            local targetCol = self.ToggleSide and self.Right or self.Left
            self.ToggleSide = not self.ToggleSide

            local SectionFrame = Instance.new("Frame", targetCol)
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 8)
            SectionFrame.ClipsDescendants = true
            We13ideLib:RegisterTheme(SectionFrame, "BackgroundColor3", "Section")

            local SecLayout = Instance.new("UIListLayout", SectionFrame)
            SecLayout.Padding = UDim.new(0, 8)
            local SecPadding = Instance.new("UIPadding", SectionFrame)
            SecPadding.PaddingTop = UDim.new(0, 12); SecPadding.PaddingBottom = UDim.new(0, 12); SecPadding.PaddingLeft = UDim.new(0, 15); SecPadding.PaddingRight = UDim.new(0, 15)

            local SecTitle = Instance.new("TextLabel", SectionFrame)
            SecTitle.Text = secInfo.Title
            SecTitle.Font = Enum.Font.GothamMedium
            SecTitle.TextSize = 13
            SecTitle.BackgroundTransparency = 1
            SecTitle.Size = UDim2.new(1, 0, 0, 15)
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            We13ideLib:RegisterTheme(SecTitle, "TextColor3", "TextPrimary")

            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                We13ideLib:Tween(SectionFrame, {Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 24)}, 0.5)
            end)

            local SectionObj = { Frame = SectionFrame, OriginalParent = targetCol, CleanTitle = secInfo.Title:lower(), Items = {}, IsDestroyed = false }
            table.insert(WindowObj.SearchableSections, SectionObj)
            BuildSectionElements(SectionFrame, SectionObj)
            
            function SectionObj:Destroy()
                for _, i in pairs(self.Items) do i:Destroy() end
                if self.Frame then self.Frame:Destroy() end
                self.IsDestroyed = true
            end

            return SectionObj
        end
        return TabObj
    end

    return WindowObj
end

return We13ideLib
