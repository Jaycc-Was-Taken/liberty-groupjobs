local QBCore = exports["qb-core"]:GetCoreObject()
local towJobs = {}
local towvehicle = 0

RegisterServerEvent("towing:createGroupJob", function(groupID)
    local src = source
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    if #members <= Towing.MaxGroupSize then
        if FindTowingJobById(groupID) == 0 then 
            towJobs[#towJobs+1] = {groupID = groupID, truckID = 0, route=0, totaldelivered=0, maxJobs = 0, towcar = 0}

            local jobID = #towJobs

            local TruckSpawn = Towing.TruckSpawns[math.random(#Towing.TruckSpawns)]
            local car = CreateVehicle("flatbed", TruckSpawn.x, TruckSpawn.y, TruckSpawn.z, TruckSpawn.w, true, true)

            while not DoesEntityExist(car) do
                Wait(25)
            end
            if DoesEntityExist(car) then
                SetVehicleNumberPlateText(car, "TOWHQ"..tostring(math.random(100, 999)))
                SetVehicleDoorsLocked(car, 1)
                SetEntityDistanceCullingRadius(car, 999999999.0)
                Wait(500) -- Gotta wait here so the plate can be grabbed correctly? Not sure why it takes the server so long to register it.
                towJobs[jobID]["route"] = PickRandomTowingRoute()
                towJobs[jobID]["truckID"] = car
                local plate = GetVehicleNumberPlateText(car)
                local members = exports["ps-playergroups"]:getGroupMembers(groupID)
                local groupAmount = #members
                local maxJobs = Towing.MaxJobs1Person
                if groupAmount == 2 then
                    maxJobs = Towing.MaxJobs2People
                end
                towJobs[jobID]["maxJobs"] = maxJobs
                exports["ps-playergroups"]:setJobStatus(groupID, "TOWING")
                TriggerEvent("towing:newTow", groupID)
                for i=1, #members do 
                    TriggerClientEvent('vehiclekeys:client:SetOwner', members[i], plate)
                    TriggerClientEvent("towing:createTowTruck", members[i], NetworkGetNetworkIdFromEntity(car))
                    TriggerClientEvent("towing:createtowbedTarget", members[i], NetworkGetNetworkIdFromEntity(car), groupID)
                end
            end

        else 
            print("no group id found in towJobs")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "You have too many people in your group, come back with "..Towing.MaxGroupSize.. "or less.", "error")
    end
end)

function PickRandomTowingRoute()
    return math.random(1, #Towing.Locations)
end

function FindTowingJobById(id)
    for i=1, #towJobs do
        if towJobs[i]["groupID"] == id then
            return i
        end
    end
    return 0
end

RegisterServerEvent("towing:stopGroupJob", function(groupID)
    local src = source
    local jobID = FindTowingJobById(groupID)
    -- local truckCoords = GetEntityCoords(towJobs[jobID]["truckID"])

    -- if #(truckCoords - Towing.Blip) < 30 then
        DeleteEntity(towJobs[jobID]["truckID"])

        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "newTow")
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        local groupPayout = (towJobs[jobID]["totaldelivered"] * Towing.JobPayout)
        local payout = groupPayout
        

        for i=1, #members do
            if groupPayout > 0 then
                if #members == 2 then
                    payout = (groupPayout * 1.25)
                end
                local m = QBCore.Functions.GetPlayer(members[i])
                local cid = m.PlayerData.citizenid
                if Config.BuffsEnabled and exports["ps-buffs"]:HasBuff(cid, Config.BuffName) then
                    payout = payout * ((Config.BuffAmount/100) + 1)
                end
                if Config.Payslip then
                    exports['7rp-payslip']:AddMoney(cid, payout)
                    TriggerClientEvent("QBCore:Notify", members[i], "You got $"..payout.." added to your pay check for the towing work you've done", "success")
                else
                    m.Functions.AddMoney(Config.PayoutType, payout, 'Towing')
                    TriggerClientEvent("QBCore:Notify", members[i], "You were paid $"..payout.." for the towing work you've done", "success")
                end
            end
        end

        towJobs[jobID] = nil
        exports["ps-playergroups"]:setJobStatus(groupID, "WAITING")
    -- else 
    --     TriggerClientEvent("QBCore:Notify", src "Your truck is not inside the facility", "error")
    -- end
end)

RegisterServerEvent("towing:newTow", function(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    local jobID = FindTowingJobById(groupID)
    local gid = groupID 
    local model = math.random(1,#Towing.CarModels)
    local towcar = CreateVehicle(Towing.CarModels[model], vector3(-195.63, -1169.82, 10.03), true, true)
    Wait(500) 
    while not DoesEntityExist(towcar) do
        Wait(25)
    end
    if DoesEntityExist(towcar) then
        SetEntityDistanceCullingRadius(towcar, 999999999.0)
        SetEntityCoords(towcar, Towing.Locations[towJobs[jobID]["route"]]["coords"], false, false, false, false)
        towJobs[jobID]["towcar"] = towcar
        for i=1, #members do 
            TriggerClientEvent("towing:createTarget", members[i], NetworkGetNetworkIdFromEntity(towcar), groupID)
        end
        exports["ps-playergroups"]:CreateBlipForGroup(groupID, "newTow", {
            label = "Car to Tow", 
            coords = Towing.Locations[towJobs[jobID]["route"]]["coords"], 
            sprite = 68, 
            color = 5, 
            scale = 0.8, 
            route = true,
            routeColor = 5,
        })
    end
end)

RegisterServerEvent('towing:syncload', function(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    TriggerEvent('towing:returntoDepot', groupID)
    for i=1, #members do
    TriggerClientEvent('towing:loadvehicle', members[i])
    end
end)

RegisterServerEvent('towing:syncunload', function(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    for i=1, #members do
    TriggerClientEvent('towing:unloadvehicle', members[i])
    end
end)

RegisterServerEvent('towing:updateJob', function(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    local jobID = FindTowingJobById(groupID)
    towJobs[jobID]["route"] = PickRandomTowingRoute()
    towJobs[jobID]["totaldelivered"] = towJobs[jobID]["totaldelivered"] + 1
    if towJobs[jobID]["totaldelivered"] < towJobs[jobID]["maxJobs"] then
        TriggerEvent('towing:newTow', groupID)
        for i=1, #members do 
            TriggerClientEvent("QBCore:Notify", members[i], "Good Job! Go get another car or return to me to get paid for the work you've done.", "success", 7500)
        end
    else
        for i=1, #members do 
            TriggerClientEvent("QBCore:Notify", members[i], "That is all the jobs I have for you, return to the depot to get paid.", "success", 7500)
        end
    end
end)

RegisterServerEvent('towing:returntoDepot', function(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "newTow")
    for i=1, #members do 
        TriggerClientEvent("QBCore:Notify", members[i], "Take that vehicle back to the tow depot", "success", 7500)
        TriggerClientEvent('towing:return', members[i])
        end
    end)