local QBCore = exports["qb-core"]:GetCoreObject()
local electricJobs = {}

RegisterServerEvent("electric:createGroupJob", function(groupID)
    local src = source
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    if #members <= Electric.MaxGroupSize then
        if FindElectricJobById(groupID) == 0 then 
            electricJobs[#electricJobs+1] = {groupID = groupID, truckID = 0, route=0, onsiteRepair=0, totalJobRepair=0, totalRepaired = 0, maxJobs = 0}

            local jobID = #electricJobs

            local TruckSpawn = Electric.TruckSpawns[math.random(#Electric.TruckSpawns)]
            local car = CreateVehicle("boxville", TruckSpawn.x, TruckSpawn.y, TruckSpawn.z, TruckSpawn.w, true, true)

            while not DoesEntityExist(car) do
                Wait(25)
            end
            if DoesEntityExist(car) then
                SetVehicleNumberPlateText(car, "POWER"..tostring(math.random(100, 999)))
                SetVehicleDoorsLocked(car, 1)
                SetEntityDistanceCullingRadius(vehicle, 999999999.0)
                Wait(500) -- Gotta wait here so the plate can be grabbed correctly? Not sure why it takes the server so long to register it.
                electricJobs[jobID]["route"] = PickRandomElectricRoute()
                electricJobs[jobID]["truckID"] = car
                local plate = GetVehicleNumberPlateText(car)
                local members = exports["ps-playergroups"]:getGroupMembers(groupID)
                local groupAmount = #members
                local maxJobs = Electric.MaxJobs1Person
                if groupAmount == 2 then
                    maxJobs = Electric.MaxJobs2People
                elseif groupAmount == 3 then
                    maxJobs = Electric.MaxJobs3People
                elseif groupAmount == 4 then
                    maxJobs = Electric.MaxJobs4People
                end
                electricJobs[jobID]["maxJobs"] = maxJobs
                for i=1, #members do 
                    TriggerClientEvent('vehiclekeys:client:SetOwner', members[i], plate)
                    Wait(100)
                    TriggerClientEvent("electric:startRoute", members[i], electricJobs[jobID]["route"], NetworkGetNetworkIdFromEntity(car))
                end
                exports["ps-playergroups"]:setJobStatus(groupID, "ELECTRICIAN")
                exports["ps-playergroups"]:CreateBlipForGroup(groupID, "jobsite", {
                    label = "Work Site", 
                    coords = Electric.Locations[electricJobs[jobID]["route"]]["coords"], 
                    sprite = 566, 
                    color = 5, 
                    scale = 0.8, 
                    route = true,
                    routeColor = 5,
                })
            end

        else 
            print("no group id found in electricJobs")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "You have too many people in your group, come back with "..Electric.MaxGroupSize.. "or less.", "error")
    end
end)

function PickRandomElectricRoute()
    return math.random(1, #Electric.Locations)
end

function FindElectricJobById(id)
    for i=1, #electricJobs do
        if electricJobs[i]["groupID"] == id then
            return i
        end
    end
    return 0
end

RegisterServerEvent("electric:stopGroupJob", function(groupID)
    local src = source
    local jobID = FindElectricJobById(groupID)
    local truckCoords = GetEntityCoords(electricJobs[jobID]["truckID"])

    -- if #(truckCoords - Electric.Blip) < 30 then
        DeleteEntity(electricJobs[jobID]["truckID"])

        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "jobsite")
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        local groupPayout = (electricJobs[jobID]["totalRepaired"] * Electric.JobPayout)

        for i=1, #members do
            TriggerClientEvent("electric:cleartargets", members[i], electricJobs[jobID]["route"])
            if groupPayout > 0 then
                local payout = (groupPayout / #members)
                local m = QBCore.Functions.GetPlayer(members[i])
                local cid = m.PlayerData.citizenid
                if Electric.BuffsEnabled and exports["ps-buffs"]:HasBuff(cid, "oiler") then
                    payout = payout * 1.2
                end
                exports['7rp-payslip']:AddMoney(cid, payout)
                TriggerClientEvent("QBCore:Notify", members[i], "You got $"..payout.." added to your pay check for the electrical work you've done", "success")
            end
        end

        electricJobs[jobID] = nil
        exports["ps-playergroups"]:setJobStatus(groupID, "WAITING")
    -- else 
    --     TriggerClientEvent("QBCore:Notify", src "Your truck is not inside the facility", "error")
    -- end
end)

RegisterServerEvent("electric:updateJobProgress", function(groupID, sitename)
    local jobID = FindElectricJobById(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    local sitename = sitename
    local route = electricJobs[jobID]["route"]
    electricJobs[jobID]["totalJobRepair"] = #Electric.Locations[route]["jobs"]
    electricJobs[jobID]["onsiteRepair"] = electricJobs[jobID]["onsiteRepair"] + 1
    
        if electricJobs[jobID]["totalJobRepair"] > electricJobs[jobID]["onsiteRepair"] then
            for i=1, #members do
                exports["ps-playergroups"]:RemoveBlipForGroup(groupID, sitename)
                TriggerClientEvent("electric:removeTarget", members[i], sitename)
                TriggerClientEvent("QBCore:Notify", members[i], electricJobs[jobID]["onsiteRepair"].." / "..electricJobs[jobID]["totalJobRepair"].." Equipment Repaired.", "primary")
            end
        else 
            electricJobs[jobID]["totalRepaired"] = electricJobs[jobID]["totalRepaired"] + 1
            electricJobs[jobID]["onsiteRepair"] = 0
            if electricJobs[jobID]["totalRepaired"] >= electricJobs[jobID]["maxJobs"] then
                exports["ps-playergroups"]:RemoveBlipForGroup(groupID, sitename)
                exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "jobsite")
                for i=1, #members do
                    TriggerClientEvent("electric:removeTarget", members[i], sitename)
                    TriggerClientEvent("QBCore:Notify", members[i], "All jobs are finished, return to LS WaP to receive your payslip", "primary")
                    TriggerClientEvent("electric:ReturnToDepot", members[i])
                end
            else
                exports["ps-playergroups"]:RemoveBlipForGroup(groupID, sitename)
                exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "jobsite")
                for i=1, #members do
                TriggerClientEvent("electric:cleartargets",members[i], electricJobs[jobID]["route"])
                end
                NewRoute(groupID)
                for i=1, #members do
                    TriggerClientEvent("electric:removeTarget", members[i], sitename)
                    TriggerClientEvent("QBCore:Notify", members[i], "All work repaired for this site.", "primary")
                    TriggerClientEvent("QBCore:Notify", members[i], "Head to the next job site for more work or return to LS WaP to get paid for the work you've done.", "primary")
                    CreateJobSiteBlip(groupID)
                    TriggerClientEvent("electric:startRoute", members[i], electricJobs[jobID]["route"])
                end
            end
        end
end)

function CreateJobSiteBlip(groupID)
    local jobID = FindElectricJobById(groupID)
    local newRoute = electricJobs[jobID]["route"]
    exports["ps-playergroups"]:CreateBlipForGroup(groupID, "jobsite", {
        label = "Work Site", 
        coords = Electric.Locations[newRoute]["coords"], 
        sprite = 566, 
        color = 5, 
        scale = 0.8, 
        route = true,
        routeColor = 5,
    })
end

function NewRoute(groupID)
    local src = source
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    local jobID = FindElectricJobById(groupID)
    local newRoute = PickRandomElectricRoute()
    while newRoute == electricJobs[jobID]["route"] do
        newRoute = PickRandomElectricRoute()
        Wait(100)
    end
    electricJobs[jobID]["route"] = newRoute
    for i=1, #members do
    TriggerClientEvent("electric:updateJobsite", members[i], Electric.Locations[newRoute]["coords"], jobID)
    end
end

RegisterNetEvent("electric:addjobblip", function(groupID, blipname, blipcoords)
exports["ps-playergroups"]:CreateBlipForGroup(groupID, blipname, {
    label = "Faulty Equipment", 
    coords = blipcoords, 
    sprite = 1, 
    color = 5, 
    scale = 0.3,
})
end)

RegisterNetEvent("electric:removejobblip" , function(groupID, blipname)
    exports["ps-playergroups"]:RemoveBlipForGroup(groupID, blipname)
end)