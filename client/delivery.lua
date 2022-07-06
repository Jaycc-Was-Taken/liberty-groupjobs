local QBCore = exports["qb-core"]:GetCoreObject()
local DoingDeliveryRoute = false
local DeliveryFinished = false
local HasBox = false
local BoxObject = nil
local dropoffLocation = vector3(0.0, 0.0, 0.0)
local Truck = nil
local AllLoaded = false
local allGrabbed = false

RegisterNetEvent("delivery:attemptStart", function()
    if exports["ps-playergroups"]:IsGroupLeader() then 
        if exports["ps-playergroups"]:GetJobStage() == "WAITING" then
            local groupID = exports["ps-playergroups"]:GetGroupID()
            
            local model = GetHashKey("Rumpo")
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            TriggerServerEvent("delivery:createGroupJob", groupID)
        else 
            QBCore.Functions.Notify("Your group is already doing something!", "error")
        end
    else 
        QBCore.Functions.Notify("You are not the group leader!", "error")
    end
end)

RegisterNetEvent("delivery:attemptStop", function()
    if exports["ps-playergroups"]:IsGroupLeader() then 
        if exports["ps-playergroups"]:GetJobStage() == "DELIVERY" or exports["ps-playergroups"]:GetJobStage() == "DELIVERY FINISHED" then
            local groupID = exports["ps-playergroups"]:GetGroupID()
            TriggerServerEvent("delivery:stopGroupJob", groupID)
        else 
            QBCore.Functions.Notify("Your group isn't doing a run!", "error")
        end
    else 
        QBCore.Functions.Notify("You are not the group leader!", "error")
    end
end)

RegisterNetEvent("delivery:startRoute", function()
    RouteDeliveryLoop()
end)

RegisterNetEvent("delivery:loadBoxesTarget", function(truckID)
    Truck = NetworkGetEntityFromNetworkId(truckID)
    exports['ps-fuel']:SetFuel(Truck, 100)
    SetVehicleLivery(Truck , 1)
    local BDSDoor = {'door_pside_r', 'door_dside_r'}
    exports['qb-target']:AddTargetBone(BDSDoor, {
        options = { 
        {
            icon = 'fa-solid fa-box',
            label = 'Load Package',
            action = function(entity) 
                LoadBoxAnim()
            end,   
            canInteract = function(entity, distance, data)
                if entity == Truck and HasBox and not AllLoaded then return true end 
                return false
            end,
            },
            {
                icon = 'fa-solid fa-box',
                label = 'Grab Package',
                action = function(entity) 
                    GrabBox()
                end,   
                canInteract = function(entity, distance, data)
                    if entity == Truck and not HasBox and AllLoaded then return true end  -- make it so you only see grab package after all packages loaded
                    return false
                end,
                }
            },
        distance = 1,
    })
    exports['qb-target']:AddBoxZone(Delivery.BoxPickup.name, Delivery.BoxPickup.coords, Delivery.BoxPickup.length, Delivery.BoxPickup.width, {
        name=Delivery.BoxPickup.name,
        heading=Delivery.BoxPickup.heading,
        debugPoly=false,
        minZ=Delivery.BoxPickup.minZ,
        maxZ=Delivery.BoxPickup.maxZ,
    }, {
        options = {
            {
                label = "Grab a Box",
                type = "client",
                icon = "fas fa-circle",
                event = "delivery:grabLoadPackage",
            },
        },
        distance = 1.5,
    })
    
end)

RegisterNetEvent("delivery:endRoute", function()
    local BDSDoor = {'door_pside_r', 'door_dside_r'}
    exports['qb-target']:RemoveTargetBone(BDSDoor, "Grab Package")
    exports['qb-target']:RemoveZone(Delivery.BoxPickup.name, "Grab a Box")
    DoingDeliveryRoute = true
    DeliveryFinished = false
    HasBox = false
    AllLoaded = false
    allGrabbed = false
    Truck = nil
    dropoffLocation = vector3(0.0, 0.0, 0.0)
    Wait(2500)
    StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
    DetachEntity(BoxObject, 1, false)
    DeleteObject(BoxObject)
    BoxObject = nil
end)

RegisterNetEvent("delivery:restartRoute", function()
    DoingDeliveryRoute = true
    DeliveryFinished = false
    HasBox = false
    AllLoaded = false
    allGrabbed = false
    Wait(2500)
    StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
    DetachEntity(BoxObject, 1, false)
    DeleteObject(BoxObject)
    BoxObject = nil
end)

RegisterNetEvent("delivery:dropoffClean", function()
    HasBox = false
    Wait(2500)
    StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
    DetachEntity(BoxObject, 1, false)
    DeleteObject(BoxObject)
    BoxObject = nil
end)

RegisterNetEvent("delivery:updateDropoff", function(coords)
    dropoffLocation = Delivery.Routes[coords]["coords"]
end)

RegisterNetEvent("delivery:resetDropoff", function()
    dropoffLocation = vector3(0.0, 0.0, 0.0)
end)

RegisterNetEvent("delivery:toggleDeliveryRoute", function(status)
    DoingDeliveryRoute = status
end)

function RouteDeliveryLoop()
    DoingDeliveryRoute = true
    local sleep = 2000
    CreateThread(function()
        while DoingDeliveryRoute do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local Distance = #(pos - vector3(dropoffLocation.x, dropoffLocation.y, dropoffLocation.z))
            local DisplayText = false
            if HasBox then
                if Distance < 15 then 
                    sleep = 0
                    LoadAnimation('missfbi4prepp1')
                    -- DrawMarker(27, dropoffLocation.x, dropoffLocation.y, dropoffLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 100, 245, 195, 255, false, false, false, false, false, false, false)
                    if Distance < 1.5 then
                        if not DisplayText and HasBox == true then
                            DisplayText = true
                            exports['qb-core']:DrawText("[E] Deliver Package", "left")
                        end
                        if IsControlJustPressed(0, 51) then
                            HasBox = false
                            DisplayText = false
                            exports['qb-core']:HideText()
                            DeliverBoxAnim()
                        end
                    elseif Distance > 1.5 then
                        if DisplayText then
                            DisplayText = false
                            exports['qb-core']:HideText()
                        end
                    end
                else 
                    sleep = 2000
                end
            end

            Wait(sleep)
        end
    end)
end

function LoadAnimation(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do Wait(10) end
end

function AnimBoxCheck()
    CreateThread(function()
        while HasBox do
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
                ClearPedTasksImmediately(ped)
                LoadAnimation('anim@heists@box_carry@')
                TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(2000)
            if HasBox == false then
                StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
            end
        end
    end)
end

function TakeBoxAnim()
    local ped = PlayerPedId()
    LoadAnimation('anim@heists@box_carry@')
    TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    BoxObject = CreateObject(`hei_prop_heist_box`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(BoxObject, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    AnimBoxCheck()
end

function DeliverBoxAnim()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("deliverpackage", "Delivering Package", 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        DetachEntity(BoxObject, 1, false)
        DeleteObject(BoxObject)
        StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
        BoxObject = nil
        TriggerServerEvent("delivery:updateBoxes", exports["ps-playergroups"]:GetGroupID())
    end, function() -- Cancel
        QBCore.Functions.Notify('Cancelled', 'error', 1500)
        HasBox = true
    end)
end

function LoadBoxAnim()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("loadpackage", "Loading Package", 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        DetachEntity(BoxObject, 1, false)
        DeleteObject(BoxObject)
        StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
        BoxObject = nil
        HasBox = false
        TriggerServerEvent("delivery:loadPackage", exports["ps-playergroups"]:GetGroupID())
    end, function() -- Cancel
        QBCore.Functions.Notify('Cancelled', 'error', 1500)
        HasBox = false
    end)
end

function GrabBox()
    QBCore.Functions.Progressbar("grabpackage", "Grabbing Package", 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        HasBox = true
        TakeBoxAnim()
    end, function() -- Cancel
        QBCore.Functions.Notify('Cancelled', 'error', 1500)
        HasBox = false
    end)
end

function GrabDepotBox()
    local groupID = exports["ps-playergroups"]:GetGroupID()
    QBCore.Functions.Progressbar("grabdepotpackage", "Grabbing Package", 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        HasBox = true
        TakeBoxAnim()
        TriggerServerEvent('delivery:takePackage', groupID)
    end, function() -- Cancel
        QBCore.Functions.Notify('Cancelled', 'error', 1500)
        HasBox = false
    end)
end

function LoadBox()
    QBCore.Functions.Progressbar("grabpackage", "Loading Package", 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        HasBox = false
        LoadBoxAnim()
    end, function() -- Cancel
        QBCore.Functions.Notify('Cancelled', 'error', 1500)
    end)
end
    
RegisterNetEvent("delivery:grabLoadPackage", function()
    if not allGrabbed then
        if not HasBox then
            GrabDepotBox()
        else
            TriggerEvent("QBCore:Notify", "You already have a package", "error")
        end
    else
        TriggerEvent("QBCore:Notify", "You have all the packages you need, head to the delivery point", "primary")
    end
end)

RegisterNetEvent("delivery:toggleAllLoaded", function(status)
    AllLoaded = status
end)

RegisterNetEvent("delivery:toggleAllGrabbed", function(status)
    allGrabbed = status
end)

RegisterNetEvent("delivery:toggleDeliveryFinished", function(status)
    DeliveryFinished = status
end)

RegisterNetEvent("delivery:ReturnToDepot", function()
    SetNewWaypoint(150.28, -3194.66)
end)

RegisterNetEvent("delivery:getNewDelivery", function()
    local groupID = exports["ps-playergroups"]:GetGroupID()
    TriggerServerEvent("delivery:NewDelivery", groupID)
end)