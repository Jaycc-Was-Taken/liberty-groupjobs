local QBCore = exports["qb-core"]:GetCoreObject()


local peds = {}
local jobPeds = {}
local nearPed = function(model, coords, heading, gender, animDict, animName, scenario)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(1)
	end
	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	else
		print("No gender provided! Check your configuration!")
	end
	if Config.MinusOne then 
		local x, y, z = table.unpack(coords)
		ped = CreatePed(genderNum, GetHashKey(model), x, y, z - 1, heading, false, true)
		table.insert(jobPeds, ped)
	else
		ped = CreatePed(genderNum, GetHashKey(v.model), coords, heading, false, true)
		table.insert(jobPeds, ped)
	end
	SetEntityAlpha(ped, 0, false)
	if Config.Frozen then
		FreezeEntityPosition(ped, true)
	end
	if Config.Invincible then
		SetEntityInvincible(ped, true)
	end
	if Config.Stoic then
		SetBlockingOfNonTemporaryEvents(ped, true)
	end
	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
	if scenario then
		TaskStartScenarioInPlace(ped, scenario, 0, true)
	end
	if Config.Fade then
		for i = 0, 255, 51 do
			Citizen.Wait(50)
			SetEntityAlpha(ped, i, false)
		end
	end
	return ped
end
local CreatePeds = function()
    while true do
        Citizen.Wait(500)
        for k = 1, #Config.PedList, 1 do
            v = Config.PedList[k]
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - v.coords)
            if dist < Config.Distance and not peds[k] then
                local ped = nearPed(v.model, v.coords, v.heading, v.gender, v.animDict, v.animName, v.scenario)
                peds[k] = {ped = ped}
                local options = {}
                for _,v in pairs(v.options) do
                    optionData = {
                        type = v.type,
                        event = v.event,
                        icon = v.icon,
                        label = v.label,
                        canInteract = v.canInteract
                    }
                    table.insert(options, optionData)
                end
                exports['qb-target']:AddTargetEntity(ped, {
                    options = options,
                    distance = 2.0
                })
            end
            if dist >= Config.Distance and peds[k] then
                if Config.Fade then
                    for i = 255, 0, -51 do
                        Citizen.Wait(50)
                        SetEntityAlpha(peds[k].ped, i, false)
                    end
                end
                DeletePed(peds[k].ped)
                peds[k] = nil
            end
        end
    end
end
local blips = {}
function CreateBlips()
    for k,v in pairs(Config.PedList) do
        if v.blipInfo.enable then
            blips[k] = AddBlipForCoord(v.coords)
            SetBlipSprite(blips[k], v.blipInfo.sprite)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale(blips[k], v.blipInfo.scale)
            SetBlipAsShortRange(blips[k], true)
            SetBlipColour(blips[k], v.blipInfo.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(v.blipInfo.text)
            EndTextCommandSetBlipName(blips[k]) 
        end   
    end
end
CreateThread(function()
    CreateBlips()
    CreatePeds()
end)