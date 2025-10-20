local blips = {}

function GetAllBlips()
    return blips
end

exports('GetAllBlips', GetAllBlips)

local function createBlip(blip)
    blip.zone = GetLabelText(GetNameOfZone(blip.coords.x, blip.coords.y, blip.coords.z))

    if not blip.hideUi then
        if blips[blip.id] and blips[blip.id].blipObj then
            RemoveBlip(blips[blip.id].blipObj)
        end

        blips[blip.id] = blips[blip.id] or {}
        blips[blip.id].blipObj = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)
        local newBlip = blips[blip.id].blipObj

        SetBlipSprite(newBlip, blip.Sprite)
        SetBlipScale(newBlip, blip.scale / 10)
        SetBlipColour(newBlip, blip.sColor)
        SetBlipAsShortRange(newBlip, blip.sRange)
        ShowTickOnBlip(newBlip, blip.tickb)
        ShowOutlineIndicatorOnBlip(newBlip, blip.outline)
        SetBlipAlpha(newBlip, blip.alpha)

        if blip.bflash then
            SetBlipFlashes(newBlip, true)
            SetBlipFlashInterval(newBlip, tonumber(blip.ftimer))
        end

        if blip.hideb then
            SetBlipDisplay(newBlip, 3)
        else
            SetBlipDisplay(newBlip, 2)
        end

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.name)
        EndTextCommandSetBlipName(newBlip)
    else
        if blips[blip.id] and blips[blip.id].blipObj then
            RemoveBlip(blips[blip.id].blipObj)
            blips[blip.id].blipObj = nil
        end
    end
end

CreateThread(function()
    Wait(1000)
    TriggerServerEvent('blips:getBlips')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('blips:getBlips')
end)

RegisterNetEvent('esx:playerLoaded', function()
    TriggerServerEvent('blips:getBlips')
end)

RegisterNetEvent('blips:setBlips', function(data)
    blips = data

    for _, blip in pairs(data) do
        createBlip(blip)
    end

    local success, err = pcall(function()
        exports['donk_blips']:UpdateBlipsCache(data)
    end)
    if not success then
        print('[donk_blips] Error updating cache: ' .. tostring(err))
    end
end)

RegisterNetEvent('blips:setBlip', function(id, source, data)
    if not blips then return end

    if data then
        blips[id] = data
        createBlip(data)

        if NuiHasLoaded then
            SendNuiMessage(json.encode({
                action = 'updateBlipData',
                data = data
            }))
        end

        local success, err = pcall(function()
            exports['donk_blips']:UpdateBlipsCache(blips)
        end)
        if not success then
            print('[donk_blips] Error updating cache: ' .. tostring(err))
        end
    end
end)

RegisterNetEvent('blips:editBlip', function(id, data)
    if source == '' then return end

    local blip = blips[id]

    if data then
        data.zone = blip and blip.zone or GetLabelText(GetNameOfZone(data.coords.x, data.coords.y, data.coords.z))
    end

    if data == nil then
        if blip and blip.blipObj then
            RemoveBlip(blip.blipObj)
        end
        blips[id] = nil

        SendNuiMessage(json.encode({
            action = 'updateBlipData',
            data = id
        }))

        local success, err = pcall(function()
            exports['donk_blips']:UpdateBlipsCache(blips)
        end)
        if not success then
            print('[donk_blips] Error updating cache: ' .. tostring(err))
        end
        return
    end

    blips[id] = data
    createBlip(data)

    if NuiHasLoaded then
        SendNuiMessage(json.encode({
            action = 'updateBlipData',
            data = data
        }))
    end

    local success, err = pcall(function()
        exports['donk_blips']:UpdateBlipsCache(blips)
    end)
    if not success then
        print('[donk_blips] Error updating cache: ' .. tostring(err))
    end
end)
