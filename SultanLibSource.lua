-- SultanLib v5 - Nursultan Minecraft Style 2025

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SultanLib_Nursultan"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(80, 120, 255)
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 180, 255))
}
Gradient.Rotation = 90
Gradient.Parent = MainStroke

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "SultanLib — Nursultan Edition"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = MainFrame

-- Контейнер вкладок
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 50)
TabButtons.Position = UDim2.new(0, 0, 0, 50)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -100)
ContentFrame.Position = UDim2.new(0, 0, 0, 100)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Tabs = {}
local CurrentTab = nil

local function CreateTab(Name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Button.Text = Name
    Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 16
    Button.Parent = TabButtons
    Button.Position = UDim2.new(0, (#TabButtons:GetChildren() - 2) * 122, 0, 0)

    local Corner = Instance.new("UICorner", Button)
    Corner.CornerRadius = UDim.new(0, 8)

    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.Visible = false
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Parent = ContentFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Content

    Button.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = Content
        Content.Visible = true
        for _, btn in pairs(TabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        Button.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
        Button.TextColor3 = Color3.new(1,1,1)
    end)

    local Tab = {}

    function Tab:Button(Name, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -20, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        Btn.Text = "  " .. Name
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.Gotham
        Btn.TextXAlignment = "Left"
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        Btn.MouseButton1Click:Connect(Callback or function() end)
        Content.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
    end

    function Tab:Toggle(Name, Default, Callback)
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(1, -20, 0, 40)
        Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        Toggle.Text = "  " .. Name
        Toggle.TextColor3 = Color3.new(1,1,1)
        Toggle.Font = Enum.Font.Gotham
        Toggle.TextXAlignment = "Left"
        Toggle.Parent = Content

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 30, 0, 16)
        Indicator.Position = UDim2.new(1, -40, 0.5, -8)
        Indicator.BackgroundColor3 = Default and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 60)
        Indicator.Parent = Toggle
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 8)

        local state = Default or false
        Toggle.MouseButton1Click:Connect(function()
            state = not state
            Indicator.BackgroundColor3 = state and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 60)
            if Callback then Callback(state) end
        end)

        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
        Content.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
    end

    function Tab:Slider(Name, Min, Max, Default, Callback)
        -- можно добавить слайдер (по желанию)
    end

    table.insert(Tabs, {Button = Button, Content = Content})
    return Tab
end

-- Драг
local Drag = Instance.new("Frame")
Drag.Size = UDim2.new(1,0,0,50)
Drag.BackgroundTransparency = 1
Drag.Parent = MainFrame
local dragging = false
local startPos
Drag.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = MainFrame.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end
Drag.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - (i.Position - MainFrame.Position) wait() -- фикс
        MainFrame.Position = UDim2.new(0, startPos.X.Offset + (i.Position.X - startPos.X.Offset), 0, startPos.Y.Offset + (i.Position.Y - startPos.Y.Offset))
    end
end)

local SultanLib = {}
function SultanLib:Tab(Name) return CreateTab(Name) end

-- Авто-открытие первой вкладки
task.spawn(function()
    task.wait(0.5)
    if #Tabs > 0 then
        Tabs[1].Button.MouseButton1Click:Fire()
    end
end)

return SultanLib
