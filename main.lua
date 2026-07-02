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
local ACCENT_BLUE = Color3.fromRGB(0, 162, 255)

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
            frame.BackgroundTransparency = 0
            frame.BorderSizePixel = 0
            frame.ZIndex = 999999
            frame.Parent = whiteScreenGui

            -- กล่อง Profile หลัก (มี bg)
            local container = Instance.new("Frame")
            container.Name = "InfoContainer"
            container.Size = UDim2.new(0, 440, 0, 190)
            container.AnchorPoint = Vector2.new(0.5, 0.5)
            container.Position = UDim2.new(0.5, 0, 0.5, 0)
            container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            container.BackgroundTransparency = 0
            container.BorderSizePixel = 0
            container.ZIndex = 1000000
            container.Parent = frame

            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 14)
            containerCorner.Parent = container

            local containerPadding = Instance.new("UIPadding")
            containerPadding.PaddingLeft = UDim.new(0, 20)
            containerPadding.PaddingRight = UDim.new(0, 20)
            containerPadding.PaddingTop = UDim.new(0, 16)
            containerPadding.PaddingBottom = UDim.new(0, 16)
            containerPadding.Parent = container

            -- แถวบน: Network icon (ซ้าย) + ข้อความ Network (ขวาของ icon)
            local networkRow = Instance.new("Frame")
            networkRow.Name = "NetworkRow"
            networkRow.Size = UDim2.new(1, 0, 0, 36)
            networkRow.Position = UDim2.new(0, 0, 0, 0)
            networkRow.BackgroundTransparency = 1
            networkRow.ZIndex = 1000001
            networkRow.Parent = container

            local networkIcon = Instance.new("ImageLabel")
            networkIcon.Name = "NetworkIcon"
            networkIcon.Size = UDim2.new(0, 36, 0, 36)
            networkIcon.Position = UDim2.new(0, 0, 0, 0)
            networkIcon.BackgroundTransparency = 1
            networkIcon.Image = WHITE_SCREEN_IMAGE
            networkIcon.ZIndex = 1000002
            networkIcon.Parent = networkRow

            local networkText = Instance.new("TextLabel")
            networkText.Name = "NetworkText"
            networkText.Size = UDim2.new(0, 150, 0, 36)
            networkText.Position = UDim2.new(0, 46, 0, 0)
            networkText.BackgroundTransparency = 1
            networkText.Text = WHITE_SCREEN_TEXT
            networkText.TextColor3 = ACCENT_BLUE
            networkText.Font = Enum.Font.FredokaOne
            networkText.TextSize = 22
            networkText.TextXAlignment = Enum.TextXAlignment.Left
            networkText.ZIndex = 1000002
            networkText.Parent = networkRow

            -- แถวล่าง: Avatar ซ้าย | ข้อมูล ขวา
            local bottomRow = Instance.new("Frame")
            bottomRow.Name = "BottomRow"
            bottomRow.Size = UDim2.new(1, 0, 0, 120)
            bottomRow.Position = UDim2.new(0, 0, 0, 46)
            bottomRow.BackgroundTransparency = 1
            bottomRow.ZIndex = 1000001
            bottomRow.Parent = container

            -- Avatar รูปโปรไฟล์
            local avatarImage = Instance.new("ImageLabel")
            avatarImage.Name = "AvatarImage"
            avatarImage.Size = UDim2.new(0, 110, 0, 110)
            avatarImage.Position = UDim2.new(0, 0, 0, 0)
            avatarImage.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            avatarImage.BorderSizePixel = 0
            avatarImage.Image = getAvatar()
            avatarImage.ZIndex = 1000002
            avatarImage.Parent = bottomRow

            local avatarCorner = Instance.new("UICorner")
            avatarCorner.CornerRadius = UDim.new(0, 12)
            avatarCorner.Parent = avatarImage

            -- กล่องข้อมูลด้านขวา (Name / UserId / PlaceId)
            local infoFrame = Instance.new("Frame")
            infoFrame.Name = "InfoFrame"
            infoFrame.Size = UDim2.new(1, -130, 1, 0)
            infoFrame.Position = UDim2.new(0, 130, 0, 0)
            infoFrame.BackgroundTransparency = 1
            infoFrame.ZIndex = 1000001
            infoFrame.Parent = bottomRow

            local infoLayout = Instance.new("UIListLayout")
            infoLayout.FillDirection = Enum.FillDirection.Vertical
            infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            infoLayout.Padding = UDim.new(0, 10)
            infoLayout.Parent = infoFrame

            -- หัวข้อสีฟ้า + ค่าสีขาว ในบรรทัดเดียวกัน
            local function createInfoRow(rowName, labelText, valueText)
                local row = Instance.new("Frame")
                row.Name = rowName
                row.Size = UDim2.new(1, 0, 0, 24)
                row.BackgroundTransparency = 1
                row.ZIndex = 1000002
                row.Parent = infoFrame

                local rowLayout = Instance.new("UIListLayout")
                rowLayout.FillDirection = Enum.FillDirection.Horizontal
                rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                rowLayout.Padding = UDim.new(0, 6)
                rowLayout.Parent = row

                local headLbl = Instance.new("TextLabel")
                headLbl.Name = "Header"
                headLbl.Size = UDim2.new(0, 70, 1, 0)
                headLbl.BackgroundTransparency = 1
                headLbl.Text = labelText
                headLbl.TextColor3 = ACCENT_BLUE
                headLbl.Font = Enum.Font.GothamBold
                headLbl.TextSize = 18
                headLbl.TextXAlignment = Enum.TextXAlignment.Left
                headLbl.ZIndex = 1000003
                headLbl.Parent = row

                local valLbl = Instance.new("TextLabel")
                valLbl.Name = "Value"
                valLbl.Size = UDim2.new(0, 180, 1, 0)
                valLbl.BackgroundTransparency = 1
                valLbl.Text = valueText
                valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                valLbl.Font = Enum.Font.Gotham
                valLbl.TextSize = 18
                valLbl.TextXAlignment = Enum.TextXAlignment.Left
                valLbl.ZIndex = 1000003
                valLbl.Parent = row

                return row, valLbl
            end

            createInfoRow("NameRow", "Name:", LocalPlayer.Name)
            createInfoRow("UserIdRow", "UserId:", tostring(LocalPlayer.UserId))
            createInfoRow("PlaceIdRow", "PlaceId:", tostring(game.PlaceId))

            if gethui then
                whiteScreenGui.Parent = gethui()
            else
                whiteScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
        else
            -- อัพเดตข้อมูลกรณี gui มีอยู่แล้ว
            local nameRow = whiteScreenGui:FindFirstChild("NameRow", true)
            local uidRow = whiteScreenGui:FindFirstChild("UserIdRow", true)
            local pidRow = whiteScreenGui:FindFirstChild("PlaceIdRow", true)
            if nameRow then
                local v = nameRow:FindFirstChild("Value")
                if v then v.Text = LocalPlayer.Name end
            end
            if uidRow then
                local v = uidRow:FindFirstChild("Value")
                if v then v.Text = tostring(LocalPlayer.UserId) end
            end
            if pidRow then
                local v = pidRow:FindFirstChild("Value")
                if v then v.Text = tostring(game.PlaceId) end
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

local placeName = "Unknown"
pcall(function()
    placeName = game.Name -- ดึงชื่อแมพได้ทันที ปลอดภัยและไม่พัง
end)

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
            .. "&map=" .. HttpService:UrlEncode(placeName) -- ส่งข้อมูลชื่อแมพไปที่เซิร์ฟเวอร์
        game:HttpGet(url)
    end)

    task.wait(5)
end
