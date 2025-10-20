local blipsCache = {}

---Updates the local blips cache
---@param data table Blips data from server
local function UpdateBlipsCache(data)
    blipsCache = data
    local count = 0
    for id, blip in pairs(data or {}) do
        count = count + 1
        print('[donk_blips] Cached blip ID: ' .. tostring(id) .. ' Name: ' .. tostring(blip.name))
    end
    print('[donk_blips] Cache updated with ' .. count .. ' blips')
end

-- Export the update function
exports('UpdateBlipsCache', UpdateBlipsCache)

---Get all blips as options for selection
---@return table options
local function getAllBlipsOptions()
    local options = {}

    for id, blip in pairs(blipsCache) do
        table.insert(options, {
            value = tostring(id),
            label = blip.name .. ' (ID: ' .. id .. ')'
        })
    end

    if #options == 0 then
        table.insert(options, {
            value = 'none',
            label = 'No blips available'
        })
    end

    return options
end

---Opens the main blips menu
local function openBlipsMenu()
    -- Ensure cache is updated before opening menu
    local currentBlips = exports['donk_blips']:GetAllBlips()
    if currentBlips then
        blipsCache = currentBlips
        local count = 0
        for _ in pairs(blipsCache) do
            count = count + 1
        end
        print('[donk_blips] Menu opened. Loaded ' .. count .. ' blips')
    end

    lib.registerContext({
        id = 'blips_main_menu',
        title = 'Blips Management',
        options = {
            {
                title = 'Place New Blip',
                description = 'Create a new blip at your current location',
                icon = 'map-marker-alt',
                onSelect = function()
                    openPlaceBlipMenu()
                end
            },
            {
                title = 'Modify Blip',
                description = 'Edit an existing blip',
                icon = 'edit',
                onSelect = function()
                    openModifyBlipSelect()
                end
            },
            {
                title = 'Delete Blip',
                description = 'Remove a blip from the map',
                icon = 'trash',
                onSelect = function()
                    openDeleteBlipSelect()
                end
            },
            {
                title = 'List All Blips',
                description = 'View all existing blips',
                icon = 'list',
                onSelect = function()
                    openListBlipsMenu()
                end
            },
            {
                title = 'Teleport to Blip',
                description = 'Teleport to a blip location',
                icon = 'location-arrow',
                onSelect = function()
                    openTeleportBlipSelect()
                end
            }
        }
    })

    lib.showContext('blips_main_menu')
end

---Opens the place blip menu
function openPlaceBlipMenu()
    local input = lib.inputDialog('Place New Blip', {
        {
            type = 'input',
            label = 'Blip Name',
            description = 'Enter the name for this blip',
            required = true,
            min = 1,
            max = 50
        },
        {
            type = 'number',
            label = 'Blip Sprite',
            description = 'Sprite ID (see FiveM docs)',
            min = 0,
            max = 826,
            default = 1,
            required = true
        },
        {
            type = 'number',
            label = 'Blip Color',
            description = 'Color ID (0-85)',
            min = 0,
            max = 85,
            default = 0,
            required = true
        },
        {
            type = 'slider',
            label = 'Blip Scale',
            description = 'Set the blip size (1-20)',
            min = 1,
            max = 20,
            default = 7,
            required = true
        },
        {
            type = 'slider',
            label = 'Blip Alpha',
            description = 'Set the blip transparency (0-255)',
            min = 0,
            max = 255,
            default = 255,
            required = true
        },
        {
            type = 'checkbox',
            label = 'Short Range',
            description = 'Only show blip when close',
            checked = true
        },
        {
            type = 'checkbox',
            label = 'Show Tick',
            description = 'Show checkmark on blip',
            checked = false
        },
        {
            type = 'checkbox',
            label = 'Show Outline',
            description = 'Show outline around blip',
            checked = false
        },
        {
            type = 'checkbox',
            label = 'Flash Blip',
            description = 'Make the blip flash',
            checked = false
        },
        {
            type = 'number',
            label = 'Flash Timer (ms)',
            description = 'Flash interval in milliseconds',
            min = 100,
            max = 10000,
            default = 500,
            required = true
        }
    })

    if not input then
        openBlipsMenu()
        return
    end

    local coords = GetEntityCoords(PlayerPedId())

    local blipData = {
        name = input[1],
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        Sprite = tonumber(input[2]),
        sColor = tonumber(input[3]),
        scale = tonumber(input[4]),
        alpha = tonumber(input[5]),
        sRange = input[6],
        tickb = input[7],
        outline = input[8],
        bflash = input[9],
        ftimer = tonumber(input[10]),
        hideb = false,
        hideUi = false,
        groups = {},
        items = 0,
        scImg = '',
        SpriteImg = '',
        colors = 0
    }

    TriggerServerEvent('blips:editBlip', nil, blipData)

    lib.notify({
        title = 'Blips',
        description = 'Blip creation request sent!',
        type = 'success'
    })

    Wait(500)
    openBlipsMenu()
end

---Opens the modify blip selection menu
function openModifyBlipSelect()
    local options = getAllBlipsOptions()

    if options[1].value == 'none' then
        lib.notify({
            title = 'Blips',
            description = 'No blips available to modify',
            type = 'error'
        })
        openBlipsMenu()
        return
    end

    local input = lib.inputDialog('Select Blip to Modify', {
        {
            type = 'select',
            label = 'Select Blip',
            description = 'Choose which blip to modify',
            options = options,
            required = true
        }
    })

    if not input then
        openBlipsMenu()
        return
    end

    local blipId = tonumber(input[1])
    openModifyBlipMenu(blipId)
end

---Opens the modify menu for a specific blip
---@param blipId number The ID of the blip to modify
function openModifyBlipMenu(blipId)
    local blip = blipsCache[blipId]

    if not blip then
        lib.notify({
            title = 'Blips',
            description = 'Blip not found!',
            type = 'error'
        })
        openBlipsMenu()
        return
    end

    local input = lib.inputDialog('Modify Blip: ' .. blip.name, {
        {
            type = 'input',
            label = 'Blip Name',
            description = 'Enter the name for this blip',
            default = blip.name,
            required = true,
            min = 1,
            max = 50
        },
        {
            type = 'number',
            label = 'Blip Sprite',
            description = 'Sprite ID (see FiveM docs)',
            min = 0,
            max = 826,
            default = blip.Sprite,
            required = true
        },
        {
            type = 'number',
            label = 'Blip Color',
            description = 'Color ID (0-85)',
            min = 0,
            max = 85,
            default = blip.sColor,
            required = true
        },
        {
            type = 'slider',
            label = 'Blip Scale',
            description = 'Set the blip size (1-20)',
            min = 1,
            max = 20,
            default = blip.scale,
            required = true
        },
        {
            type = 'slider',
            label = 'Blip Alpha',
            description = 'Set the blip transparency (0-255)',
            min = 0,
            max = 255,
            default = blip.alpha,
            required = true
        },
        {
            type = 'checkbox',
            label = 'Short Range',
            description = 'Only show blip when close',
            checked = blip.sRange
        },
        {
            type = 'checkbox',
            label = 'Show Tick',
            description = 'Show checkmark on blip',
            checked = blip.tickb
        },
        {
            type = 'checkbox',
            label = 'Show Outline',
            description = 'Show outline around blip',
            checked = blip.outline
        },
        {
            type = 'checkbox',
            label = 'Flash Blip',
            description = 'Make the blip flash',
            checked = blip.bflash
        },
        {
            type = 'number',
            label = 'Flash Timer (ms)',
            description = 'Flash interval in milliseconds',
            min = 100,
            max = 10000,
            default = blip.ftimer,
            required = true
        },
        {
            type = 'checkbox',
            label = 'Update Coordinates',
            description = 'Update to your current location',
            checked = false
        }
    })

    if not input then
        openBlipsMenu()
        return
    end

    local coords = blip.coords

    if input[11] then
        local newCoords = GetEntityCoords(PlayerPedId())
        coords = {
            x = newCoords.x,
            y = newCoords.y,
            z = newCoords.z
        }
    end

    local blipData = {
        id = blipId,
        name = input[1],
        coords = coords,
        Sprite = tonumber(input[2]),
        sColor = tonumber(input[3]),
        scale = tonumber(input[4]),
        alpha = tonumber(input[5]),
        sRange = input[6],
        tickb = input[7],
        outline = input[8],
        bflash = input[9],
        ftimer = tonumber(input[10]),
        hideb = blip.hideb or false,
        hideUi = blip.hideUi or false,
        groups = blip.groups or {},
        items = blip.items or 0,
        scImg = blip.scImg or '',
        SpriteImg = blip.SpriteImg or '',
        colors = blip.colors or 0
    }

    TriggerServerEvent('blips:editBlip', blipId, blipData)

    lib.notify({
        title = 'Blips',
        description = 'Blip modification request sent!',
        type = 'success'
    })

    Wait(500)
    openBlipsMenu()
end

---Opens the delete blip selection menu
function openDeleteBlipSelect()
    local options = getAllBlipsOptions()

    if options[1].value == 'none' then
        lib.notify({
            title = 'Blips',
            description = 'No blips available to delete',
            type = 'error'
        })
        openBlipsMenu()
        return
    end

    local input = lib.inputDialog('Select Blip to Delete', {
        {
            type = 'select',
            label = 'Select Blip',
            description = 'Choose which blip to delete',
            options = options,
            required = true
        }
    })

    if not input then
        openBlipsMenu()
        return
    end

    local blipId = tonumber(input[1])
    local blip = blipsCache[blipId]

    if not blip then
        lib.notify({
            title = 'Blips',
            description = 'Blip not found!',
            type = 'error'
        })
        openBlipsMenu()
        return
    end

    local confirm = lib.alertDialog({
        header = 'Delete Blip',
        content = 'Are you sure you want to delete "' .. blip.name .. '"?',
        centered = true,
        cancel = true
    })

    if confirm == 'confirm' then
        TriggerServerEvent('blips:editBlip', blipId, nil)

        lib.notify({
            title = 'Blips',
            description = 'Blip deletion request sent!',
            type = 'success'
        })
    end

    Wait(500)
    openBlipsMenu()
end

---Opens the list all blips menu
function openListBlipsMenu()
    local options = {}

    for id, blip in pairs(blipsCache) do
        table.insert(options, {
            title = blip.name,
            description = 'ID: ' .. id .. ' | Coords: ' .. string.format('%.2f, %.2f, %.2f', blip.coords.x, blip.coords.y, blip.coords.z),
            icon = 'map-marker',
            onSelect = function()
                openBlipDetailsMenu(id)
            end
        })
    end

    if #options == 0 then
        lib.notify({
            title = 'Blips',
            description = 'No blips available',
            type = 'info'
        })
        openBlipsMenu()
        return
    end

    lib.registerContext({
        id = 'blips_list_menu',
        title = 'All Blips',
        menu = 'blips_main_menu',
        options = options
    })

    lib.showContext('blips_list_menu')
end

---Opens the details menu for a specific blip
---@param blipId number The ID of the blip
function openBlipDetailsMenu(blipId)
    local blip = blipsCache[blipId]

    if not blip then
        lib.notify({
            title = 'Blips',
            description = 'Blip not found!',
            type = 'error'
        })
        openListBlipsMenu()
        return
    end

    lib.registerContext({
        id = 'blip_details_menu',
        title = blip.name,
        menu = 'blips_list_menu',
        options = {
            {
                title = 'Information',
                description = 'ID: ' .. blipId,
                icon = 'info-circle',
                disabled = true
            },
            {
                title = 'Coordinates',
                description = string.format('X: %.2f, Y: %.2f, Z: %.2f', blip.coords.x, blip.coords.y, blip.coords.z),
                icon = 'map-pin',
                disabled = true
            },
            {
                title = 'Sprite ID',
                description = tostring(blip.Sprite),
                icon = 'image',
                disabled = true
            },
            {
                title = 'Color',
                description = tostring(blip.sColor),
                icon = 'palette',
                disabled = true
            },
            {
                title = 'Teleport to Blip',
                description = 'Teleport to this blip location',
                icon = 'location-arrow',
                onSelect = function()
                    SetEntityCoords(PlayerPedId(), blip.coords.x, blip.coords.y, blip.coords.z)
                    lib.notify({
                        title = 'Blips',
                        description = 'Teleported to ' .. blip.name,
                        type = 'success'
                    })
                end
            },
            {
                title = 'Modify Blip',
                description = 'Edit this blip',
                icon = 'edit',
                onSelect = function()
                    openModifyBlipMenu(blipId)
                end
            },
            {
                title = 'Delete Blip',
                description = 'Remove this blip',
                icon = 'trash',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Delete Blip',
                        content = 'Are you sure you want to delete "' .. blip.name .. '"?',
                        centered = true,
                        cancel = true
                    })

                    if confirm == 'confirm' then
                        TriggerServerEvent('blips:editBlip', blipId, nil)

                        lib.notify({
                            title = 'Blips',
                            description = 'Blip deleted successfully!',
                            type = 'success'
                        })

                        Wait(500)
                        openListBlipsMenu()
                    else
                        openBlipDetailsMenu(blipId)
                    end
                end
            }
        }
    })

    lib.showContext('blip_details_menu')
end

---Opens the teleport blip selection menu
function openTeleportBlipSelect()
    local options = getAllBlipsOptions()

    if options[1].value == 'none' then
        lib.notify({
            title = 'Blips',
            description = 'No blips available',
            type = 'error'
        })
        openBlipsMenu()
        return
    end

    local input = lib.inputDialog('Teleport to Blip', {
        {
            type = 'select',
            label = 'Select Blip',
            description = 'Choose which blip to teleport to',
            options = options,
            required = true
        }
    })

    if not input then
        openBlipsMenu()
        return
    end

    local blipId = tonumber(input[1])
    local blip = blipsCache[blipId]

    if not blip then
        lib.notify({
            title = 'Blips',
            description = 'Blip not found!',
            type = 'error'
        })
        openBlipsMenu()
        return
    end

    SetEntityCoords(PlayerPedId(), blip.coords.x, blip.coords.y, blip.coords.z)

    lib.notify({
        title = 'Blips',
        description = 'Teleported to ' .. blip.name,
        type = 'success'
    })

    Wait(500)
    openBlipsMenu()
end

-- Export the menu function
exports('openBlipsMenu', openBlipsMenu)

-- Register the network event to open menu
RegisterNetEvent('blips:openMenu', function()
    local count = 0
    for _ in pairs(blipsCache or {}) do
        count = count + 1
    end
    print('[donk_blips] Opening menu. Cache has ' .. count .. ' blips')
    openBlipsMenu()
end)

-- Initialize cache when player spawns
CreateThread(function()
    Wait(2000)
    -- Request blips data
    TriggerServerEvent('blips:getBlips')
end)
