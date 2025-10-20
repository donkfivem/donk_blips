-- Initialize blips table on resource start
CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `donk_blips` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `name` VARCHAR(100) NOT NULL,
            `x` FLOAT NOT NULL,
            `y` FLOAT NOT NULL,
            `z` FLOAT NOT NULL,
            `sprite` INT NOT NULL,
            `color` INT NOT NULL,
            `scale` FLOAT NOT NULL DEFAULT 0.8,
            `created_by` VARCHAR(50) NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- Framework detection and helper functions
local Framework = nil
local FrameworkName = nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = exports['es_extended']:getSharedObject()
        FrameworkName = 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        Framework = exports['qb-core']:GetCoreObject()
        FrameworkName = 'qbcore'
    end
end)

-- Get player identifier
local function GetPlayerIdentifier(source)
    if FrameworkName == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    elseif FrameworkName == 'qbcore' then
        local Player = Framework.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
    return nil
end

-- Check if player has admin permission
local function HasAdminPermission(source)
    local hasPermission = false

    if FrameworkName == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            for _, group in ipairs(Config.AdminGroups) do
                if xPlayer.getGroup() == group then
                    hasPermission = true
                    break
                end
            end
        end
    elseif FrameworkName == 'qbcore' then
        hasPermission = Framework.Functions.HasPermission(source, Config.AdminPermission)
    end

    return hasPermission
end

-- Send notification
local function SendNotify(source, message, type)
    lib.notify(source, {
        title = 'Blip Manager',
        description = message,
        type = type
    })
end

-- Get all blips from database
lib.callback.register('donk_blips:server:getBlips', function(source)
    local result = MySQL.query.await('SELECT * FROM donk_blips')
    return result or {}
end)

-- Add new blip
RegisterNetEvent('donk_blips:server:addBlip', function(data)
    local src = source

    -- Check if player has admin permission
    if not HasAdminPermission(src) then
        SendNotify(src, 'You do not have permission to use this command', 'error')
        return
    end

    local identifier = GetPlayerIdentifier(src)
    if not identifier then
        SendNotify(src, 'Failed to get player identifier', 'error')
        return
    end

    local insertId = MySQL.insert.await('INSERT INTO donk_blips (name, x, y, z, sprite, color, scale, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        data.name,
        data.coords.x,
        data.coords.y,
        data.coords.z,
        data.sprite,
        data.color,
        data.scale,
        identifier
    })

    if insertId then
        SendNotify(src, 'Blip created successfully!', 'success')
        TriggerClientEvent('donk_blips:client:refreshBlips', -1) -- Refresh for all players
    else
        SendNotify(src, 'Failed to create blip', 'error')
    end
end)

-- Delete blip
RegisterNetEvent('donk_blips:server:deleteBlip', function(blipId)
    local src = source

    -- Check if player has admin permission
    if not HasAdminPermission(src) then
        SendNotify(src, 'You do not have permission to use this command', 'error')
        return
    end

    local deleted = MySQL.query.await('DELETE FROM donk_blips WHERE id = ?', {blipId})

    if deleted then
        SendNotify(src, 'Blip deleted successfully!', 'success')
        TriggerClientEvent('donk_blips:client:refreshBlips', -1) -- Refresh for all players
    else
        SendNotify(src, 'Failed to delete blip', 'error')
    end
end)

-- Check admin permission callback
lib.callback.register('donk_blips:server:checkAdmin', function(source)
    return HasAdminPermission(source)
end)

-- Register admin command
lib.addCommand(Config.AdminCommand, {
    help = 'Open Blip Management Menu (Admin Only)',
    restricted = 'group.admin'
}, function(source, args, raw)
    if HasAdminPermission(source) then
        TriggerClientEvent('donk_blips:client:openAdminMenu', source)
    else
        SendNotify(source, 'You do not have permission to use this command', 'error')
    end
end)
