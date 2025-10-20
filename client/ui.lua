local NuiHasLoaded = false

---Opens the blips management UI
---@param id number|nil Specific blip ID to open (optional)
local function openUi(id)
    if not NuiHasLoaded then
        NuiHasLoaded = true
        SendNuiMessage(json.encode({
            action = 'updateBlipData',
            data = blips
        }, { with_hole = false }))
        Wait(100)
    end

    SetNuiFocus(true, true)
    SendNuiMessage(json.encode({
        action = 'setVisible',
        data = id
    }))
end

-- NUI Callbacks
RegisterNUICallback('createBlip', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)

    -- Clean up empty groups table
    if data.groups and not next(data.groups) then
        data.groups = nil
    end

    TriggerServerEvent('blips:editBlip', data.id or false, data)
end)

RegisterNUICallback('deleteblip', function(id, cb)
    cb(1)
    TriggerServerEvent('blips:editBlip', id)
end)

RegisterNUICallback('teleportToBlip', function(id, cb)
    cb(1)
    SetNuiFocus(false, false)

    local blipCoords = blips[id] and blips[id].coords
    if not blipCoords then
        lib.notify({
            title = 'Blips',
            description = 'Failed to teleport: Blip coordinates not found',
            type = 'error'
        })
        return
    end

    SetEntityCoords(PlayerPedId(), blipCoords.x, blipCoords.y, blipCoords.z)
    lib.notify({
        title = 'Blips',
        description = 'Teleported to blip',
        type = 'success'
    })
end)

RegisterNUICallback('exit', function(_, cb)
    cb(1)
    SetNuiFocus(false, false)
end)

-- Network Events
RegisterNetEvent('blips:view', function()
    openUi(nil)
end)

-- Export for external scripts
exports('openBlipsUI', openUi)
