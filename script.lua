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

        if success and response:find(userKey) then
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
    end,
})

--------------------------------
-- ✅ Shared config
--------------------------------
local hivePosition = Vector3.new(-42.8689, 5.1038, -324.8359)
local convertArgs = {"ActionCall", "Anthill", workspace:WaitForChild("Anthills"):WaitForChild("1"):WaitForChild("Platform")}
local toolArgs = {"UseTool", 1}
local hiveWaitTime = 5

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

    local function startFarm()
        while running and validKey do
            local pollen = player:WaitForChild("Leaderstats"):FindFirstChild("Pollen")
            local pollenValue = pollen and pollen.Value or 0

            if pollenValue >= bagThreshold then
                moveTo(hivePosition)
                task.wait(hiveWaitTime)
                RS:WaitForChild("Events"):WaitForChild("Server_Function"):InvokeServer(unpack(convertArgs))
                repeat task.wait(1) pollenValue = pollen.Value until pollenValue <= 0 or not running
            end

            for _, wp in ipairs(generateWaypoints()) do
                if not running then return end
                pollenValue = pollen.Value
                if pollenValue >= bagThreshold then break end
                moveTo(wp)
                RS:WaitForChild("Events"):WaitForChild("Server_Event"):FireServer(unpack(toolArgs))
                task.wait(0.05)
            end
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
            running = Value
            if running then task.spawn(startFarm) end
        end,
    })
end

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

createFieldTab("🌹 Rose Field", {
    Vector3.new(431.2232, 246.4489, 512.6610),
    Vector3.new(497.1391, 246.4489, 514.7206),
    Vector3.new(499.6319, 246.4489, 664.9557),
    Vector3.new(428.8901, 246.4489, 656.9597),
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
