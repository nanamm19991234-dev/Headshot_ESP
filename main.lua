local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- [[ GLOBAL SETTINGS ]]
_G.AimbotEnabled = false
_G.ESPEnabled = false
_G.TeamCheck = true
_G.AimPart = "Head"
_G.Sensitivity = 0 
_G.CircleRadius = 150
_G.HoldKey = Enum.KeyCode.X -- Default Key

local IsHoldingKey = false

-- [[ FUNGSI VALIDASI (CEK MUSUH & DARAH) ]]
local function IsValid(Player)
    if Player and Player ~= LocalPlayer and Player.Character then
        local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
        local Part = Player.Character:FindFirstChild(_G.AimPart)
        if Hum and Hum.Health > 0 and Part then
            if _G.TeamCheck and Player.Team == LocalPlayer.Team then return false end
            return true
        end
    end
    return false
end

-- [[ FUNGSI CARI TARGET TERDEKAT ]]
local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil
    for _, v in pairs(Players:GetPlayers()) do
        if IsValid(v) then
            local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(v.Character[_G.AimPart].Position)
            if OnScreen then
                local MouseLocation = UserInputService:GetMouseLocation()
                local VectorDistance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                if VectorDistance < MaximumDistance then
                    MaximumDistance = VectorDistance
                    Target = v
                end
            end
        end
    end
    return Target
end

-- [[ FUNGSI ESP (HIGHLIGHT) ]]
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("GeminiESP")
            
            if _G.ESPEnabled then
                -- Cek apakah musuh
                if player.Team ~= LocalPlayer.Team or player.Team == nil then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "GeminiESP"
                        highlight.Parent = char
                    end
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Enabled = true
                else
                    if highlight then highlight.Enabled = false end
                end
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
end

-- [[ INPUT HANDLING ]]
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == _G.HoldKey then IsHoldingKey = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == _G.HoldKey then IsHoldingKey = false end
end)

-- [[ MAIN LOOP ]]
RunService.RenderStepped:Connect(function()
    -- Update ESP secara berkala
    UpdateESP()

    -- Logika Aimbot
    local MyChar = LocalPlayer.Character
    local MyHum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
    
    if _G.AimbotEnabled and IsHoldingKey and MyHum and MyHum.Health > 0 then
        local Target = GetClosestPlayer()
        if Target and IsValid(Target) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[_G.AimPart].Position)
        end
    end
end)

-- [[ UI SYSTEM ]]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "😳 | Auto Headshot | V-0.0.1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- Button Aimbot
local btnAim = Instance.new("TextButton", MainFrame)
btnAim.Size = UDim2.new(0.8, 0, 0, 35)
btnAim.Position = UDim2.new(0.1, 0, 0.25, 0)
btnAim.Text = "Aimbot: OFF"
btnAim.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btnAim.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btnAim)

-- Button ESP
local btnESP = Instance.new("TextButton", MainFrame)
btnESP.Size = UDim2.new(0.8, 0, 0, 35)
btnESP.Position = UDim2.new(0.1, 0, 0.45, 0)
btnESP.Text = "ESP: OFF"
btnESP.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btnESP.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btnESP)

-- Input Key
local keyInput = Instance.new("TextBox", MainFrame)
keyInput.Size = UDim2.new(0.8, 0, 0, 35)
keyInput.Position = UDim2.new(0.1, 0, 0.7, 0)
keyInput.Text = "X"
keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
keyInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", keyInput)

-- UI LOGIC
btnAim.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    btnAim.Text = _G.AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    btnAim.BackgroundColor3 = _G.AimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

btnESP.MouseButton1Click:Connect(function()
    _G.ESPEnabled = not _G.ESPEnabled
    btnESP.Text = _G.ESPEnabled and "ESP: ON" or "ESP: OFF"
    btnESP.BackgroundColor3 = _G.ESPEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

keyInput.FocusLost:Connect(function()
    local key = keyInput.Text:upper()
    if #key == 1 then
        _G.HoldKey = Enum.KeyCode[key]
    else
        keyInput.Text = "X"
    end
end)
