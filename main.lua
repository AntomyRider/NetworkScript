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

    pcall(function()
        local url = "http://127.0.0.1:3000/status"
            .. "?name=" .. name
            .. "&jobid=" .. jobId
            .. "&status=" .. status
            .. "&avatar=" .. game:GetService("HttpService"):UrlEncode(avatar)

        game:HttpGet(url)
    end)

    task.wait(5)
end
