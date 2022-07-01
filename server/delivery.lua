local QBCore = exports["qb-core"]:GetCoreObject()
local deliveryJobs = {}

RegisterServerEvent('delivery:createGroupJob', function(groupID)
    local src = source
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    if #members <= Delivery.MaxGroupSize then
        if FindDeliveryJobById(groupID) == 0 then 
            deliveryJobs[#deliveryJobs+1] = {groupID = groupID, truckID = 0, routes=5, currentRoute=0, boxes=0, dropoffAmount=0, totalDropped=0, boxesGrabbed = 0, boxesLoaded = 0}

            local jobID = #deliveryJobs

            local VanSpawn = Delivery.VanSpawns[math.random(#Delivery.VanSpawns)]
            local car = CreateVehicle("rumpo", VanSpawn.x, VanSpawn.y, VanSpawn.z, VanSpawn.w, true, true)
            
            while not DoesEntityExist(car) do --Find delivery vehicle hash
                Wait(25)
            end
            if DoesEntityExist(car) then
                SetVehicleNumberPlateText(car, "DELIV"..tostring(math.random(100, 999)))
                SetVehicleDoorsLocked(car, 1)
                SetEntityDistanceCullingRadius(car, 999999999.0)
                Wait(500) -- Gotta wait here so the plate can be grabbed correctly? Not sure why it takes the server so long to register it.

                deliveryJobs[jobID]["truckID"] = car
                deliveryJobs[jobID]["route"] = PickRandomDeliveryRoute()
                local plate = GetVehicleNumberPlateText(car)
                local members = exports["ps-playergroups"]:getGroupMembers(groupID)
                local groupAmount = #members
                if groupAmount == 1 then
                    deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs1Person
                elseif groupAmount == 2 then
                    deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs2People
                elseif groupAmount == 3 then
                    deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs3People
                else
                    deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs4People
                end
                for i=1, #members do 
                    TriggerClientEvent('vehiclekeys:client:SetOwner', members[i], plate)
                    Wait(100)
                    TriggerClientEvent("delivery:loadBoxesTarget", members[i], NetworkGetNetworkIdFromEntity(deliveryJobs[jobID]["truckID"]))
                    TriggerClientEvent("delivery:toggleDeliveryRoute", members[i], true)
                    TriggerClientEvent("QBCore:Notify", members[i], "Load the boxes from the shelves in to the van", "success")
                end
                exports["ps-playergroups"]:setJobStatus(groupID, "DELIVERY")
            end
        else 
            print("no group id found in jobs")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "You have too many people in your group, come back with "..Delivery.MaxGroupSize.. "or less.", "error")
    end
end)
RegisterServerEvent("delivery:stopGroupJob", function(groupID)
    local src = source
    local jobID = FindDeliveryJobById(groupID)
    local truckCoords = GetEntityCoords(deliveryJobs[jobID]["truckID"])

    -- if #(truckCoords - Delivery.Blip) < 30 then
        DeleteEntity(deliveryJobs[jobID]["truckID"])

        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "deliveryDropoff")
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        local groupPayout = (deliveryJobs[jobID]["totalDropped"] * Delivery.JobPayout)

        for i=1, #members do
            TriggerClientEvent("delivery:endRoute", members[i])
            if groupPayout > 0 then
                local payout = (groupPayout / #members)
                local m = QBCore.Functions.GetPlayer(members[i])
                local cid = m.PlayerData.citizenid
                if Delivery.BuffsEnabled and exports["ps-buffs"]:HasBuff(cid, "oiler") then
                    payout = payout * 1.2
                end
                exports['7rp-payslip']:AddMoney(cid, payout)
                TriggerClientEvent("QBCore:Notify", members[i], "$"..payout.." added to your pay check for the work you've done.", "success")
            end
        end

        deliveryJobs[jobID] = nil
        exports["ps-playergroups"]:setJobStatus(groupID, "WAITING")
    -- else 
    --     TriggerClientEvent("QBCore:Notify", src "Your truck is not inside the facility", "error")
    -- end
end)

RegisterServerEvent("delivery:NewDelivery", function(groupID)
    local src = source
    local jobID = FindDeliveryJobById(groupID)

    exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "deliveryDropoff")
    exports["ps-playergroups"]:setJobStatus(groupID, "DELIVERY")
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    local groupPayout = (deliveryJobs[jobID]["totalDropped"] * 130.00)
    deliveryJobs[jobID]["boxes"] = 0
    deliveryJobs[jobID]["totalDropped"] = 0
    deliveryJobs[jobID]["boxesGrabbed"] = 0
    deliveryJobs[jobID]["boxesLoaded"] = 0
    for i=1, #members do
        TriggerClientEvent("delivery:restartRoute", members[i])
        TriggerClientEvent("delivery:resetDropoff", members[i])
        if groupPayout > 0 then
            local payout = (groupPayout / #members)
            local m = QBCore.Functions.GetPlayer(members[i])
            local cid = m.PlayerData.citizenid
            if exports["ps-buffs"]:HasBuff(cid, "oiler") then
                payout = payout * 1.2
            end
            exports['7rp-payslip']:AddMoney(cid, payout)
            TriggerClientEvent("QBCore:Notify", members[i], "You got $"..payout.." added to your pay check for the On a Delivery Run", "success")
            Wait(500)
            TriggerClientEvent("QBCore:Notify", members[i], "Load up your van again and head to the new delivery", "primary")
         end
    end
end)

RegisterServerEvent("delivery:updateBoxes", function(groupID)
    local src = source
    local jobID = FindDeliveryJobById(groupID)
    deliveryJobs[jobID]["boxes"] = deliveryJobs[jobID]["boxes"] + 1
    deliveryJobs[jobID]["totalDropped"] = deliveryJobs[jobID]["totalDropped"] + 1
    if deliveryJobs[jobID]["boxes"] >= deliveryJobs[jobID]["dropoffAmount"] then
        deliveryJobs[jobID]["boxes"] = 0
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        local groupAmount = #members
        if groupAmount == 1 then
            deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs1Person
        elseif groupAmount == 2 then
            deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs2People
        elseif groupAmount == 3 then
            deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs3People
        else
            deliveryJobs[jobID]["dropoffAmount"] = Delivery.MaxJobs4People
        end
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        for i=1, #members do
            TriggerClientEvent('delivery:dropoffClean', members[i])
            TriggerClientEvent("delivery:toggleAllLoaded", members[i], false)
            TriggerClientEvent("delivery:ReturnToDepot", members[i])
            TriggerClientEvent("delivery:toggleDeliveryFinished", members[i], true)
            TriggerClientEvent("QBCore:Notify", members[i], "All boxes delivered for this store.", "primary")
            Wait(500)
            TriggerClientEvent("QBCore:Notify", members[i], "Return to the depot to load another delivery.", "primary")
        end
        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "deliveryDropoff")
        exports["ps-playergroups"]:setJobStatus(groupID, "DELIVERY FINISHED")
    else
        local members = exports["ps-playergroups"]:getGroupMembers(groupID)
        for i=1, #members do
            TriggerClientEvent("QBCore:Notify", members[i], deliveryJobs[jobID]["boxes"].."/"..deliveryJobs[jobID]["dropoffAmount"].." Boxes Delivered.", "primary")
        end
    end
end)

function CreateDeliveryBlip()
exports["ps-playergroups"]:CreateBlipForGroup(groupID, "deliveryDropoff", {
    label = "Dropoff", 
    coords = Delivery.Routes[newdelivery].coords, 
    sprite = 615, 
    color = 2, 
    scale = 0.8, 
    route = true,
    routeColor = 2,
})
end

RegisterServerEvent('delivery:takePackage', function(groupID)
    local src = source 
    local jobID = FindDeliveryJobById(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    deliveryJobs[jobID]["boxesGrabbed"] = deliveryJobs[jobID]["boxesGrabbed"] + 1
    if deliveryJobs[jobID]["boxesGrabbed"] < deliveryJobs[jobID]["dropoffAmount"] then
        for i=1, #members do
                    TriggerClientEvent("QBCore:Notify", members[i], deliveryJobs[jobID]["boxesGrabbed"].."/"..deliveryJobs[jobID]["dropoffAmount"].." packages grabbed.", "primary")
        end
    elseif deliveryJobs[jobID]["boxesGrabbed"] >= deliveryJobs[jobID]["dropoffAmount"] then
        for i=1, #members do
            TriggerClientEvent("QBCore:Notify", members[i], "All packages grabbed.", "primary")
            TriggerClientEvent("delivery:toggleAllGrabbed", members[i], true)
        end
    end
end)

RegisterServerEvent('delivery:loadPackage', function(groupID)
    local src = source 
    local jobID = FindDeliveryJobById(groupID)
    local members = exports["ps-playergroups"]:getGroupMembers(groupID)
    deliveryJobs[jobID]["boxesLoaded"] = deliveryJobs[jobID]["boxesLoaded"] + 1
    if deliveryJobs[jobID]["boxesLoaded"] < deliveryJobs[jobID]["dropoffAmount"] then
        for i=1, #members do
            TriggerClientEvent("QBCore:Notify", members[i], deliveryJobs[jobID]["boxesLoaded"].."/"..deliveryJobs[jobID]["dropoffAmount"].." packages loaded.", "primary")
        end
    elseif deliveryJobs[jobID]["boxesLoaded"] >= deliveryJobs[jobID]["dropoffAmount"] then
        local newRoute = math.random(1, #Delivery.Routes)
        --print(newRoute)
        for i=1, #members do
            TriggerClientEvent("QBCore:Notify", members[i], "All packages loaded. Head to the delivery location.", "primary")
            TriggerClientEvent("delivery:toggleAllLoaded", members[i], true)
            TriggerClientEvent("delivery:updateDropoff", members[i], newRoute)
            TriggerClientEvent("delivery:startRoute", members[i])
        end
        exports["ps-playergroups"]:RemoveBlipForGroup(groupID, "deliveryDropoff")
        exports["ps-playergroups"]:CreateBlipForGroup(groupID, "deliveryDropoff", {
            label = "Dropoff", 
            coords = Delivery.Routes[newRoute]["coords"], 
            sprite = 615, 
            color = 2, 
            scale = 0.8, 
            route = true,
            routeColor = 2,
        })
        -- exports["ps-playergroups"]:CreateBlipForGroup(groupID, "deliveryDropoff", {
        --     label = "Dropoff", 
        --     coords = Delivery.Routes[newRoute].coords, 
        --     sprite = 162, 
        --     color = 11, 
        --     scale = 1.0, 
        --     route = true,
        --     routeColor = 2,
        -- })
    end
end)

function FindDeliveryJobById(id)
    for i=1, #deliveryJobs do
        if deliveryJobs[i]["groupID"] == id then
            return i
        end
    end
    return 0
end
function PickRandomDeliveryRoute()
    return math.random(1, #Delivery.Routes)
end

QBCore.Functions.CreateCallback('delivery:getStatus', function(status)
    cb(status)
end)