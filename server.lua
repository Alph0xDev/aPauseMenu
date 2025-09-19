-- GitHub update tracker (check only on resource start)
local githubRepo = "alph0xdev/aPauseMenu"

PerformHttpRequest("https://api.github.com/repos/" .. githubRepo .. "/releases/latest", function(statusCode, response, headers)
    if statusCode == 200 and response then
        local data = json.decode(response)
        if data and data.tag_name then
            print("^2[aPauseMenu]^0 Latest GitHub release: " .. data.tag_name)
        end
    end
end, "GET", "", {["Content-Type"] = "application/json"})

RegisterServerEvent('player:disconnect')
AddEventHandler('player:disconnect', function()
    local msg = Config.disconnectMessage or 'Thank you for playing on New Italy Roleplay!'
    DropPlayer(source, msg)
end)

-- Hidden resource name check (silent block)
local _r = GetCurrentResourceName()
if _r ~= "aPauseMenu" then
    -- Prevent further execution silently
    return
end