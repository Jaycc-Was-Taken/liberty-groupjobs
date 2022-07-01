local QBCore = exports["qb-core"]:GetCoreObject()
local jobLocation = vector3(0.0, 0.0, 0.0)
local jobSite = 0
local onJob = false 

RegisterNetEvent("electric:attemptStart", function()
    if exports["ps-playergroups"]:IsGroupLeader() then 
        if exports["ps-playergroups"]:GetJobStage() == "WAITING" then
            local groupID = exports["ps-playergroups"]:GetGroupID()
            
            local model = GetHashKey("boxville")
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            TriggerServerEvent("electric:createGroupJob", groupID)
        else 
            QBCore.Functions.Notify("Your group is already doing something!", "error")
        end
    else 
        QBCore.Functions.Notify("You are not the group leader!", "error")
    end
end)

RegisterNetEvent("electric:ReturnToDepot", function()
    local coords = Electric.PedList[1].coords
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNetEvent("electric:attemptStop", function()
    if exports["ps-playergroups"]:IsGroupLeader() then 
        if exports["ps-playergroups"]:GetJobStage() == "ELECTRICIAN" then
            local groupID = exports["ps-playergroups"]:GetGroupID()
            TriggerServerEvent("electric:stopGroupJob", groupID)
        else 
            QBCore.Functions.Notify("Your group isn't doing a job!", "error")
        end
    else 
        QBCore.Functions.Notify("You are not the group leader!", "error")
    end
end)

RegisterNetEvent("electric:startRoute", function(worksite, TruckID)
    Truck = NetworkGetEntityFromNetworkId(TruckID)
    exports['ps-fuel']:SetFuel(Truck, 100)
    local groupID = exports["ps-playergroups"]:GetGroupID()
    for k, v in pairs(Electric.Locations[worksite]["jobs"]) do
        TriggerServerEvent("electric:addjobblip", groupID, v.name, v.coords)
        exports['qb-target']:AddBoxZone(v.name, v.coords, v.length, v.width, {
            name = v.name,
            debugPoly = false,
            heading = v.heading,
            minZ = v.minZ,
            maxZ = v.maxZ,
        }, {
            options = {
                {
                    type = "client",
                    icon = "bi bi-arrow-right-circle-fill",
                    label = "Repair",
                    event = "electric:repairWork",
                    args = {
                        sitename = v.name,
                    },
                    canInteract = function()
                        if exports["ps-playergroups"]:GetJobStage() == "ELECTRICIAN" then return true end
                        return false
                    end,
                },
            },
            distance = 1.5
        })
    end
end)

function nearPed(model, coords, heading, gender, animDict, animName, scenario)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(1)
	end
	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	else
		print("No gender provided! Check your uration!")
	end
	if Electric.MinusOne then 
		local x, y, z = table.unpack(coords)
		ped = CreatePed(genderNum, GetHashKey(model), x, y, z - 1, heading, false, true)
		table.insert(shopelectricpeds, ped)
	else
		ped = CreatePed(genderNum, GetHashKey(v.model), coords, heading, false, true)
		table.insert(shopelectricpeds, ped)
	end
	SetEntityAlpha(ped, 0, false)
	if Electric.Frozen then
		FreezeEntityPosition(ped, true)
	end
	if Electric.Invincible then
		SetEntityInvincible(ped, true)
	end
	if Electric.Stoic then
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
	if Electric.Fade then
		for i = 0, 255, 51 do
			Citizen.Wait(50)
			SetEntityAlpha(ped, i, false)
		end
	end
	return ped
end --End of the Jimathy stuff

RegisterNetEvent("electric:updateJobsite", function(coords, jobsite)
    jobLocation = coords
    jobSite = jobsite
end)

RegisterNetEvent("electric:cleartargets", function(worksite)
    local worksite = worksite
    local groupID = exports["ps-playergroups"]:GetGroupID()
    for k, v in pairs(Electric.Locations[worksite]["jobs"]) do
        exports['qb-target']:RemoveZone(v.name)
        TriggerServerEvent("electric:removejobblip", groupID, v.name)
    end
end)

RegisterNetEvent("electric:removeTarget", function(sitename)
    local sitename = sitename
    exports['qb-target']:RemoveZone(sitename)
end)

RegisterNetEvent("electric:repairWork", function(data)
    local ped = PlayerPedId()
    local sitename = data.args.sitename
    local groupID = exports["ps-playergroups"]:GetGroupID()
    local worktime = math.random(Electric.WorkTimeMin, Electric.WorkTimeMax) * Electric.WorkTimeMultiplier
    QBCore.Functions.Progressbar("repairwork", "Repairing Electrical Equipment", worktime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "amb@world_human_welding@male@base",
        anim = "base",
    }, {
        model = "prop_weld_torch",
        bone = 28422,
        coords = {
            x = 0.0,
            y = 0.0,
            z = 0.0
        },
        rotation = {
            x = 0.0,
            y = 0.0,
            z = 0.0
        }
    }, {}, function()
        TriggerServerEvent("electric:updateJobProgress", groupID, sitename) -- add anims
        ClearPedTasks(ped)
    end, function() -- Cancel
        ClearPedTasks(ped)
        QBCore.Functions.Notify('Cancelled', 'error', 1500)
    end)
end)