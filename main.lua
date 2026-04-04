
--[ Rayfield Loader & UI Creation ]--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Anti-Cheat & Debug Suite",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "AntiCheatDebug"
    },
    KeySystem = false,
})

-- Create main tabs
local HitboxTab = Window:CreateTab("Hitbox Expander")
local ESPTab = Window:CreateTab("ESP Debugger")

--[ HITBOX EXPANDER MODULE ]--
local HitboxSection = HitboxTab:CreateSection("Hitbox Configuration")

-- Core Toggle
local HitboxEnabled = false
local HitboxSize = Vector3.new(13,13,13)
local HitboxTransparency = 0.5
local targetLimbs = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}

-- Store original part properties to restore later
local originalProperties = {} -- [part] = {Size, CanCollide, Transparency}

HitboxTab:CreateToggle({
    Name = "Enable Hitbox Expansion",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(State)
        HitboxEnabled = State
        if not HitboxEnabled then
            -- Restore all modified parts
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character then
                    for _, limb in pairs(targetLimbs) do
                        local part = v.Character:FindFirstChild(limb)
                        if part and originalProperties[part] then
                            part.Size = originalProperties[part].Size
                            part.CanCollide = originalProperties[part].CanCollide
                            part.Transparency = originalProperties[part].Transparency
                        end
                    end
                end
            end
        end
    end
})

-- Size Slider
HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {3, 25},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 13,
    Flag = "HitboxSize",
    Callback = function(Value)
        HitboxSize = Vector3.new(Value, Value, Value)
    end
})

-- Transparency Slider (fixed from dropdown)
HitboxTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "HitboxTransparency",
    Callback = function(Value)
        HitboxTransparency = Value
    end
})

--[ ESP DEBUGGING MODULE ]--
local ESPEnabled = false
local TeamCheckEnabled = true
local TraceEnabled = false
local EspColor = Color3.fromRGB(255, 0, 0)
local EspTransparency = 0.5
local MaxDistance = 1000

local function getTeamColor(player)
    if not TeamCheckEnabled or not player.Team then return EspColor end
    return player.Team.TeamColor.Color
end

local function createESP(player)
    if not player.Character or player == game.Players.LocalPlayer then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 1
    highlight.OutlineColor = getTeamColor(player)
    highlight.OutlineTransparency = EspTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    if TraceEnabled then
        local tracer = Instance.new("LineHandleAdornment")
        tracer.Name = "ESP_Tracer"
        tracer.Color3 = getTeamColor(player)
        tracer.Transparency = EspTransparency
        tracer.AlwaysOnTop = true
        tracer.ZIndex = 5
        tracer.Visible = false
        tracer.Parent = player.Character
    end
end

local function updateESP()
    if not ESPEnabled then return end
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local localChar = localPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
            if distance <= MaxDistance then
                if not player.Character:FindFirstChild("ESP_Highlight") then
                    createESP(player)
                else
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    highlight.OutlineColor = getTeamColor(player)
                    highlight.OutlineTransparency = EspTransparency
                end
                if TraceEnabled then
                    local tracer = player.Character:FindFirstChild("ESP_Tracer")
                    if tracer then
                        tracer.Visible = true
                        tracer.From = camera.CFrame.Position
                        tracer.To = player.Character.HumanoidRootPart.Position
                        tracer.Color3 = getTeamColor(player)
                        tracer.Transparency = EspTransparency
                    end
                end
            else
                if player.Character:FindFirstChild("ESP_Highlight") then
                    player.Character:FindFirstChild("ESP_Highlight"):Destroy()
                end
                if player.Character:FindFirstChild("ESP_Tracer") then
                    player.Character:FindFirstChild("ESP_Tracer"):Destroy()
                end
            end
        end
    end
end

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(State)
        ESPEnabled = State
        if not ESPEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    if player.Character:FindFirstChild("ESP_Highlight") then
                        player.Character:FindFirstChild("ESP_Highlight"):Destroy()
                    end
                    if player.Character:FindFirstChild("ESP_Tracer") then
                        player.Character:FindFirstChild("ESP_Tracer"):Destroy()
                    end
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheckToggle",
    Callback = function(State)
        TeamCheckEnabled = State
    end
})

ESPTab:CreateToggle({
    Name = "Enable Tracers",
    CurrentValue = false,
    Flag = "TraceToggle",
    Callback = function(State)
        TraceEnabled = State
        if not TraceEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP_Tracer") then
                    player.Character:FindFirstChild("ESP_Tracer"):Destroy()
                end
            end
        end
    end
})

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255,0,0),
    Flag = "ESPColor",
    Callback = function(Color)
        EspColor = Color
    end
})

ESPTab:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "ESPTransparency",
    Callback = function(Value)
        EspTransparency = Value
    end
})

ESPTab:CreateSlider({
    Name = "Max ESP Distance",
    Range = {50, 2000},
    Increment = 50,
    Suffix = "Studs",
    CurrentValue = 1000,
    Flag = "ESPDistance",
    Callback = function(Value)
        MaxDistance = Value
    end
})

--[ MAIN LOOPS ]--
local hitboxLoop
local espLoop

local function startHitboxLoop()
    if hitboxLoop then hitboxLoop:Disconnect() end
    hitboxLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if HitboxEnabled then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character then
                    for _, limb in pairs(targetLimbs) do
                        local part = v.Character:FindFirstChild(limb)
                        if part then
                            -- Store original properties once
                            if not originalProperties[part] then
                                originalProperties[part] = {
                                    Size = part.Size,
                                    CanCollide = part.CanCollide,
                                    Transparency = part.Transparency
                                }
                            end
                            part.CanCollide = false
                            part.Transparency = HitboxTransparency
                            part.Size = HitboxSize
                        end
                    end
                end
            end
        end
    end)
end

local function startESPLoop()
    if espLoop then espLoop:Disconnect() end
    espLoop = game:GetService("RunService").RenderStepped:Connect(function()
        updateESP()
    end)
end

startHitboxLoop()
startESPLoop()

game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        if player.Character:FindFirstChild("ESP_Highlight") then
            player.Character:FindFirstChild("ESP_Highlight"):Destroy()
        end
        if player.Character:FindFirstChild("ESP_Tracer") then
            player.Character:FindFirstChild("ESP_Tracer"):Destroy()
        end
    end
end)

Rayfield:Notify({
    Title = "Debug Suite Loaded",
    Content = "Anti-cheat analysis tools ready.",
    Duration = 5
})
