-- ✅ Required Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ✅ Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🐜 ANT KING FARMER PRO",
    LoadingTitle = "🐜 ANT KING PRO",
    LoadingSubtitle = "Dominating the Fields...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "AntKingProFarm"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
})

-- ✅ Globals
local hivePosition = Vector3.new(-42.8689, 5.1038, -324.8359)
local convertArgs = {"ActionCall", "Anthill", workspace:WaitForChild("Anthills"):WaitForChild("1"):WaitForChild("Platform")}
local toolArgs = {"UseTool", 1}

local baseTweenSpeed = 0.04
local tweenMultiplier = 1.0
local densityMultiplier = 1.0
local toolInterval = 0.05
local hiveWaitTime = 10

local antiAFKEnabled = false
local validKey = false

-- ✅ Anti-AFK
player.Idled:Connect(function()
    if antiAFKEnabled then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- ✅ Character rebind after death
local function waitForCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local hrp = waitForCharacter()
player.CharacterAdded:Connect(function()
    hrp = waitForCharacter()
end)

-- ✅ Safe Move Function
local function moveTo(pos)
    local info = TweenInfo.new(baseTweenSpeed / tweenMultiplier, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- ✅ Waypoint Generator
local function createWaypoints(corner1, corner2, corner3, corner4, baseRows, baseCols)
    local waypoints = {}
    local rows = math.floor(baseRows * densityMultiplier)
    local cols = math.floor(baseCols * densityMultiplier)
    for i = 0, rows do
        local t = i / rows
        local left = corner1:Lerp(corner4, t)
        local right = corner2:Lerp(corner3, t)
        for j = 0, cols do
            local s = j / cols
            table.insert(waypoints, left:Lerp(right, s))
        end
    end
    return waypoints
end

-- ✅ Farming Loops
local function runField(thresholdGetter, getWaypoints)
    while validKey do
        local pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
        local pollenValue = pollen and pollen.Value or 0
        if pollenValue >= thresholdGetter() then
            moveTo(hivePosition)
            task.wait(hiveWaitTime)
            RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
            repeat task.wait(1) pollenValue = pollen.Value until pollenValue <= 0
        end
        for _, wp in ipairs(getWaypoints()) do
            pollenValue = pollen.Value
            if pollenValue >= thresholdGetter() then break end
            moveTo(wp)
            RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer(unpack(toolArgs))
            task.wait(toolInterval)
        end
    end
end

-- ✅ Key System UI
local KeyTab = Window:CreateTab("🔑 Key System", 1234567890)
local userKey = ""

KeyTab:CreateInput({
    Name = "Enter Your Key",
    PlaceholderText = "XXXXXXXXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        userKey = Value
    end,
})

KeyTab:CreateButton({
    Name = "Submit Key",
    Callback = function()
        local success, response = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/StormysDomain/AntSim2/main/keys.txt")
        end)

        if success and response:find(userKey) then
            validKey = true

            Rayfield:Notify({
                Title = "✅ Valid Key",
                Content = "Access Granted. Tabs Unlocked!",
                Duration = 5
            })

            --------------------
            -- ✅ Settings Tab
            --------------------
            local SettingsTab = Window:CreateTab("⚙️ Settings", 1234567890)
            SettingsTab:CreateToggle({
                Name = "Anti-AFK",
                CurrentValue = true,
                Callback = function(Value)
                    antiAFKEnabled = Value
                end,
            })

            SettingsTab:CreateSlider({
                Name = "Tween Speed Multiplier",
                Range = {0.5, 5},
                Increment = 0.1,
                CurrentValue = 1.0,
                Callback = function(Value)
                    tweenMultiplier = Value
                end,
            })

            SettingsTab:CreateSlider({
                Name = "Field Density Multiplier",
                Range = {0.5, 5},
                Increment = 0.1,
                CurrentValue = 1.0,
                Callback = function(Value)
                    densityMultiplier = Value
                end,
            })

            --------------------
            -- ✅ Top Field
            --------------------
            local topThreshold = 500000
            local TopTab = Window:CreateTab("🌾 Top Field", 1234567890)
            TopTab:CreateInput({
                Name = "Bag Size",
                PlaceholderText = tostring(topThreshold),
                RemoveTextAfterFocusLost = true,
                Callback = function(Value)
                    local num = tonumber(Value)
                    if num then topThreshold = num end
                end
            })
            TopTab:CreateToggle({
                Name = "Toggle Farming",
                CurrentValue = false,
                Callback = function(Value)
                    if Value then
                        task.spawn(function()
                            runField(
                                function() return topThreshold end,
                                function()
                                    return createWaypoints(
                                        Vector3.new(-56.7527, 364.4479, 1000.4171),
                                        Vector3.new(-83.5665, 364.4479, 1075.5822),
                                        Vector3.new(-153.7264, 364.4489, 1051.4057),
                                        Vector3.new(-128.2519, 364.4489, 975.0910),
                                        6, 8
                                    )
                                end
                            )
                        end)
                    end
                end
            })

            --------------------
            -- ✅ Cedar Field
            --------------------
            local cedarThreshold = 500000
            local CedarTab = Window:CreateTab("🌲 Cedar Field", 1234567890)
            CedarTab:CreateInput({
                Name = "Bag Size",
                PlaceholderText = tostring(cedarThreshold),
                RemoveTextAfterFocusLost = true,
                Callback = function(Value)
                    local num = tonumber(Value)
                    if num then cedarThreshold = num end
                end
            })
            CedarTab:CreateToggle({
                Name = "Toggle Farming",
                CurrentValue = false,
                Callback = function(Value)
                    if Value then
                        task.spawn(function()
                            runField(
                                function() return cedarThreshold end,
                                function()
                                    return createWaypoints(
                                        Vector3.new(424.4028, 246.4489, 634.6984),
                                        Vector3.new(502.1051, 246.4489, 635.2498),
                                        Vector3.new(502.7247, 246.4489, 567.5714),
                                        Vector3.new(427.0260, 246.4489, 567.0328),
                                        5, 6
                                    )
                                end
                            )
                        end)
                    end
                end
            })

            --------------------
            -- ✅ Rose Field
            --------------------
            local roseThreshold = 500000
            local RoseTab = Window:CreateTab("🌹 Rose Field", 1234567890)
            RoseTab:CreateInput({
                Name = "Bag Size",
                PlaceholderText = tostring(roseThreshold),
                RemoveTextAfterFocusLost = true,
                Callback = function(Value)
                    local num = tonumber(Value)
                    if num then roseThreshold = num end
                end
            })
            RoseTab:CreateToggle({
                Name = "Toggle Farming",
                CurrentValue = false,
                Callback = function(Value)
                    if Value then
                        task.spawn(function()
                            runField(
                                function() return roseThreshold end,
                                function()
                                    return createWaypoints(
                                        Vector3.new(424.4028, 246.4489, 634.6984), -- placeholder
                                        Vector3.new(502.1051, 246.4489, 635.2498),
                                        Vector3.new(502.7247, 246.4489, 567.5714),
                                        Vector3.new(427.0260, 246.4489, 567.0328),
                                        5, 6
                                    )
                                end
                            )
                        end)
                    end
                end
            })

        else
            Rayfield:Notify({
                Title = "❌ Invalid Key",
                Content = "Key not valid. Try again or contact owner.",
                Duration = 5
            })
        end
    end,
})
