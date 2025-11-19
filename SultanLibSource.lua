local S=game:GetService("TweenService")
local I=game:GetService("UserInputService")
local P=game.Players.LocalPlayer.PlayerGui
local G=Instance.new("ScreenGui",P)
G.ResetOnSpawn=false
G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
G.Name="SultanLib"
local Z=100
local X=180

local function D(F)
local dr,start,startPos
F.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then
dr=true start=i.Position startPos=F.Position end end)
F.InputChanged:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseMovement and dr then
local delta=i.Position-start
S:Create(F,TweenInfo.new(.12),{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)}):Play()
end end)
I.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
end

local Lib={}
function Lib:Window(n)
X=X+280
local W=Instance.new("Frame",G)
W.Size=UDim2.new(0,260,0,500)
W.Position=UDim2.new(0,X,0,-600)
W.BackgroundColor3=Color3.fromRGB(20,16,32)
W.ZIndex=Z Z=Z+10

local C=Instance.new("UICorner",W)C.CornerRadius=UDim.new(0,18)
local T=Instance.new("UIStroke",W)
T.Thickness=2 T.Color=Color3.fromRGB(140,60,255) T.Transparency=.35
local Gr=Instance.new("UIGradient",T)
Gr.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(180,50,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(50,150,255))}
Gr.Rotation=45

local Title=Instance.new("TextLabel",W)
Title.Size=UDim2.new(1,-60,0,50)
Title.Position=UDim2.new(0,20,0,0)
Title.BackgroundTransparency=1
Title.Text=n or"Tab"
Title.TextColor3=Color3.new(1,1,1)
Title.Font=Enum.Font.GothamBold
Title.TextSize=21
Title.TextXAlignment="Left"
Title.ZIndex=W.ZIndex+1

local Close=Instance.new("TextButton",W)
Close.Size=UDim2.new(0,36,0,36)
Close.Position=UDim2.new(1,-46,0,7)
Close.BackgroundTransparency=1
Close.Text="×"
Close.TextColor3=Color3.fromRGB(255,80,80)
Close.Font=Enum.Font.GothamBold
Close.TextSize=30
Close.ZIndex=W.ZIndex+2
Close.MouseButton1Click:Connect(function()
S:Create(W,TweenInfo.new(.4,Enum.EasingStyle.Quint),{Position=UDim2.new(0,X,0,-600)}):Play()
task.wait(.45)W:Destroy()
end)

local Drag=Instance.new("Frame",W)
Drag.Size=UDim2.new(1,0,0,50)
Drag.BackgroundTransparency=1
Drag.ZIndex=W.ZIndex+3
D(Drag)

S:Create(W,TweenInfo.new(.7,Enum.EasingStyle.Back),{Position=UDim2.new(0,X,0,120)}):Play()

local C=Instance.new("Folder",W)C.Name="C"

local tab={}
function tab:Button(t,f)
local B=Instance.new("TextButton",C)
B.Size=UDim2.new(0,210,0,44)
B.Position=UDim2.new(0,25,0,60+(#C:GetChildren()*52))
B.BackgroundColor3=Color3.fromRGB(30,24,46)
B.Text="  "..t
B.TextColor3=Color3.new(1,1,1)
B.Font=Enum.Font.Gotham
B.TextSize=18
B.TextXAlignment="Left"
B.ZIndex=W.ZIndex+5

Instance.new("UICorner",B).CornerRadius=UDim.new(0,12)
local St=Instance.new("UIStroke",B)
St.Color=Color3.fromRGB(120,50,220)
St.Thickness=1.5
St.Transparency=.6

B.MouseButton1Click:Connect(function()
spawn(f)
S:Create(B,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(90,40,180)}):Play()
task.wait(.15)
S:Create(B,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(30,24,46)}):Play()
end)
end
return tab
end

function Lib:Notify(t,d)
d=d or 3
local N=Instance.new("Frame",G)
N.Size=UDim2.new(0,320,0,80)
N.Position=UDim2.new(1,-340,1,-100)
N.BackgroundColor3=Color3.fromRGB(20,16,32)
N.ZIndex=9999

Instance.new("UICorner",N).CornerRadius=UDim.new(0,16)
local St=Instance.new("UIStroke",N)
St.Color=Color3.fromRGB(140,60,255)
St.Thickness=2

local L=Instance.new("TextLabel",N)
L.Size=UDim2.new(1,-20,1,0)
L.Position=UDim2.new(0,10,0,0)
L.BackgroundTransparency=1
L.Text=t
L.TextColor3=Color3.new(1,1,1)
L.Font=Enum.Font.GothamBold
L.TextSize=19
L.ZIndex=10000

S:Create(N,TweenInfo.new(.5,Enum.EasingStyle.Quint),{Position=UDim2.new(1,-340,1,-170)}):Play()
task.wait(d)
S:Create(N,TweenInfo.new(.5),{Position=UDim2.new(1,20,1,-100)}):Play()
task.wait(.6)
N:Destroy()
end

return Lib
