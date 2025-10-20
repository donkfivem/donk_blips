---@class Framework
---@field name 'qbcore'|'esx'|'none'
---@field object table|nil

Framework = {
    name = 'none',
    object = nil
}

---Initialize the framework
function Framework:Init()
    -- Try QBCore first
    local success, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if success and core then
        self.name = 'qbcore'
        self.object = core
        return
    end

    -- Try ESX
    success, core = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if success and core then
        self.name = 'esx'
        self.object = core
        return
    end

    -- Fallback to standalone
    self.name = 'none'
    self.object = nil
end

-- Initialize on load
Framework:Init()
