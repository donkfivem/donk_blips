local activeBlips = {}

-- Function to clear all active blips
local function ClearBlips()
    for _, blip in pairs(activeBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    activeBlips = {}
end

-- Function to create blips
local function CreateBlips(blipsData)
    ClearBlips()

    for _, v in pairs(blipsData) do
        local coords = vector3(v.x, v.y, v.z)
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, v.sprite)
        SetBlipScale(blip, v.scale)
        SetBlipColour(blip, v.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
        table.insert(activeBlips, blip)
    end
end

-- Load blips from database on resource start
if Config.blipsShow then
    CreateThread(function()
        Wait(1000) -- Wait for server to be ready
        local blips = lib.callback.await('donk_blips:server:getBlips', false)
        if blips then
            CreateBlips(blips)
        end
    end)
end

-- Refresh blips when triggered by server
RegisterNetEvent('donk_blips:client:refreshBlips', function()
    local blips = lib.callback.await('donk_blips:server:getBlips', false)
    if blips then
        CreateBlips(blips)
    end
end)

-- Open admin menu
RegisterNetEvent('donk_blips:client:openAdminMenu', function()
    lib.registerContext({
        id = 'donk_blips_admin_menu',
        title = 'Blip Management',
        options = {
            {
                title = 'Add New Blip',
                description = 'Create a new blip at your current location',
                icon = 'map-pin',
                onSelect = function()
                    OpenAddBlipMenu()
                end
            },
            {
                title = 'Manage Blips',
                description = 'View and delete existing blips',
                icon = 'list',
                onSelect = function()
                    OpenManageBlipsMenu()
                end
            }
        }
    })
    lib.showContext('donk_blips_admin_menu')
end)

-- Open add blip menu
function OpenAddBlipMenu()
    local input = lib.inputDialog('Create New Blip', {
        {type = 'input', label = 'Blip Name', description = 'Enter the name for the blip', required = true, min = 1, max = 100},
        {type = 'number', label = 'Sprite ID', description = 'Blip sprite (icon) ID', required = true, default = 1, min = 1},
        {type = 'number', label = 'Color ID', description = 'Blip color ID', required = true, default = 1, min = 0},
        {type = 'number', label = 'Scale', description = 'Blip size (0.5 - 2.0)', required = true, default = 0.8, min = 0.1, max = 2.0}
    })

    if not input then return end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local data = {
        name = input[1],
        sprite = math.floor(input[2]),
        color = math.floor(input[3]),
        scale = input[4],
        coords = {x = coords.x, y = coords.y, z = coords.z}
    }

    TriggerServerEvent('donk_blips:server:addBlip', data)
end

-- Open manage blips menu
function OpenManageBlipsMenu()
    local blips = lib.callback.await('donk_blips:server:getBlips', false)

    if not blips or #blips == 0 then
        lib.notify({
            title = 'Blip Manager',
            description = 'No blips found in database',
            type = 'info'
        })
        return
    end

    local options = {}

    for _, blip in ipairs(blips) do
        table.insert(options, {
            title = blip.name,
            description = string.format('ID: %s | Sprite: %s | Color: %s | Scale: %.1f', blip.id, blip.sprite, blip.color, blip.scale),
            icon = 'map-pin',
            onSelect = function()
                OpenBlipOptionsMenu(blip)
            end
        })
    end

    lib.registerContext({
        id = 'donk_blips_manage_menu',
        title = 'Manage Blips',
        menu = 'donk_blips_admin_menu',
        options = options
    })
    lib.showContext('donk_blips_manage_menu')
end

-- Open individual blip options menu
function OpenBlipOptionsMenu(blip)
    lib.registerContext({
        id = 'donk_blips_options_menu',
        title = blip.name,
        menu = 'donk_blips_manage_menu',
        options = {
            {
                title = 'View Location',
                description = 'Set a waypoint to this blip',
                icon = 'location-dot',
                onSelect = function()
                    SetNewWaypoint(blip.x, blip.y)
                    lib.notify({
                        title = 'Blip Manager',
                        description = 'Waypoint set to ' .. blip.name,
                        type = 'success'
                    })
                end
            },
            {
                title = 'Teleport to Blip',
                description = 'Teleport to this blip location',
                icon = 'map',
                onSelect = function()
                    local playerPed = PlayerPedId()
                    SetEntityCoords(playerPed, blip.x, blip.y, blip.z)
                    lib.notify({
                        title = 'Blip Manager',
                        description = 'Teleported to ' .. blip.name,
                        type = 'success'
                    })
                end
            },
            {
                title = 'Delete Blip',
                description = 'Permanently delete this blip',
                icon = 'trash',
                iconColor = 'red',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Delete Blip',
                        content = 'Are you sure you want to delete "' .. blip.name .. '"?',
                        centered = true,
                        cancel = true
                    })

                    if alert == 'confirm' then
                        TriggerServerEvent('donk_blips:server:deleteBlip', blip.id)
                    end
                end
            }
        }
    })
    lib.showContext('donk_blips_options_menu')
end