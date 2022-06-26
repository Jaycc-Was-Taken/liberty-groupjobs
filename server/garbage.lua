--Devyn Sanitation https://github.com/devin-monro/devyn-sanitation

local QBCore = exports["qb-core"]:GetCoreObject()
local garbageJobs = {}

RegisterServerEvent("garbage:createGroupJob", function(groupID)
    local src = source
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    if #members <= Garbage.MaxGroupSize then
        if FindGarbageJobById(groupID) == 0 then 
            garbageJobs[#garbageJobs+1] = {groupID = groupID, truckID = 0, routes=10, currentRoute=0, bags=0, pickupAmount=0, totalCollected=0}

            local jobID = #garbageJobs

            local TruckSpawn = Garbage.TruckSpawns[math.random(#Garbage.TruckSpawns)]
            local car = CreateVehicle("trash", TruckSpawn.x, TruckSpawn.y, TruckSpawn.z, TruckSpawn.w, true, true)

            while not DoesEntityExist(car) do
                Wait(25)
            end
            if DoesEntityExist(car) then
                SetVehicleNumberPlateText(car, "GARB"..tostring(math.random(1000, 9999)))
                SetVehicleDoorsLocked(car, 1)
                Wait(500) -- Gotta wait here so the plate can be grabbed correctly? Not sure why it takes the server so long to register it.

                garbageJobs[jobID]["truckID"] = car
                garbageJobs[jobID]["route"] = PickRandomGarbageRoute()
                local plate = GetVehicleNumberPlateText(car)
                local members = exports["ps-playergroups"]:getGroupMembers(groupID)
                local groupAmount = #members
                if groupAmount == 1 then
                    garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags1Person
                elseif groupAmount == 2 then
                    garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags2People
                elseif groupAmount == 3 then
                    garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags3People
                else
                    garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags4People
                end
                for i=1, #members do 
                    TriggerClientEvent('vehiclekeys:client:SetOwner', members[i], plate)
                    TriggerClientEvent("garbage:updatePickup", members[i], Garbage.Locations[garbageJobs[jobID]["route"]]["coords"])
                    Wait(100)
                    TriggerClientEvent("garbage:startRoute", members[i], NetworkGetNetworkIdFromEntity(car))
                end
                exports["ps-playergroups"]:setJobStatus(groupID, "GARBAGE")
            end

            exports["ps-playergroups"]:CreateBlipForGroup(groupID, "garbagePickup", {
                label = "Pickup", 
                coords = Garbage.Locations[garbageJobs[jobID]["route"]]["coords"], 
                sprite = 318, 
                color = 2, 
                scale = 1.0, 
                route = true,
                routeColor = 2,
            })
        else 
            print("no group id found in garbageJobs")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "You have too many people in your group, come back with "..Garbage.MaxGroupSize.. "or less.", "error")
    end
end)

RegisterServerEvent("garbage:stopGroupJob", function(groupID)
    local src = source
    local jobID = FindGarbageJobById(groupID)
    local truckCoords = GetEntityCoords(garbageJobs[jobID]["truckID"])

    if #(truckCoords - Garbage.Blip) < 30 then
        DeleteEntity(garbageJobs[jobID]["truckID"])

        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "garbagePickup")
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        local groupPayout = (garbageJobs[jobID]["totalCollected"] * Garbage.JobPayout)

        for i=1, #members do
            TriggerClientEvent("garbage:endRoute", members[i])
            if groupPayout > 0 then
                local payout = (groupPayout / #members)
                local m = QBCore.Functions.GetPlayer(members[i])
                local cid = m.PlayerData.citizenid
                if Garbage.BuffsEnabled and exports["ps-buffs"]:HasBuff(cid, "oiler") then
                    payout = payout * 1.2
                end
                exports['7rp-payslip']:AddMoney(cid, payout)
                TriggerClientEvent("QBCore:Notify", members[i], "You got $"..payout.." added to payslip for your garbage run", "success")
            end
        end

        garbageJobs[jobID] = nil
        exports["ps-playergroups"]:setJobStatus(groupID, "WAITING")
    else 
        TriggerClientEvent("QBCore:Notify", src "Your truck is not inside the facility", "error")
    end
end)

RegisterServerEvent("garbage:updateBags", function(groupID)
    local src = source
    local jobID = FindGarbageJobById(groupID)
    garbageJobs[jobID]["bags"] = garbageJobs[jobID]["bags"] + 1
    garbageJobs[jobID]["totalCollected"] = garbageJobs[jobID]["totalCollected"] + 1
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    if garbageJobs[jobID]["bags"] < garbageJobs[jobID]["pickupAmount"] then
        for i=1, #members do
            TriggerClientEvent("QBCore:Notify", members[i], garbageJobs[jobID]["bags"].."/"..garbageJobs[jobID]["pickupAmount"].." Garbage Bags Collected.", "primary")
        end
    else
        garbageJobs[jobID]["bags"] = 0
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        local groupAmount = #members
        if groupAmount == 1 then
            garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags1Person
        elseif groupAmount == 2 then
            garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags2People
        elseif groupAmount == 3 then
            garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags3People
        else
            garbageJobs[jobID]["pickupAmount"] = Garbage.MaxBags4People
        end
        local newRoute = PickRandomGarbageRoute()
        while newRoute == garbageJobs[jobID]["currentRoute"] do
            newRoute = PickRandomGarbageRoute()
            Wait(100)
        end
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        for i=1, #members do
            TriggerClientEvent("QBCore:Notify", members[i], "All bags collected for this dumpster", "primary")
            TriggerClientEvent('garage:pickupClean', members[i])
            TriggerClientEvent('garbage:updatePickup', members[i], Garbage.Locations[newRoute]["coords"])
            if math.random(1, 100) > 60 then
                local itemIndex = math.random(1, #Garbage.Rewards)
                local amount = math.random(Garbage.Rewards[itemIndex]["min"], Garbage.Rewards[itemIndex]["max"])
                local m = QBCore.Functions.GetPlayer(members[i])
                m.Functions.AddItem(Garbage.Rewards[itemIndex]["item"], amount, false, {}, false)
                TriggerClientEvent('inventory:client:ItemBox', members[i], QBCore.Shared.Items[Garbage.Rewards[itemIndex]["item"]], 'add', amount)
            end
        end
        garbageJobs[jobID]["currentRoute"] = newRoute
        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "garbagePickup")
        exports["ps-playergroups"]:CreateBlipForGroup(groupID, "garbagePickup", {
            label = "Pickup", 
            coords = Garbage.Locations[newRoute]["coords"], 
            sprite = 318, 
            color = 11, 
            scale = 1.0, 
            route = true,
            routeColor = 2,
        })
    end
end)


function FindGarbageJobById(id)
    for i=1, #garbageJobs do
        if garbageJobs[i]["groupID"] == id then
            return i
        end
    end
    return 0
end

function PickRandomGarbageRoute()
    return math.random(1, #Garbage.Locations)
end
