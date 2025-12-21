local P, RS = game:GetService("Players"), game:GetService("RunService")
local LP = P.LocalPlayer

local function btn(txt, pos, size)
	local b = Instance.new("TextButton")
	b.Text, b.Position, b.Size = txt, pos, size
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3, b.BorderSizePixel = Color3.new(1,1,1), 0
	b.Parent = gui
	return b
end

-- GUI
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local list = Instance.new("ScrollingFrame", gui)
list.Size, list.Position = UDim2.new(0,200,0,300), UDim2.new(0,270,0,10)
list.BackgroundColor3, list.BorderSizePixel = Color3.fromRGB(30,30,30), 0
list.ScrollBarThickness, list.Visible = 8, false

local select = btn("Select Player", UDim2.new(0,10,0,10), UDim2.new(0,130,0,30))
local tpBtn  = btn("Teleport OFF", UDim2.new(0,10,0,50), UDim2.new(0,130,0,30))
local hide   = btn("Hide All", UDim2.new(0,10,0,90), UDim2.new(0,130,0,30))
local show   = btn("▶", UDim2.new(0,10,0,90), UDim2.new(0,30,0,30))
local posBtn = btn("Position: Behind", UDim2.new(0,10,0,130), UDim2.new(0,130,0,30))
local plus   = btn("+", UDim2.new(0,150,0,130), UDim2.new(0,30,0,30))
local minus  = btn("-", UDim2.new(0,190,0,130), UDim2.new(0,30,0,30))

local distLbl = Instance.new("TextLabel", gui)
distLbl.Size, distLbl.Position = UDim2.new(0,200,0,30), UDim2.new(0,10,0,170)
distLbl.BackgroundColor3, distLbl.TextColor3 = Color3.fromRGB(30,30,30), Color3.new(1,1,1)
distLbl.BorderSizePixel, distLbl.Text = 0, "Distance: 4.0"

show.Visible = false

-- State
local target, tp, behind, dist = nil, false, true, 4

-- Player list
select.MouseButton1Click:Connect(function()
	list.Visible = not list.Visible
	if not list.Visible then return end
	list:ClearAllChildren()
	local y = 0
	for _,plr in ipairs(P:GetPlayers()) do
		if plr ~= LP then
			local b = Instance.new("TextButton", list)
			b.Text, b.Size, b.Position = plr.Name, UDim2.new(0,180,0,25), UDim2.new(0,10,0,y)
			b.BackgroundColor3, b.TextColor3, b.BorderSizePixel = Color3.fromRGB(50,50,50), Color3.new(1,1,1), 0
			b.MouseButton1Click:Connect(function()
				target = plr
				for _,c in ipairs(list:GetChildren()) do
					if c:IsA("TextButton") then
						c.BackgroundColor3 = (c == b) and Color3.fromRGB(0,255,0) or Color3.fromRGB(50,50,50)
					end
				end
			end)
			y += 30
		end
	end
	list.CanvasSize = UDim2.new(0,0,0,y)
end)

-- Toggles
tpBtn.MouseButton1Click:Connect(function()
	tp = not tp
	tpBtn.Text = tp and "Teleport ON" or "Teleport OFF"
end)

posBtn.MouseButton1Click:Connect(function()
	behind = not behind
	posBtn.Text = behind and "Position: Behind" or "Position: In Front"
end)

plus.MouseButton1Click:Connect(function()
	dist += 0.5
	distLbl.Text = ("Distance: %.1f"):format(dist)
end)

minus.MouseButton1Click:Connect(function()
	dist = math.max(0.5, dist - 0.5)
	distLbl.Text = ("Distance: %.1f"):format(dist)
end)

hide.MouseButton1Click:Connect(function()
	for _,v in ipairs({select,tpBtn,hide,posBtn,plus,minus,distLbl,list}) do v.Visible = false end
	show.Visible = true
end)

show.MouseButton1Click:Connect(function()
	for _,v in ipairs({select,tpBtn,hide,posBtn,plus,minus,distLbl}) do v.Visible = true end
	show.Visible = false
end)

-- Teleport
RS.Heartbeat:Connect(function()
	if not (tp and target and target.Character and LP.Character) then return end
	local t,l = target.Character:FindFirstChild("HumanoidRootPart"), LP.Character:FindFirstChild("HumanoidRootPart")
	if not (t and l) then return end
	local off = (behind and -1 or 1) * t.CFrame.LookVector * dist
	l.CFrame = CFrame.new(t.Position + off, t.Position)
end)
