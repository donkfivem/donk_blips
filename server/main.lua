local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}

local function isPlayerAllowed(source)
  local Player = QBCore.Functions.GetPlayer(source)

  if not Player then return false end

  if QBCore.Functions.HasPermission(source, 'god') == false then
    return false
  end

  return true
end

local function encodeData(blip)
	return json.encode({
		coords = blip.coords,
		groups = blip.groups,
		items = blip.items,
		hideUi = blip.hideUi,
		ftimer = blip.ftimer,
		sColor= blip.sColor,
		scImg= blip.scImg,
		Sprite= blip.Sprite,
		SpriteImg= blip.SpriteImg,
		scale= blip.scale,
		alpha= blip.alpha,
		colors= blip.colors,
		hideb= blip.hideb,
		tickb= blip.tickb,
		bflash= blip.bflash,
		sRange= blip.sRange,
		outline= blip.outline,
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

local isLoaded = false

MySQL.ready(function()
	local success, result = pcall(MySQL.query.await, 'SELECT id, name, data FROM blips') --[[@as any]]

	if not success then
		success, result = pcall(MySQL.query, [[CREATE TABLE `blips` (
			`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
			`name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci',
			`data` LONGTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
			PRIMARY KEY (`id`) USING BTREE
		) COLLATE='utf8mb4_unicode_ci' ENGINE=InnoDB; ]])

		if not success then
			return error(result)
		end

	elseif result then
		for i = 1, #result do
			local blip = result[i]
			createBlip(blip.id, json.decode(blip.data), blip.name)
		end
	end

	isLoaded = true
end)

RegisterNetEvent('blips:getBlips', function()
	local source = source
	while not isLoaded do Wait(100) end

	TriggerClientEvent('blips:setBlips', source, blips)
end)

RegisterNetEvent('blips:editBlip', function(id, data)
	local source = source
	if isPlayerAllowed(source) then
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
			else
				MySQL.update('DELETE FROM blips WHERE id = ?', { id })
			end

			blips[id] = data
			TriggerClientEvent('blips:editBlip', -1, id, data)

			TriggerClientEvent('QBCore:Notify', source, 'Blip (' .. data.name .. ') ' .. 'has been ' .. (data and 'updated' or 'deleted'), 'success')

		else
			local insertId = MySQL.insert.await('INSERT INTO blips (name, data) VALUES (?, ?)', { data.name, encodeData(data) })
			local blip = createBlip(insertId, data, data.name)

			TriggerClientEvent('blips:setBlip', -1, blip.id, false, blip)

			TriggerClientEvent('QBCore:Notify', source, 'Blip (' .. data.name .. ') ' .. 'has been created', 'success')
		end
	end
end)


-- MIGRATION
CreateThread(function()
  Wait(1000)

  if config_blips == nil then return end


  --[[ insert all stashes if they doesnt exists in the database ]]
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

		local insert = MySQL.insert.await('INSERT INTO blips (name, data) VALUES (?, ?)', { config_blips[i].title, encodeData(data) })

	end
end)




QBCore.Commands.Add('blipss', 'Blips tool', {}, true, function(source, args)
	TriggerClientEvent('blips:view', source)
end, 'master')