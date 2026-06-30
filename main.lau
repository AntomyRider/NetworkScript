local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getAvatar()
    local userId = LocalPlayer.UserId

    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size150x150

    local image = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    return image
end

while true do
    local name = LocalPlayer.Name
    local jobId = game.JobId
    local status = "online"
    local avatar = getAvatar()

    task.wait(5)
end
