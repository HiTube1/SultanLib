local S=game:GetService("TweenService")
local I=game:GetService("UserInputService")
local P=game.Players.LocalPlayer:WaitForChild("PlayerGui")

local G=Instance.new("ScreenGui",P)
G.Name="SultanLib"
G.ResetOnSpawn=false
G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local Z=10
local X=200

local function Drag(f)
	local dr,start,startPos
	f.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			dr=true start=i.Position startPos=f.Position
		end
	end)
	f.InputChanged:Connect(function(i)
		if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
			local d=i.Position-start
			f.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
		end
	end)
	I.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
end

local Lib={}
function Lib:Window(name)
	X=X+300
	local Win=Instance.new("Frame",G)
	Win.Size=UDim2.new(0,246,0,454)
	Win.Position=UDim2.new(0,X,0,-600)
	Win.BackgroundColor3=Color3.fromRGB(29,25,37)
	Win.BackgroundTransparency=0.2
	Win.BorderSizePixel=0
	Win.ZIndex=Z Z=Z+10

	local Corner=Instance.new("UICorner",Win)
	Corner.CornerRadius=UDim.new(0,20)

	local Stroke=Instance.new("UIStroke",Win)
	Stroke.Thickness=2
	Stroke.Color=Color3.fromRGB(140,60,255)
	Stroke.Transparency=0.4
	local Grad=Instance.new("UIGradient",Stroke)
	Grad.Color=ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(170,50,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(50,150,255))
	}
	Grad.Rotation=45

	local Title=Instance.new("TextLabel",Win)
	Title.Name="Tab name text"
	Title.Size=UDim2.new(0,48,0,15)
	Title.Position=UDim2.new(0.41663,0,0.02173,0)
	Title.BackgroundTransparency=1
	Title.Text=name
	Title.TextColor3=Color3.new(1,1,1)
	Title.Font=Enum.Font.Arial
	Title.TextSize=30
	Title.ZIndex=Win.ZIndex+1

	local DragArea=Instance.new("Frame",Win)
	DragArea.Size=UDim2.new(1,0,0,50)
	DragArea.BackgroundTransparency=1
	Drag(DragArea)

	S:Create(Win,TweenInfo.new(0.6,Enum.E subduedStyle.Back),{Position=UDim2.new(0,X,0.112,0)}):Play()

	local Container=Instance.new("Frame",Win)
	Container.Size=UDim2.new(1,0,1,0)
	Container.BackgroundTransparency=1
	Container.ZIndex=Win.ZIndex

	local Y=0.08431
	local tab={}
	function tab:Button(text,callback)
		local Btn=Instance.new("TextButton",Container)
		Btn.Size=UDim2.new(0,210,0,41)
		Btn.Position=UDim2.new(0.0841,0,Y,0)
		Btn.BackgroundColor3=Color3.fromRGB(29,25,37)
		Btn.BackgroundTransparency=0.15
		Btn.BorderSizePixel=0
		Btn.Text=" "..text
		Btn.TextColor3=Color3.new(1,1,1)
		Btn.Font=Enum.Font.Arial
		Btn.TextSize=19
		Btn.TextXAlignment="Left"
		Btn.ZIndex=Win.ZIndex+3

		local C=Instance.new("UICorner",Btn)
		C.CornerRadius=UDim.new(0,12)

		Btn.MouseButton1Click:Connect(function()
			spawn(callback)
		end)

		Y=Y+0.10132 -- точное расстояние между кнопками как у тебя
	end

	return tab
end

function Lib:Notify(text,dur)
	dur=dur or 3
	local N=Instance.new("Frame",G)
	N.Size=UDim2.new(0,300,0,80)
	N.Position=UDim2.new(0.5,-150,0,-100)
	N.BackgroundColor3=Color3.fromRGB(29,25,37)
	N.BackgroundTransparency=0.2
	N.ZIndex=9999

	local C=Instance.new("UICorner",N)C.CornerRadius=UDim.new(0,16)
	local S=Instance.new("UIStroke",N)
	S.Color=Color3.fromRGB(140,60,255)
	S.Thickness=2
	S.Transparency=0.5

	local L=Instance.new("TextLabel",N)
	L.Size=UDim2.new(1,0,1,0)
	L.BackgroundTransparency=1
	L.Text=text
	L.TextColor3=Color3.new(1,1,1)
	L.Font=Enum.Font.GothamBold
	L.TextSize=22
	L.ZIndex=10000

	N.Position=UDim2.new(0.5,-150,0,-100)
	S:Create(N,TweenInfo.new(0.6,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-150,0,120)}):Play()
	task.wait(dur)
	S:Create(N,TweenInfo.new(0.5),{Position=UDim2.new(0.5,-150,0,-100)}):Play()
	task.wait(0.6) N:Destroy()
end

return Lib
