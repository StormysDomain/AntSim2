-- ✅ Load Rayfield UI
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🐜 ANT KING FARMER",
    LoadingTitle = "🐜 ANT KING",
    LoadingSubtitle = "Dominating fields...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "AntKingFarm"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
})

-- ✅ Key System Tab
local userKey = ""
local KeyTab = Window:CreateTab("🔑 Key System", 1234567890)

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
            Rayfield:Notify({
                Title = "✅ Valid Key",
                Content = "Access Granted. Happy Farming!",
                Duration = 5
            })

            -- ✅ Unlock the full farming GUI dynamically
            local RS = game:GetService("ReplicatedStorage")
            local TweenService = game:GetService("TweenService")
            local hrp = player.Character or player.CharacterAdded:Wait()
            hrp = hrp:WaitForChild("HumanoidRootPart")

            local hivePosition = Vector3.new(-42.8689, 5.1038, -324.8359)
            local convertArgs = {"ActionCall", "Anthill", workspace:WaitForChild("Anthills"):WaitForChild("1"):WaitForChild("Platform")}
            local toolArgs = {"UseTool", 1}
            local tweenSpeed = 0.035
            local toolInterval = 0.05
            local hiveWaitTime = 7

            local function moveTo(pos)
                local info = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)})
                tween:Play()
                tween.Completed:Wait()
            end

            -- ✅ Top Field
            local topFieldWaypoints = {}
            do
                local corner1 = Vector3.new(-56.7527, 364.4479, 1000.4171)
                local corner2 = Vector3.new(-83.5665, 364.4479, 1075.5822)
                local corner3 = Vector3.new(-153.7264, 364.4489, 1051.4057)
                local corner4 = Vector3.new(-128.2519, 364.4489, 975.0910)
                local rows, cols = 6, 8
                for i = 0, rows do
                    local t = i / rows
                    local left = corner1:Lerp(corner4, t)
                    local right = corner2:Lerp(corner3, t)
                    for j = 0, cols do
                        local s = j / cols
                        table.insert(topFieldWaypoints, left:Lerp(right, s))
                    end
                end
            end

            local topRunning = false
            local topThreshold = 500000

            local function startTop()
                while topRunning do
                    local pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
                    local pollenValue = pollen and pollen.Value or 0
                    if pollenValue >= topThreshold then
                        moveTo(hivePosition)
                        task.wait(hiveWaitTime)
                        RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
                        repeat task.wait(1) pollenValue = pollen.Value until pollenValue <= 0 or not topRunning
                    end
                    for _, wp in ipairs(topFieldWaypoints) do
                        if not topRunning then return end
                        pollenValue = pollen.Value
                        if pollenValue >= topThreshold then break end
                        moveTo(wp)
                        RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer(unpack(toolArgs))
                        task.wait(toolInterval)
                    end
                end
            end

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
                    topRunning = Value
                    if topRunning then task.spawn(startTop) end
                end
            })

            -- ✅ Cedar Field
            local cedarFieldWaypoints = {}
            do
                local corner1 = Vector3.new(424.4028, 246.4489, 634.6984)
                local corner2 = Vector3.new(502.1051, 246.4489, 635.2498)
                local corner3 = Vector3.new(502.7247, 246.4489, 567.5714)
                local corner4 = Vector3.new(427.0260, 246.4489, 567.0328)
                local rows, cols = 5, 6
                for i = 0, rows do
                    local t = i / rows
                    local left = corner1:Lerp(corner4, t)
                    local right = corner2:Lerp(corner3, t)
                    for j = 0, cols do
                        local s = j / cols
                        table.insert(cedarFieldWaypoints, left:Lerp(right, s))
                    end
                end
            end

            local cedarRunning = false
            local cedarThreshold = 500000

            local function startCedar()
                while cedarRunning do
                    local pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
                    local pollenValue = pollen and pollen.Value or 0
                    if pollenValue >= cedarThreshold then
                        moveTo(hivePosition)
                        task.wait(hiveWaitTime)
                        RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
                        repeat task.wait(1) pollenValue = pollen.Value until pollenValue <= 0 or not cedarRunning
                    end
                    for _, wp in ipairs(cedarFieldWaypoints) do
                        if not cedarRunning then return end
                        pollenValue = pollen.Value
                        if pollenValue >= cedarThreshold then break end
                        moveTo(wp)
                        RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer(unpack(toolArgs))
                        task.wait(toolInterval)
                    end
                end
            end

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
                    cedarRunning = Value
                    if cedarRunning then task.spawn(startCedar) end
                end
            })

            -- ✅ Rose Field
            local roseFieldWaypoints = cedarFieldWaypoints -- Replace with real rose corners
            local roseRunning = false
            local roseThreshold = 500000

            local function startRose()
                while roseRunning do
                    local pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
                    local pollenValue = pollen and pollen.Value or 0
                    if pollenValue >= roseThreshold then
                        moveTo(hivePosition)
                        task.wait(hiveWaitTime)
                        RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
                        repeat task.wait(1) pollenValue = pollen.Value until pollenValue <= 0 or not roseRunning
                    end
                    for _, wp in ipairs(roseFieldWaypoints) do
                        if not roseRunning then return end
                        pollenValue = pollen.Value
                        if pollenValue >= roseThreshold then break end
                        moveTo(wp)
                        RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer(unpack(toolArgs))
                        task.wait(toolInterval)
                    end
                end
            end

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
                    roseRunning = Value
                    if roseRunning then task.spawn(startRose) end
                end
            })

        else
            Rayfield:Notify({
                Title = "❌ Invalid Key",
                Content = "That key is not valid. Try again or contact support.",
                Duration = 5
            })
        end
    end,
})
