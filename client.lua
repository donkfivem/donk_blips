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

    print("^2[DONK BLIPS] Creating blips, count: " .. #blipsData)

    for _, v in pairs(blipsData) do
        print("^3[DONK BLIPS] Creating blip: " .. v.name .. " at " .. v.x .. ", " .. v.y .. ", " .. v.z)

        local coords = vector3(v.x, v.y, v.z)
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

        SetBlipSprite(blip, v.sprite)
        SetBlipDisplay(blip, 4) -- Display on both minimap and main map
        SetBlipScale(blip, v.scale)
        SetBlipColour(blip, v.color)
        SetBlipAsShortRange(blip, false) -- Always visible on map

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)

        table.insert(activeBlips, blip)

        print("^2[DONK BLIPS] Blip created successfully! Blip ID: " .. blip .. " | Sprite: " .. v.sprite .. " | Color: " .. v.color .. " | Scale: " .. v.scale)
    end

    print("^2[DONK BLIPS] Total active blips: " .. #activeBlips)
end

-- Function to load blips
local function LoadBlips()
    print("^5[DONK BLIPS] LoadBlips called")

    if not Config.blipsShow then
        print("^1[DONK BLIPS] Config.blipsShow is FALSE - blips disabled!")
        return
    end

    print("^5[DONK BLIPS] Requesting blips from server...")
    local blips = lib.callback.await('donk_blips:server:getBlips', false)

    if blips then
        print("^2[DONK BLIPS] Received " .. #blips .. " blips from server")
        CreateBlips(blips)
    else
        print("^1[DONK BLIPS] No blips received from server!")
    end
end

-- Load blips on player spawn
CreateThread(function()
    Wait(1000) -- Wait for framework to be ready
    LoadBlips()
end)

-- ESX PlayerLoaded event
RegisterNetEvent('esx:playerLoaded', function()
    Wait(1000)
    LoadBlips()
end)

-- QBCore PlayerLoaded event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    LoadBlips()
end)

-- Refresh blips when triggered by server
RegisterNetEvent('donk_blips:client:refreshBlips', function()
    LoadBlips()
end)

-- Register main admin menu
lib.registerMenu({
    id = 'donk_blips_admin_menu',
    title = 'Blip Management',
    position = 'top-right',
    onSelected = function(selected)
        if selected == 1 then
            -- Add New Blip
            OpenAddBlipMenu()
        elseif selected == 2 then
            -- Manage Blips
            OpenManageBlipsMenu()
        end
    end,
    options = {
        {label = 'Add New Blip', description = 'Create a new blip at your current location', icon = 'map-pin'},
        {label = 'Manage Blips', description = 'View and delete existing blips', icon = 'list'},
    }
}, function(selected, scrollIndex, args)
    print('Menu opened')
end)

-- Open admin menu
RegisterNetEvent('donk_blips:client:openAdminMenu', function()
    lib.showMenu('donk_blips_admin_menu')
end)

-- Open add blip menu
function OpenAddBlipMenu()
    local input = lib.inputDialog('Create New Blip', {
        {type = 'input', label = 'Blip Name', description = 'Enter the name for the blip', required = true, min = 1, max = 100},
        {type = 'input', label = 'Sprite ID', description = 'Blip sprite (icon) ID', required = true, default = '1'},
        {type = 'input', label = 'Color ID', description = 'Blip color ID', required = true, default = '1'},
        {type = 'input', label = 'Scale', description = 'Blip size (0.1 - 2.0, decimals allowed)', required = true, default = '0.8'}
    })

    if not input then return end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Convert and validate inputs
    local sprite = tonumber(input[2])
    local color = tonumber(input[3])
    local scale = tonumber(input[4])

    if not sprite or not color or not scale then
        lib.notify({
            title = 'Blip Manager',
            description = 'Invalid input! Please enter valid numbers.',
            type = 'error'
        })
        return
    end

    local data = {
        name = input[1],
        sprite = math.floor(sprite),
        color = math.floor(color),
        scale = scale,
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
            label = blip.name,
            description = string.format('ID: %s | Sprite: %s | Color: %s | Scale: %.1f', blip.id, blip.sprite, blip.color, blip.scale),
            icon = 'map-pin',
            args = {blipData = blip}
        })
    end

    lib.registerMenu({
        id = 'donk_blips_manage_menu',
        title = 'Manage Blips',
        position = 'top-right',
        onSelected = function(selected, secondary, args)
            if args and args.blipData then
                OpenBlipOptionsMenu(args.blipData)
            end
        end,
        onClose = function()
            lib.showMenu('donk_blips_admin_menu')
        end,
        options = options
    }, function(selected, scrollIndex, args)
        print('Manage blips menu opened')
    end)

    lib.showMenu('donk_blips_manage_menu')
end

-- Open individual blip options menu
function OpenBlipOptionsMenu(blip)
    lib.registerMenu({
        id = 'donk_blips_options_menu',
        title = blip.name,
        position = 'top-right',
        onSelected = function(selected)
            if selected == 1 then
                -- Set Waypoint
                SetNewWaypoint(blip.x, blip.y)
                lib.notify({
                    title = 'Blip Manager',
                    description = 'Waypoint set to ' .. blip.name,
                    type = 'success'
                })
            elseif selected == 2 then
                -- Teleport
                local playerPed = PlayerPedId()
                SetEntityCoords(playerPed, blip.x, blip.y, blip.z)
                lib.notify({
                    title = 'Blip Manager',
                    description = 'Teleported to ' .. blip.name,
                    type = 'success'
                })
            elseif selected == 3 then
                -- Delete
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
        end,
        onClose = function()
            lib.showMenu('donk_blips_manage_menu')
        end,
        options = {
            {label = 'View Location', description = 'Set a waypoint to this blip', icon = 'location-dot'},
            {label = 'Teleport to Blip', description = 'Teleport to this blip location', icon = 'map'},
            {label = 'Delete Blip', description = 'Permanently delete this blip', icon = 'trash'},
        }
    }, function(selected, scrollIndex, args)
        print('Blip options menu opened')
    end)

    lib.showMenu('donk_blips_options_menu')
end