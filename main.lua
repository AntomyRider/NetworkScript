local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- PlaceId ของ Blox Fruits
local BLOX_FRUITS_PLACE_ID = 2753915549

local function getAvatar()
    return Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size150x150
    )
end

while task.wait(5) do
    local payload = {
        name = LocalPlayer.Name,
        jobId = game.JobId,
        placeId = game.PlaceId,
        status = "online",
        avatar = getAvatar()
    }

    -- ส่งข้อมูลเฉพาะเมื่ออยู่ใน Blox Fruits
    if game.PlaceId == BLOX_FRUITS_PLACE_ID then
        local data = LocalPlayer:WaitForChild("Data")

        payload.data = {
            beli = data.Beli.Value,
            fragments = data.Fragments.Value,
            level = data.Level.Value
        }

        payload.description = table.concat({
            "⭐ Level: " .. data.Level.Value,
            "💰 Beli: " .. data.Beli.Value,
            "🟣 Fragments: " .. data.Fragments.Value,
        }, "\n")
    end

    print(HttpService:JSONEncode(payload))

end
