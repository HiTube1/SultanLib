-- SultanLib Final — Nursultan Style 2025 


local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local pgui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SultanLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pgui


local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 680, 0, 500)
Main.Position = UDim2.new(0.5, -340, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Main.BackgroundTransparency = 0.05
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 18)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.8
Stroke.Transparency = 0.35
Stroke.Color = Color3.fromRGB(100, 100, 255)
local Grad = Instance.new("UIGradient", Stroke)
Grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 160, 255))
}
Grad.Rotation = 90


local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "SultanLib"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 28
Title.TextStrokeTransparency = 0.8


local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1, 0, 0, 55)
Tabs.Position = UDim2.new(0, 0, 0, 55)
Tabs.BackgroundTransparency = 1

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -20, 1, -120)
Content.Position = UDim2.new(0, 10, 0, 110)
Content.BackgroundTransparency = 1

local ActivePage = nil
local Buttons = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0, 140, 0, 45)
    btn.Position = UDim2.new(0, (#Buttons * 145), 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    table.insert(Buttons, btn)

    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        if ActivePage then ActivePage.Visible = false end
        ActivePage = page
        page.Visible = true
        for _, b in Buttons do
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
            b.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(90, 70, 255)
        btn.TextColor3 = Color3.new(1,1,1)
    end)

    local tab = {}
    function tab:Button(text, callback)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(1, -20, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(22, 22, 44)
        b.Text = "  " .. text
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 18
        b.TextXAlignment = "Left"
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        b.MouseButton1Click:Connect(callback or function() end)
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end

    return tab
end


local dragging = false
local dragStart, startPos
Main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
Main.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)


SultanLib = {}
SultanLib.Tab = CreateTab


task.spawn(function()
    task.wait(0.1)
    if #Buttons > 0 then
        Buttons[1].MouseButton1Click:Fire()
    end
end)


print("SultanLib загружен — Nursultan Style")
