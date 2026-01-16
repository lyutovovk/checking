--// CONFIGURATION
local TargetID = 8816493943
local ProfileLink = "https://www.roblox.com/users/8816493943/profile"
local ScriptToLoad = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/lyutovovk/dwdamn/refs/heads/main/main.lua"))()]]

--// SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// THEME
local Theme = {
    Background = Color3.fromRGB(25, 25, 35),
    Sidebar = Color3.fromRGB(20, 20, 30),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(120, 120, 130),
    Accent = Color3.fromRGB(10, 132, 255),
    Stroke = Color3.fromRGB(60, 60, 70),
    CornerRadius = UDim.new(0, 16)
}

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "macOS_Verification"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Window"
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = Theme.CornerRadius

-- Sidebar & Content
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.5

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -150, 1, 0)
Content.Position = UDim2.new(0, 150, 0, 0)
Content.BackgroundTransparency = 1

-- macOS Dots
local function CreateDot(color, offset)
    local Dot = Instance.new("Frame", MainFrame)
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = UDim2.new(0, 18 + offset, 0, 18)
    Dot.BackgroundColor3 = color
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
end
CreateDot(Color3.fromRGB(255, 95, 87), 0)
CreateDot(Color3.fromRGB(255, 189, 46), 20)
CreateDot(Color3.fromRGB(40, 200, 64), 40)

-- Text
local Title = Instance.new("TextLabel", Sidebar)
Title.Text = "Verification"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 20, 0, 60)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

--// VERIFICATION LOGIC
local function CheckIfFollowing(userId, targetId)
    local success, result = pcall(function()
        -- Using RoProxy to access the Friends API
        local url = string.format("https://friends.roproxy.com/v1/users/%d/followings?limit=100", userId)
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        
        for _, user in pairs(data.data) do
            if user.id == targetId then
                return true
            end
        end
        return false
    end)
    return success and result
end

--// BUTTONS
local function CreateButton(text, pos, callback)
    local ButtonFrame = Instance.new("Frame", Content)
    ButtonFrame.Size = UDim2.new(0.8, 0, 0, 45)
    ButtonFrame.Position = pos
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 10)

    local Btn = Instance.new("TextButton", ButtonFrame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = text
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 14

    Btn.MouseButton1Click:Connect(function()
        callback(Btn)
    end)
end

-- Button 1: Copy Link
CreateButton("Copy Profile Link", UDim2.new(0.1, 0, 0.3, 0), function(btn)
    if setclipboard then
        setclipboard(ProfileLink)
        btn.Text = "Link Copied!"
        task.wait(2)
        btn.Text = "Copy Profile Link"
    end
end)

-- Button 2: Verify & Inject
CreateButton("Verify Following", UDim2.new(0.1, 0, 0.55, 0), function(btn)
    btn.Text = "Checking..."
    
    if CheckIfFollowing(LocalPlayer.UserId, TargetID) then
        btn.Text = "Success!"
        task.wait(0.5)
        ScreenGui:Destroy()
        -- Run your main script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lyutovovk/dwdamn/refs/heads/main/main.lua"))()
    else
        btn.Text = "Not Following!"
        btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(2)
        btn.Text = "Verify Following"
        btn.TextColor3 = Theme.Text
    end
end)

-- Dragging Support
local Dragging, DragInput, DragStart, StartPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
end)
