Config = Config or {}

-- Enable/Disable blips display
Config.blipsShow = true

-- Admin command to open the blip management menu
Config.AdminCommand = 'blipsadmin'

-- For QBCore: Permission group required (e.g., 'god', 'admin')
Config.AdminPermission = 'god'

-- For ESX: Admin groups that can manage blips
Config.AdminGroups = {
    'admin',
    'superadmin'
}

-- Legacy static locations (DEPRECATED - Use database system instead)
-- These are kept for backwards compatibility but will not be used
-- All blips should now be managed through the admin menu and stored in database
Config.Locations = {
    -- [1] = {
    --     vector = vector3(-2564.09, 3230.73, 32.81),
    --     text = "Race Track",
    --     color = 1,
    --     sprite = 315,
    --     scale = 0.8,
    -- },
    -- [2] = {
    --     vector = vector3(-1257.24, -1437.49, 4.37),
    --     text = "Pop Pills",
    --     color = 5,
    --     sprite = 51,
    --     scale = 0.5,
    -- },
    -- [3] = {
    --     vector = vector3(-1274.59, -1411.22, 4.37 ),
    --     text = "Digital Den",
    --     color = 1,
    --     sprite = 817,
    --     scale = 0.5,
    -- },
    -- [4] = {
    --     vector = vector3(2408.24, 3057.88, 48.15 ),
    --     text = "Junkyard Recycling",
    --     color = 0,
    --     sprite = 739,
    --     scale = 0.8,
    -- },
}
