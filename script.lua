-- ✅ Load Rayfield UI
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🐜 ANT KING FARMER PRO",
    LoadingTitle = "🐜 ANT KING",
    LoadingSubtitle = "Dominating fields and bushes...",
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

--------------------------------
-- ✅ Anti AFK
--------------------------------
local antiAfk = true
Players.LocalPlayer.Idled:Connect(function()
    if antiAfk then
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

--------------------------------
-- ✅ Key System
--------------------------------
local userKey = ""
local validKey = false

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

        if success then
            local keyValid = false
            for line in response:gmatch("[^\r\n]+") do
                if line == userKey then
                    keyValid = true
                    break
                end
            end

            if keyValid then
                validKey = true
                Rayfield:Notify({
                    Title = "✅ Valid Key",
                    Content = "Access Granted.",
                    Duration = 5
                })
            else
                Rayfield:Notify({
                    Title = "❌ Invalid Key",
                    Content = "Key not valid.",
                    Duration = 5
                })
            end
        else
            Rayfield:Notify({
                Title = "❌ Error",
                Content = "Could not fetch key list.",
                Duration = 5
            })
        end
    end,
})

--------------------------------
-- ✅ Hive Detection
--------------------------------
local hivePosition = nil
local convertArgs = nil

local hivePositions = {
    [1] = Vector3.new(-42.8689, 5.1038, -324.8359),
    [2] = Vector3.new(-2.3234851, 5.1039328, -369.5058),
    [3] = Vector3.new(55.502813, 5.1039042, -385.0993),
    [4] = Vector3.new(-112.2728805, 5.1038875, -367.5769),
    [5] = Vector3.new(156.571868, 5.1039724, -329.2253),
}

local function detectHive()
    local anthills = workspace:WaitForChild("Anthills")
    for i = 1,5 do
        local anthill = anthills:FindFirstChild(tostring(i))
        if anthill then
            local platform = anthill:FindFirstChild("Platform")
            if platform and platform:FindFirstChild("Owner") then
                if platform.Owner.Value == player.Name then
                    hivePosition = hivePositions[i]
                    convertArgs = {"ActionCall", "Anthill", platform}
                    print("✅ Hive detected: "..i)
                    break
                end
            end
        end
    end
end

--------------------------------
-- ✅ Shared config
--------------------------------
local hiveWaitTime = 8
local tweenMultiplier = 1
local densityMultiplier = 1

local function moveTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local info = TweenInfo.new(0.04 * (1 / tweenMultiplier), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

local function convertPollen()
    moveTo(hivePosition)
    task.wait(hiveWaitTime)

    local Vars = workspace:FindFirstChild("Vars")
    local converting = Vars and Vars:FindFirstChild("Converting")
    local tries = 0

    RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
    task.wait(1)

    while converting and not converting.Value and tries < 5 do
        RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
        tries += 1
        task.wait(1)
    end
end

--------------------------------
-- ✅ FIELD FARMING (Fixed)
--------------------------------
local function createFieldTab(name, corners)
    local running = false
    local bagThreshold = 500000

    local function generateWaypoints()
        local wp = {}
        local rows = math.max(1, math.floor(5 * densityMultiplier))
        local cols = math.max(1, math.floor(6 * densityMultiplier))
        for i = 0, rows do
            local t = i / rows
            local left = corners[1]:Lerp(corners[4], t)
            local right = corners[2]:Lerp(corners[3], t)
            for j = 0, cols do
                local s = j / cols
                table.insert(wp, left:Lerp(right, s))
            end
        end
        return wp
    end

    local function loopFarm()
        local pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")

        while running and validKey do
            pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
            if pollen.Value >= bagThreshold then
                convertPollen()
                while pollen.Value > 0 and running do
                    task.wait(1)
                    pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
                end
            else
                for _, wp in ipairs(generateWaypoints()) do
                    if not running then return end
                    pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
                    if pollen.Value >= bagThreshold then break end
                    moveTo(wp)
                    RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer("UseTool", 1)
                    task.wait(0.05)
                end
            end
            task.wait(0.1)
        end
    end

    local tab = Window:CreateTab(name, 1234567890)

    tab:CreateInput({
        Name = "Bag Size",
        PlaceholderText = tostring(bagThreshold),
        RemoveTextAfterFocusLost = true,
        Callback = function(Value)
            local num = tonumber(Value)
            if num then bagThreshold = num end
        end,
    })

    tab:CreateToggle({
        Name = "Toggle Farming",
        CurrentValue = false,
        Callback = function(Value)
            if not validKey then
                Rayfield:Notify({
                    Title = "🔒 Key Required",
                    Content = "Submit a valid key first.",
                    Duration = 5
                })
                return
            end
            if not hivePosition then detectHive() end
            if not hivePosition then
                Rayfield:Notify({
                    Title = "❌ Hive not found",
                    Content = "No hive detected for your player.",
                    Duration = 5
                })
                return
            end
            running = Value
            if running then
                task.spawn(loopFarm)
            end
        end,
    })
end

--------------------------------
-- ✅ BUSH FARMING (SAFE)
--------------------------------
local bushes = {
    Vector3.new(-5.4815, 3.95, -215.5573),
    Vector3.new(-65.5382, 27.9499, 289.5440),
    Vector3.new(-73.0016, 58.9499, 376.1909),
    Vector3.new(-316.1985, 92.5984, 466.4048),
    Vector3.new(-308.2780, 92.5984, 455.3149),
    Vector3.new(165.9558, 92.5978, 541.1715)
}

local bushHitTime = 5
local bushRunning = false

local function safeMoveTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    -- Always keep height safe
    local safePos = Vector3.new(pos.X, math.max(pos.Y, 5), pos.Z)
    local info = TweenInfo.new(0.04 * (1 / tweenMultiplier), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(safePos)})
    tween:Play()
    tween.Completed:Wait()
end

local function BushFarm()
    while bushRunning and validKey do
        for _, bushPos in ipairs(bushes) do
            safeMoveTo(bushPos)
            local t = tick()
            while tick() - t < bushHitTime and bushRunning do
                RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer("UseTool", 1)
                task.wait(0.2)
            end

            local radius = 4
            for angle = 0, 360, 45 do
                local rad = math.rad(angle)
                local offset = Vector3.new(math.cos(rad) * radius, 0, math.sin(rad) * radius)
                safeMoveTo(bushPos + offset)
                task.wait(0.1)
            end
        end
    end
end

local BushTab = Window:CreateTab("🌿 Bush Farm", 1234567890)

BushTab:CreateInput({
    Name = "Bush Hit Time (sec)",
    PlaceholderText = tostring(bushHitTime),
    RemoveTextAfterFocusLost = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then bushHitTime = num end
    end,
})

BushTab:CreateToggle({
    Name = "Toggle Bush Farming",
    CurrentValue = false,
    Callback = function(Value)
        if not validKey then
            Rayfield:Notify({
                Title = "🔒 Key Required",
                Content = "Submit a valid key first.",
                Duration = 5
            })
            return
        end
        bushRunning = Value
        if bushRunning then task.spawn(BushFarm) end
    end,
})

--------------------------------
-- ✅ Fields
--------------------------------
createFieldTab("🌾 Top Field", {
    Vector3.new(-56.7527, 364.4479, 1000.4171),
    Vector3.new(-83.5665, 364.4479, 1075.5822),
    Vector3.new(-153.7264, 364.4489, 1051.4057),
    Vector3.new(-128.2519, 364.4489, 975.0910),
})

createFieldTab("🌲 Cedar Field", {
    Vector3.new(424.4028, 246.4489, 634.6984),
    Vector3.new(502.1051, 246.4489, 635.2498),
    Vector3.new(502.7247, 246.4489, 567.5714),
    Vector3.new(427.0260, 246.4489, 567.0328),
})


createFieldTab("🌼 Dandelion Field", {
    Vector3.new(-38.9106, 3.95, -202.7858),
    Vector3.new(-100.5770, 3.95, -199.4258),
    Vector3.new(-100.8382, 3.95, -142.8992),
    Vector3.new(-38.4781, 3.95, -141.7600),
})

createFieldTab("🍄 Mushroom Field", {
    Vector3.new(13.0849, 3.95, -3.1232),
    Vector3.new(73.0142, 3.95, -1.2952),
    Vector3.new(73.7536, 3.95, 51.0374),
    Vector3.new(12.2008, 3.95, 51.6056),
})

createFieldTab("🔵 Blue Flower Field", {
    Vector3.new(-230.0941, 3.95, 196.2644),
    Vector3.new(-230.5790, 3.95, 269.0285),
    Vector3.new(-283.4212, 3.95, 270.2152),
    Vector3.new(-284.6819, 3.95, 197.2568),
})

createFieldTab("🎍 Bamboo Field", {
    Vector3.new(-206.9211, 91.8234, 496.4200),
    Vector3.new(-137.6663, 91.0871, 497.1348),
    Vector3.new(-137.7168, 90.8236, 575.4165),
    Vector3.new(-209.6989, 90.8236, 575.1451),
})



--------------------------------
-- ✅ Global Controls
--------------------------------
local Controls = Window:CreateTab("⚙️ Controls", 1234567890)

Controls:CreateSlider({
    Name = "Tween Speed Multiplier",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = tweenMultiplier,
    Callback = function(Value)
        tweenMultiplier = Value
    end,
})

Controls:CreateSlider({
    Name = "Density Multiplier",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = densityMultiplier,
    Callback = function(Value)
        densityMultiplier = Value
    end,
})

Controls:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = antiAfk,
    Callback = function(Value)
        antiAfk = Value
    end,
})
