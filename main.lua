local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ดึง config จาก global, ใส่ default กันพัง
local config = getgenv().config or {}
config.LockFps = config.LockFps or { Enable = false, Fps = 60 }
if config.WhiteScreen == nil then
    config.WhiteScreen = false
end

-- Hardcode ค่าตรงนี้ได้เลย ไม่ต้องพึ่ง config
local WHITE_SCREEN_TEXT = "NETWORK"
local WHITE_SCREEN_IMAGE = "rbxassetid://107237532641657"

local function getAvatar()
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size150x150
    local image = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    return image
end

local function applyFpsLock()
    if config.LockFps.Enable then
        local fps = config.LockFps.Fps or 30
        if setfpscap then
            setfpscap(fps)
        end
    end
end

-- ฟังก์ชันสร้าง/ลบ White Screen overlay
local whiteScreenGui = nil

local function applyWhiteScreen()
    if config.WhiteScreen then
        if not whiteScreenGui then
            whiteScreenGui = Instance.new("ScreenGui")
            whiteScreenGui.Name = "WhiteScreenOverlay"
            whiteScreenGui.IgnoreGuiInset = true
            whiteScreenGui.DisplayOrder = 999999
            whiteScreenGui.ResetOnSpawn = false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.Position = UDim2.new(0, 0, 0, 0)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.45 -- โปร่งใส มองเห็นฉากหลังลาง ๆ ปรับได้ 0 (ทึบ) - 1 (ใสหมด)
            frame.BorderSizePixel = 0
            frame.ZIndex = 999999
            frame.Parent = whiteScreenGui

            -- กล่องกลางจอ ใช้รวม layout
            local container = Instance.new("Frame")
            container.Size = UDim2.new(0, 320, 0, 290)
            container.AnchorPoint = Vector2.new(0.5, 0.5)
            container.Position = UDim2.new(0.5, 0, 0.45, 0)
            container.BackgroundTransparency = 1
            container.ZIndex = 1000000
            container.Parent = frame

            -- รูปภาพตรงกลาง (ขยายเป็น 200x200)
            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Name = "CenterImage"
            imageLabel.Size = UDim2.new(0, 200, 0, 200)
            imageLabel.AnchorPoint = Vector2.new(0.5, 0)
            imageLabel.Position = UDim2.new(0.5, 0, 0, 0)
            imageLabel.BackgroundTransparency = 1
            imageLabel.Image = WHITE_SCREEN_IMAGE
            imageLabel.ZIndex = 1000001
            imageLabel.Parent = container

            -- ข้อความหลัก
            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "CenterText"
            textLabel.Size = UDim2.new(1, 0, 0, 45)
            textLabel.AnchorPoint = Vector2.new(0.5, 0)
            textLabel.Position = UDim2.new(0.5, 0, 0, 210)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = WHITE_SCREEN_TEXT
            textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            textLabel.Font = Enum.Font.FredokaOne
            textLabel.TextSize = 28
            textLabel.TextScaled = false
            textLabel.ZIndex = 1000001
            textLabel.Parent = container

            -- เส้นใต้บาง ๆ ให้ดูมีดีไซน์
            local underline = Instance.new("Frame")
            underline.Size = UDim2.new(0, 50, 0, 3)
            underline.AnchorPoint = Vector2.new(0.5, 0)
            underline.Position = UDim2.new(0.5, 0, 0, 260)
            underline.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
            underline.BorderSizePixel = 0
            underline.ZIndex = 1000001
            underline.Parent = container

            local underlineCorner = Instance.new("UICorner")
            underlineCorner.CornerRadius = UDim.new(1, 0)
            underlineCorner.Parent = underline

            if gethui then
                whiteScreenGui.Parent = gethui()
            else
                whiteScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
        end
    else
        if whiteScreenGui then
            whiteScreenGui:Destroy()
            whiteScreenGui = nil
        end
    end
end

task.spawn(function()
    while true do
        applyWhiteScreen()
        task.wait(0.5)
    end
end)

applyFpsLock()

while true do
    local name = LocalPlayer.Name
    local jobId = game.JobId
    local status = "online"
    local avatar = getAvatar()

    pcall(function()
        local url = "http://127.0.0.1:3000/status"
            .. "?name=" .. name
            .. "&jobid=" .. jobId
            .. "&status=" .. status
            .. "&avatar=" .. HttpService:UrlEncode(avatar)
        game:HttpGet(url)
    end)

    task.wait(5)
end
