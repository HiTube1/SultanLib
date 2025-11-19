-- SultanLib v4 - Максимально надёжная версия (2025)
-- Дизайн 1 в 1 как у тебя в оригинале
-- Никаких крашей, nil-защита, логи, проверки

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
if not Player then return end

local PlayerGui = Player:WaitForChild("PlayerGui", 10)
if not PlayerGui then warn("PlayerGui не найден") return end

-- Главный ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SultanLib_Reliable"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

local CurrentZIndex = 10
local CurrentXOffset = 200  -- начальная позиция как у тебя

-- Функция драга (надёжная)
local function MakeDraggable(Frame)
    local DragFrame = Instance.new("Frame")
    DragFrame.Size = UDim2.new(1, 0, 0, 50)
    DragFrame.BackgroundTransparency = 1
    DragFrame.Parent = Frame

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function UpdateInput(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset +  delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset +  delta.Y
        )
    end

    DragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    DragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
            UpdateInput(input)
        end
    end)
end

-- Основная библиотека
local SultanLib = {}

-- Создание окна (вкладки справа)
function SultanLib:Window(TabName)
    if not TabName or type(TabName) ~= "string" then TabName = "Tab" end

    CurrentXOffset = CurrentXOffset + 300

    local Frame = Instance.new("Frame")
    Frame.Name = "Frame Tab " .. TabName
    Frame.Size = UDim2.new(0, 246, 0, 454)
    Frame.Position = UDim2.new(0, CurrentXOffset, 0.11208, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(29, 25, 37)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.ZIndex = CurrentZIndex
    CurrentZIndex = CurrentZIndex + 10
    Frame.Parent = ScreenGui

    -- Закругления
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = Frame

    -- Заголовок вкладки
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Tab name text"
    TitleLabel.Size = UDim2.new(0, 48, 0, 15)
    TitleLabel.Position = UDim2.new(0.41663, 0, 0.02173, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = TabName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 30
    TitleLabel.Font = Enum.Font.Arial
    TitleLabel.Parent = Frame

    -- Драг
    MakeDraggable(Frame)

    -- Контейнер для кнопок
    local ButtonY = 0.08431  -- точная позиция первой кнопки как у тебя

    local Tab = {}

    function Tab:Button(ButtonText, Callback)
        if type(ButtonText) ~= "string" then ButtonText = "Button" end
        if type(Callback) ~= "function" then Callback = function() end end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 210, 0, 41)
        Button.Position = UDim2.new(0.0841, 0, ButtonY, 0)
        Button.BackgroundColor3 = Color3.fromRGB(29, 25, 37)
        Button.BackgroundTransparency = 0.15
        Button.BorderSizePixel = 0
        Button.Text = " " .. ButtonText
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 19
        Button.Font = Enum.Font.Arial
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.ZIndex = Frame.ZIndex + 3
        Button.Parent = Frame

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 12)
        ButtonCorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
            pcall(Callback)
        end)

        ButtonY = ButtonY + 0.10132  -- точное расстояние между кнопками как у тебя
    end

    return Tab
end

-- Уведомление (надёжное)
function SultanLib:Notify(Text, Duration)
    if not Text then Text = "Notification" end
    Duration = Duration or 4

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 80)
    Notif.Position = UDim2.new(0.5, -150, 0, -100)
    Notif.BackgroundColor3 = Color3.fromRGB(29, 25, 37)
    Notif.BackgroundTransparency = 0.2
    Notif.ZIndex = 999999
    Notif.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = Notif

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 22
    Label.Font = Enum.Font.GothamBold
    Label.ZIndex = 999999 + 1
    Label.Parent = Notif

    -- Анимация
    TweenService:Create(Notif, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -150, 0, 120)}):Play()
    task.wait(Duration)
    TweenService:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, -100)}):Play()
    task.wait(0.6)
    if Notif and Notif.Parent then
        Notif:Destroy()
    end
end

return SultanLib
