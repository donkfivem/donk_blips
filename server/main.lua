local blips = {}
local isLoaded = false

local function isPlayerAllowed(source)
    if Framework.name == 'qbcore' then
        local Player = Framework.object.Functions.GetPlayer(source)
        if not Player then return false end
        return Framework.object.Functions.HasPermission(source, 'god')
    elseif Framework.name == 'esx' then
        local xPlayer = Framework.object.GetPlayerFromId(source)
        if not xPlayer then return false end
        return xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
    else
        return true
    end
end

local function encodeData(blip)
    return json.encode({
        coords = blip.coords,
        groups = blip.groups,
        items = blip.items,
        hideUi = blip.hideUi,
        ftimer = blip.ftimer,
        sColor = blip.sColor,
        scImg = blip.scImg,
        Sprite = blip.Sprite,
        SpriteImg = blip.SpriteImg,
        scale = blip.scale,
        alpha = blip.alpha,
        colors = blip.colors,
        hideb = blip.hideb,
        tickb = blip.tickb,
        bflash = blip.bflash,
        sRange = blip.sRange,
        outline = blip.outline,
    })
end

local function createBlip(id, blip, name)
    blip.id = id
    blip.name = name
    blip.ftimer = tonumber(blip.ftimer)
    blip.coords = vector3(blip.coords.x, blip.coords.y, blip.coords.z)

    MySQL.update('UPDATE blips SET data = ? WHERE id = ?', { encodeData(blip), id })

    blips[id] = blip
    return blip
end

local function sendNotification(source, message, type)
    if Framework.name == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', source, message, type)
    elseif Framework.name == 'esx' then
        local xPlayer = Framework.object.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.showNotification(message)
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Blips',
            description = message,
            type = type
        })
    end
end

MySQL.ready(function()
    local success, result = pcall(MySQL.query.await, 'SELECT id, name, data FROM blips')

    if not success then
        success, result = pcall(MySQL.query, [[
            CREATE TABLE IF NOT EXISTS `blips` (
                `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
                `name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci',
                `data` LONGTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
                PRIMARY KEY (`id`) USING BTREE
            ) COLLATE='utf8mb4_unicode_ci' ENGINE=InnoDB;
        ]])

        if not success then
            return error('Failed to create blips table: ' .. tostring(result))
        end
    elseif result then
        for i = 1, #result do
            local blip = result[i]
            createBlip(blip.id, json.decode(blip.data), blip.name)
        end
    end

    isLoaded = true
    print('[donk_blips] Successfully loaded ' .. #result .. ' blips')
end)

RegisterNetEvent('blips:getBlips', function()
    local source = source

    while not isLoaded do
        Wait(100)
    end

    TriggerClientEvent('blips:setBlips', source, blips)
end)

RegisterNetEvent('blips:editBlip', function(id, data)
    local source = source

    if not isPlayerAllowed(source) then
        sendNotification(source, 'You do not have permission to manage blips', 'error')
        return
    end

    if data then
        if not data.coords then
            local ped = GetPlayerPed(source)
            data.coords = GetEntityCoords(ped)
        end

        if not data.name then
            data.name = tostring(data.coords)
        end
    end

    if id then
        if data then
            MySQL.update('UPDATE blips SET name = ?, data = ? WHERE id = ?', { data.name, encodeData(data), id })
            blips[id] = data
            TriggerClientEvent('blips:editBlip', -1, id, data)
            sendNotification(source, ('Blip (%s) has been updated'):format(data.name), 'success')
        else
            MySQL.update('DELETE FROM blips WHERE id = ?', { id })
            local blipName = blips[id] and blips[id].name or 'Unknown'
            blips[id] = nil
            TriggerClientEvent('blips:editBlip', -1, id, nil)
            sendNotification(source, ('Blip (%s) has been deleted'):format(blipName), 'success')
        end
    else
        local insertId = MySQL.insert.await('INSERT INTO blips (name, data) VALUES (?, ?)', { data.name, encodeData(data) })
        local blip = createBlip(insertId, data, data.name)

        TriggerClientEvent('blips:setBlip', -1, blip.id, false, blip)
        sendNotification(source, ('Blip (%s) has been created'):format(data.name), 'success')
    end
end)

CreateThread(function()
    Wait(1000)

    if config_blips == nil then return end

    print('[donk_blips] Migrating config blips to database...')

    for i = 1, #config_blips do
        local data = {
            coords = {
                x = config_blips[i].x,
                y = config_blips[i].y,
                z = config_blips[i].z,
            },
            hideb = false,
            items = 0,
            sColor = config_blips[i].colour,
            scImg = '',
            Sprite = config_blips[i].id,
            outline = false,
            sRange = true,
            bflash = false,
            colors = 0,
            scale = 7,
            alpha = 255,
            SpriteImg = '',
            ftimer = 50000,
            tickb = false,
        }

        MySQL.insert.await('INSERT INTO blips (name, data) VALUES (?, ?)', { config_blips[i].title, encodeData(data) })
    end

    print('[donk_blips] Migration complete!')
end)

lib.addCommand('blipsmenu', {
    help = 'Open blips management menu',
    restricted = 'group.admin'
}, function(source, args, raw)
    if isPlayerAllowed(source) then
        TriggerClientEvent('blips:openMenu', source)
    else
        sendNotification(source, 'You do not have permission to use this command', 'error')
    end
end)
