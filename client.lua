Config = Config or {}
Config.framework = Config.framework or "esx" -- "esx", "qbcore", "qbox"

local Framework = nil

function SendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

if Config.framework == "esx" then
    Framework = exports["es_extended"]:getSharedObject()
elseif Config.framework == "qbcore" then
    Framework = exports["qb-core"]:GetCoreObject()
elseif Config.framework == "qbox" then
    Framework = exports["qbx-core"]:GetCoreObject()
end

RegisterNUICallback('getInfoOfChar', function(_, cb)
    if LocalPlayer.state.invOpen == true then
        cb({})
        return
    end

    local playerData
    if Config.framework == "esx" then
        playerData = Framework.GetPlayerData()
        local Name = playerData.firstname or (playerData.charinfo and playerData.charinfo.firstname) or (playerData.name or "")
        local SecondName = playerData.lastname or (playerData.charinfo and playerData.charinfo.lastname) or ""
        local Birthday = playerData.dateofbirth or (playerData.charinfo and playerData.charinfo.birthdate) or ""
        cb({
            Name = Name,
            SecondName = SecondName,
            Birthday = Birthday
        })
    elseif Config.framework == "qbcore" or Config.framework == "qbox" then
        playerData = Framework.Functions.GetPlayerData()
        local Name = playerData.charinfo and playerData.charinfo.firstname or ""
        local SecondName = playerData.charinfo and playerData.charinfo.lastname or ""
        local Birthday = playerData.charinfo and playerData.charinfo.birthdate or ""
        cb({
            Name = Name,
            SecondName = SecondName,
            Birthday = Birthday
        })
    else
        cb({})
    end
end)

OnlinePlayer = "0 / " .. (Config.maxPlayer or 64)
Config = Config or {}

local quitClickCount = 0
local quitClickTimer = nil

local function ShowNotification(msg)
    if Config.framework == "esx" then
        Framework.ShowNotification(msg)
    elseif Config.framework == "qbcore" or Config.framework == "qbox" then
        Framework.Functions.Notify(msg, "primary")
    end
end

RegisterNetEvent('OnlinePlayers')
AddEventHandler('OnlinePlayers', function(onlinePlayers)
    OnlinePlayer = onlinePlayers .. "/" .. Config.maxPlayer
end)

local function toggleNuiFrame(shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

local function setPage(pageName)
    toggleNuiFrame(true)
    SendReactMessage('setPage', pageName)
end

RegisterNUICallback('hideFrame', function(_, cb)
    SetNuiFocus(false, false)
    setPage('')
    cb({})
end)

RegisterNUICallback('openKeybinds', function(_, cb)
    setPage('')
    SetNuiFocus(false, false)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_KEYMAPPING_MENU'),0,-1)
    cb({})
end)

RegisterNUICallback('openSettings', function(_, cb)
    setPage('')
    SetNuiFocus(false, false)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'),0,8)
    cb({})
end)

RegisterNUICallback('openMap', function(_, cb)
    setPage('')
    SetNuiFocus(false, false)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'),0,-1) 
    cb({})
end)

RegisterNUICallback('getPlayers', function(_,cb)
    cb({OnlinePlayer})
end)

RegisterNUICallback('quit', function(_, cb)
    quitClickCount = quitClickCount + 1

    if quitClickCount == 1 then
        ShowNotification(Config.quitFirstClickMessage or "Click again on Quit to disconnect from the server.")

        if quitClickTimer then
            if quitClickTimer.cancel then quitClickTimer:cancel() end
        end
        quitClickTimer = Citizen.SetTimeout(5000, function()
            quitClickCount = 0
        end)
        cb({})
        return
    end

    SetNuiFocus(false, false)
    setPage('')
    TriggerServerEvent('player:disconnect')
    quitClickCount = 0
    cb({})
end)

Config = Config or {}

RegisterNUICallback('getInfoOfServer', function(_,cb)
    cb({Config})
end)


RegisterKeyMapping('show-nui', Config.pauseMenuOpenLabel or 'Open PauseMenu', 'keyboard', 'ESCAPE')

RegisterCommand('show-nui', function()

    if IsNuiFocused() then return end
    
    if IsPauseMenuActive() or LocalPlayer.state.invOpen == true then 
        return
     end

     
    SetNuiFocus(true, true)
    setPage('pausemenu')
end)

Citizen.CreateThread(function()
    while true do
        SetPauseMenuActive(false)
        Wait(0)
    end
  end)

-- Hidden resource name check (silent block)
local _r = GetCurrentResourceName()
if _r ~= "aPauseMenu" then
    -- Prevent further execution silently
    return
end