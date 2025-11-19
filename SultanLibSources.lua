-- SultanLib — ОРИГИНАЛЬНЫЙ ДИЗАЙН КАК У ТЕБЯ В ПЕРВОМ СООБЩЕНИИ
-- Прозрачность 0.2 / 0.15, Arial, позиции 1 в 1, отдельные окна справа

local Tween = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Screen = Instance.new("ScreenGui", PlayerGui)
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local offset = 200
local z = 10

local function Drag(frame)
    local drag = Instance.new("Frame", frame)
    drag.Size = UDim2.new(1,0,0,50)
    drag.BackgroundTransparency = 1
    
    local dragging, start, startPos
    drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = i.Position
            startPos = frame.Position
        end
    end)
    drag.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - start
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local Lib = {}

function Lib:Window(name)
    offset = offset + 300
    local win = Instance.new("Frame", Screen)
    win.Size = UDim2.new(0,246,0,454)
    win.Position = UDim2.new(0,offset,0.11208,0)
    win.BackgroundColor3 = Color3.fromRGB(29,25,37)
    win.BackgroundTransparency = 0.2
    win.ZIndex = z z = z + 10

    local corner = Instance.new("UICorner", win)
    corner.CornerRadius = UDim.new(0,20)

    local title = Instance.new("TextLabel", win)
    title.Size = UDim2.new(0,48,0,15)
    title.Position = UDim2.new(0.41663,0,0.02173,0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.Arial
    title.TextSize = 30

    Drag(win)

    local y = 0.08431
    local tab = {}
    
    function tab:Button(text, callback)
        local btn = Instance.new("TextButton", win)
        btn.Size = UDim2.new(0,210,0,41)
        btn.Position = UDim2.new(0.0841,0,y,0)
        btn.BackgroundColor3 = Color3.fromRGB(29,25,37)
        btn.BackgroundTransparency = 0.15
        btn.Text = " "..text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Arial
        btn.TextSize = 19
        btn.TextXAlignment = "Left"
        btn.ZIndex = win.ZIndex + 3

        local c = Instance.new("UICorner", btn)
        c.CornerRadius = UDim.new(0,12)

        btn.MouseButton1Click:Connect(callback or function()end)
        
        y = y + 0.10132
    end

    return tab
end

SultanLib = Lib
print("SultanLib Original Style загружен")
return Lib
