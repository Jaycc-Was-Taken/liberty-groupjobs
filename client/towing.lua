local QBCore = exports["qb-core"]:GetCoreObject()
local jobLocation = vector3(0.0, 0.0, 0.0)
local jobSite = 0
local onJob = false 
local towloaded = false
local towtruck = 0
local towtarget = 0 
local cartowed = false
local indropzone = false
local currenttow = 0
local targetspawned = false
local depotcoords = Towing.DropOffZones[1]

RegisterNetEvent("towing:attemptStart", function()
    if exports["ps-playergroups"]:IsGroupLeader() then 
        if exports["ps-playergroups"]:GetJobStage() == "WAITING" then
            local groupID = exports["ps-playergroups"]:GetGroupID()
            
            local model = GetHashKey("flatbed")
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            TriggerServerEvent("towing:createGroupJob", groupID)
            onJob = true
        else 
            QBCore.Functions.Notify("Your group is already doing something!", "error")
        end
    else 
        QBCore.Functions.Notify("You are not the group leader!", "error")
    end
end)

RegisterNetEvent("towing:attemptStop", function()
    if exports["ps-playergroups"]:IsGroupLeader() then 
        if exports["ps-playergroups"]:GetJobStage() == "TOWING" then
            local groupID = exports["ps-playergroups"]:GetGroupID()
            TriggerServerEvent("towing:stopGroupJob", groupID)
            onJob = false
        else 
            QBCore.Functions.Notify("Your group isn't doing a job!", "error")
        end
    else 
        QBCore.Functions.Notify("You are not the group leader!", "error")
    end
end)

RegisterNetEvent('towing:unloadvehicle', function()
    cartowed = false
end)

RegisterNetEvent('towing:loadvehicle', function()
    cartowed = true
end)

RegisterNetEvent('towing:towVehicle', function(data)
    local ped = PlayerPedId()
    local pedcoords = GetEntityCoords(ped)
    local groupID = exports["ps-playergroups"]:GetGroupID()
    local minimum, maximum = GetModelDimensions(GetEntityModel(towtruck))
    local ratio = math.abs(maximum.y/minimum.y)
    local offset = minimum.y - (maximum.y + minimum.y)*ratio
    local trunkpos = GetOffsetFromEntityInWorldCoords(towtruck, 0, offset, 0)
    local dist = #(pedcoords - trunkpos)
    local depotdist = #(trunkpos - depotcoords)
    towcar = NetworkGetEntityFromNetworkId(data.towcar)
    local towcartemp = towtarget
    local driver = GetPedInVehicleSeat(towtruck, -1)
    local passenger = GetPedInVehicleSeat(towtruck, 0)
    if cartowed then
        if depotdist < 15 then
            if driver == 0 and passenger == 0 then
                NetworkRequestControlOfEntity(towtarget)
                QBCore.Functions.Progressbar("untowing_vehicle", "Unloading the Vehicle...", Towing.TimetoTow, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "mini@repair",
                    anim = "fixing_a_ped",
                    flags = 1,
                }, {}, {}, function() -- Done
                    StopAnimTask(ped, "mini@repair", "fixing_a_ped", 1.0)
                    TriggerServerEvent('towing:syncunload', groupID)
                    TriggerServerEvent('towing:updateJob', groupID)
                    FreezeEntityPosition(towtarget, false)
                    Wait(250)
                    DetachEntity(towtarget, true, true)
                    Wait(250)
                    DeleteVehicle(towcartemp)
                end, function()
                    ClearPedTasks(ped)
                    QBCore.Functions.Notify("Cancelled", "error")
                end)
            else
                QBCore.Functions.Notify('Truck must be empty before operating tow hydraulics', 'error', 5000)
            end
        else
            QBCore.Functions.Notify('Make sure you bring that back to the depot before you unload it', 'error')
        end
    else
        if dist < 4 then
            if driver == 0 and passenger == 0 then
                NetworkRequestControlOfEntity(towtarget)
                QBCore.Functions.Progressbar("towing_vehicle", "Hoisting the Vehicle...", Towing.TimetoTow, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "mini@repair",
                    anim = "fixing_a_ped",
                    flags = 1,
                }, {}, {}, function() -- Done
                    StopAnimTask(ped, "mini@repair", "fixing_a_ped", 1.0)
                    TriggerServerEvent('towing:syncload', groupID)
                    StopAnimTask(ped, "mini@repair", "fixing_a_ped", 1.0)
                    AttachEntityToEntity(towtarget, towtruck, GetEntityBoneIndexByName(towtruck, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 0.90, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                    FreezeEntityPosition(towtarget, true)
                end, function()
                    ClearPedTasks(ped)
                    QBCore.Functions.Notify("Cancelled", "error")
                end)
            else
                QBCore.Functions.Notify('Truck must be empty before operating tow hydraulics.', 'error', 5000)
            end
        else
            QBCore.Functions.Notify('No Towtruck Nearby', 'error')
        end
    end
end)

RegisterNetEvent("towing:createTarget", function(towcar, groupID)
    towtarget = NetworkGetEntityFromNetworkId(towcar)
    SetVehicleDoorsLocked(towtarget, 3)
    SetVehicleEngineHealth(towtarget, 199)
    for i=0, 5 do
    SetVehicleTyreBurst(towtarget, i, true, 1000)
    SmashVehicleWindow(towtarget, i)
    SetVehicleDoorBroken(towtarget, i)
    end

    exports['qb-target']:AddTargetEntity(towtarget, {
        options = { 
            {
                type = "client",
                event = "towing:towVehicle",
                icon = "fas fa-car",
                label = "Tow Vehicle",
                towcar = towcar,
                groupID = groupID,
                canInteract = function()
                    if cartowed then
                        return false
                    else
                        return true
                    end
                end,
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent("towing:createtowbedTarget", function(towbed, groupID)
    towtruck = NetworkGetEntityFromNetworkId(towbed)
    exports['qb-target']:AddTargetEntity(towtruck, {
        options = { 
            {
                type = "client",
                event = "towing:towVehicle",
                icon = "fas fa-car",
                label = "Unload Vehicle",
                towbed = towtruck,
                groupID = groupID,
                canInteract = function()
                    if cartowed then
                        return true
                    else
                        return false
                    end
                end,
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent('towing:createTowTruck', function(truckID)
    if exports['ps-playergroups']:GetJobStage() == "TOWING" then
        towtruck = NetworkGetEntityFromNetworkId(truckID)
        exports['ps-fuel']:SetFuel(towtruck, 100)
    end
end)

local function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

RegisterNetEvent('towing:return', function()
    local coords = vector3(-222.35, -1149.01, 22.99)
    SetNewWaypoint(coords.x, coords.y)
end)

local function isTowVehicle(vehicle)
    local retval = false
    for k, v in pairs(Towing.Vehicles) do
        if GetEntityModel(vehicle) == GetHashKey(k) then
            retval = true
        end
    end
    return retval
end

RegisterNetEvent('qb-tow:client:TowVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    if isTowVehicle(vehicle) then
        if CurrentTow == nil then
            local playerped = PlayerPedId()
            local coordA = GetEntityCoords(playerped, 1)
            local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
            local targetVehicle = getVehicleInDirection(coordA, coordB)

            if NpcOn and CurrentLocation ~= nil then
                if GetEntityModel(targetVehicle) ~= GetHashKey(CurrentLocation.model) then
                    QBCore.Functions.Notify("This Is Not The Right Vehicle", "error")
                    return
                end
            end
            if not IsPedInAnyVehicle(PlayerPedId()) then
                if vehicle ~= targetVehicle then
                    NetworkRequestControlOfEntity(targetVehicle)
                    local towPos = GetEntityCoords(vehicle)
                    local targetPos = GetEntityCoords(targetVehicle)
                    if #(towPos - targetPos) < 11.0 then
                        QBCore.Functions.Progressbar("towing_vehicle", "Hoisting the Vehicle...", Towing.TimetoTow, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "mini@repair",
                            anim = "fixing_a_ped",
                            flags = 16,
                        }, {}, {}, function() -- Done
                            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                            AttachEntityToEntity(targetVehicle, vehicle, GetEntityBoneIndexByName(vehicle, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 1.0, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                            FreezeEntityPosition(targetVehicle, true)
                            CurrentTow = targetVehicle
                            QBCore.Functions.Notify("Vehicle Towed")
                        end, function() -- Cancel
                            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                            QBCore.Functions.Notify("Failed", "error")
                        end)
                    end
                end
            end
        else
            QBCore.Functions.Progressbar("untowing_vehicle", "Remove The Vehicle", Towing.TimetoTow, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_ped",
                flags = 16,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                FreezeEntityPosition(CurrentTow, false)
                Wait(250)
                AttachEntityToEntity(CurrentTow, vehicle, 20, -0.0, -15.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                DetachEntity(CurrentTow, true, true)
                CurrentTow = nil
                QBCore.Functions.Notify("Vehicle Taken Off")
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                QBCore.Functions.Notify("Failed", "error")
            end)
        end
    else
        QBCore.Functions.Notify("You Must Have Been In A Towing Vehicle First", "error")
    end
end)