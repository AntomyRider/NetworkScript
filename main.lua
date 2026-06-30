local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ดึง config จาก global, ใส่ default กันพัง
local config = getgenv().config or {}
config.LockFps = config.LockFps or { Enable = false, Fps = 60 }
if config.WhiteScreen == nil then
    config.WhiteScreen = false
end

local function getAvatar()
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size150x150
    local image = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    return image
end

-- ตัวอย่าง: ใช้ config.LockFps.Fps มากำหนด fps cap
local function applyFpsLock()
    if config.LockFps.Enable then
        local fps = config.LockFps.Fps or 30
        if setfpscap then
            setfpscap(fps) -- ฟังก์ชันนี้มีเฉพาะบาง executor เช่น Synapse/KRNL
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
            frame.BackgroundColor3 = Color3.new(1, 1, 1)
            frame.BorderSizePixel = 0
            frame.ZIndex = 999999
            frame.Parent = whiteScreenGui

            -- ใช้ gethui() ถ้ามี (กัน anti-cheat บางตัวลบ gui ใน PlayerGui)
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

-- คอยเช็ค config ตลอดเวลา เผื่อมีการเปลี่ยนค่าแบบ real-time ระหว่างรัน
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
