local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ดึง config จาก global, ใส่ default กันพัง
local config = getgenv().config or {}
config.LockFps = config.LockFps or { Enable = false, Fps = 60 }
if config.WhiteScreen == nil then
    config.WhiteScreen = false
end

-- Hardcode ค่าตรงนี้ได้เลย
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

            -- พื้นหลังทึบดำสนิท
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.Position = UDim2.new(0, 0, 0, 0)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0 -- ทึบ 100%
            frame.BorderSizePixel = 0
            frame.ZIndex = 999999
            frame.Parent = whiteScreenGui

            -- Network icon มุมบนกลาง (เล็กลง ไม่เป็นจุดเด่นหลัก)
            local networkIcon = Instance.new("ImageLabel")
            networkIcon.Name = "NetworkIcon"
            networkIcon.Size = UDim2.new(0, 60, 0, 60)
            networkIcon.AnchorPoint = Vector2.new(0.5, 0)
            networkIcon.Position = UDim2.new(0.5, 0, 0, 40)
            networkIcon.BackgroundTransparency = 1
            networkIcon.Image = WHITE_SCREEN_IMAGE
            networkIcon.ZIndex = 1000001
            networkIcon.Parent = frame

            local networkText = Instance.new("TextLabel")
            networkText.Name = "NetworkText"
            networkText.Size = UDim2.new(1, 0, 0, 30)
            networkText.AnchorPoint = Vector2.new(0.5, 0)
            networkText.Position = UDim2.new(0.5, 0, 0, 100)
            networkText.BackgroundTransparency = 1
            networkText.Text = WHITE_SCREEN_TEXT
            networkText.TextColor3 = Color3.fromRGB(0, 162, 255)
            networkText.Font = Enum.Font.FredokaOne
            networkText.TextSize = 24
            networkText.ZIndex = 1000001
            networkText.Parent = frame

            -- Container กลางจอ: Avatar ซ้าย | ข้อมูล ขวา
            local container = Instance.new("Frame")
            container.Name = "InfoContainer"
            container.Size = UDim2.new(0, 420, 0, 130)
            container.AnchorPoint = Vector2.new(0.5, 0.5)
            container.Position = UDim2.new(0.5, 0, 0.5, 0)
            container.BackgroundTransparency = 1
            container.ZIndex = 1000000
            container.Parent = frame

            -- Avatar รูปโปรไฟล์ (ซ้าย)
            local avatarImage = Instance.new("ImageLabel")
            avatarImage.Name = "AvatarImage"
            avatarImage.Size = UDim2.new(0, 120, 0, 120)
            avatarImage.Position = UDim2.new(0, 0, 0.5, -60)
            avatarImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            avatarImage.BorderSizePixel = 0
            avatarImage.Image = getAvatar()
            avatarImage.ZIndex = 1000001
            avatarImage.Parent = container

            local avatarCorner = Instance.new("UICorner")
            avatarCorner.CornerRadius = UDim.new(0, 12)
            avatarCorner.Parent = avatarImage

            -- เส้นแบ่งกลาง (เส้นตรงระหว่าง avatar กับข้อมูล)
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(0, 2, 0, 120)
            divider.Position = UDim2.new(0, 140, 0.5, -60)
            divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            divider.BorderSizePixel = 0
            divider.ZIndex = 1000001
            divider.Parent = container

            -- กล่องข้อมูลด้านขวา (Name / UserId / PlaceId)
            local infoFrame = Instance.new("Frame")
            infoFrame.Name = "InfoFrame"
            infoFrame.Size = UDim2.new(0, 260, 0, 120)
            infoFrame.Position = UDim2.new(0, 160, 0.5, -60)
            infoFrame.BackgroundTransparency = 1
            infoFrame.ZIndex = 1000001
            infoFrame.Parent = container

            local infoLayout = Instance.new("UIListLayout")
            infoLayout.FillDirection = Enum.FillDirection.Vertical
            infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            infoLayout.Padding = UDim.new(0, 8)
            infoLayout.Parent = infoFrame

            local function createInfoLabel(labelName, text)
                local lbl = Instance.new("TextLabel")
                lbl.Name = labelName
                lbl.Size = UDim2.new(1, 0, 0, 30)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 20
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 1000002
                lbl.Parent = infoFrame
                return lbl
            end

            createInfoLabel("NameLabel", "Name: " .. LocalPlayer.Name)
            createInfoLabel("UserIdLabel", "UserId: " .. tostring(LocalPlayer.UserId))
            createInfoLabel("PlaceIdLabel", "PlaceId: " .. tostring(game.PlaceId))

            if gethui then
                whiteScreenGui.Parent = gethui()
            else
                whiteScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
        else
            -- อัพเดตข้อมูลกรณี gui มีอยู่แล้ว (เผื่อ PlaceId/UserId เปลี่ยนหลัง teleport)
            local infoFrame = whiteScreenGui:FindFirstChild("InfoContainer", true)
            if infoFrame then
                local nameLbl = infoFrame:FindFirstChild("NameLabel", true)
                local uidLbl = infoFrame:FindFirstChild("UserIdLabel", true)
                local pidLbl = infoFrame:FindFirstChild("PlaceIdLabel", true)
                if nameLbl then nameLbl.Text = "Name: " .. LocalPlayer.Name end
                if uidLbl then uidLbl.Text = "UserId: " .. tostring(LocalPlayer.UserId) end
                if pidLbl then pidLbl.Text = "PlaceId: " .. tostring(game.PlaceId) end
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
