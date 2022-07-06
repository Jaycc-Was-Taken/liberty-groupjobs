Config = {}
Config = {
    Blips = true,
    BlipNamer = true,
    Pedspawn = true,
    Invincible = true,
    Frozen = true,
    Stoic = true,
    Fade = true,
    Distance = 40.0,
    MinusOne = true,
}
Config.BuffsEnabled = true -- If you use the ps-buffs or not and want the payout to be altered by a buff
Config.BuffName = "oiler" -- Name of the buff
Config.BuffAmount = 20 -- Percent
Config.PedList = {
    [1] = {  -- Towing
        model = "s_m_m_autoshop_02",
        coords = vector3(-227.81, -1176.34, 23.04),
        minZ = 21.16,
        maxZ = 25.16, 
        heading = 174.66, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
            type = "client",
            event = "towing:attemptStart",
            label = 'Start Tow Work',
            icon = 'fa-solid fa-circle',
            canInteract = function()
                if exports["ps-playergroups"]:GetJobStage() == "WAITING" then return true end
                return false
            end,
            },
            {
            type = "client",
            event = "towing:attemptStop",
            icon = "bi bi-arrow-right-circle-fill",
            label = "End Work",
            canInteract = function()
                if exports["ps-playergroups"]:GetJobStage() == "TOWING" then return true end
                return false
            end,
            },
        },
        blipInfo = {
            sprite = 68,
            color = 5,
            scale = 0.7,
            text = "Towing HQ",
            enable = true,
        },
    },
    [2] = { -- Garbage
        model = "s_m_y_garbage", 
        coords = vector3(-354.96, -1542.28, 27.72),
        minZ = 25.72,
        maxZ = 29.72, 
        heading = 270.0, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
                type = "client",
                event = "garbage:attemptStart",
                label = 'Start Garbage Run',
                icon = 'fa-solid fa-circle',
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "WAITING" then return true end
                    return false
                end,
            },
            {
                type = "client",
                event = "garbage:attemptStop",
                label = 'Complete Garbage Run',
                icon = 'fa-solid fa-circle',
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "GARBAGE" then return true end
                    return false
                end,
            },
        },
        blipInfo = {
            sprite = 318,
            color = 2,
            scale = 0.7,
            text = "Sanitation",
            enable = true,
        },
    },
    [3] = { -- Delivery 
        model = "s_m_m_ups_02", 
        coords = vector3(152.57, -3210.22, 5.89),
        minZ = 3.89,
        maxZ = 7.89, 
        heading = 90.55, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
                type = "client",
                event = "delivery:attemptStart",
                label = 'Start Delivery Run',
                icon = 'fa-solid fa-circle',
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "WAITING" then return true end
                    return false
                end,
            },
            {
                type = "client",
                event = "delivery:attemptStop",
                label = 'Stop Working',
                icon = 'fa-solid fa-circle',
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "DELIVERY" or exports["ps-playergroups"]:GetJobStage() == "DELIVERY FINISHED" then return true end
                    return false
                end,
            },
            {
                type = "client",
                event = "delivery:getNewDelivery",
                label = 'Get Another Delivery',
                icon = 'fa-solid fa-circle',
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "DELIVERY FINISHED" then return true end
                    return false
                end,
            },
        },
        blipInfo = {
            sprite = 616,
            color = 2,
            scale = 0.7,
            text = "Delivery Depot",
            enable = true,
        },
    },
    [4] = { -- Electrician
        model = "s_m_m_dockwork_01", 
        coords = vector3(736.77, 132.61, 80.71),
        minZ = 78.71,
        maxZ = 82.71, 
        heading = 241.35, 
        gender = "male", 
        scenario = "",
        options = {
            {
                type = "client",
                event = "electric:attemptStart",
                label = 'Start Electrician Work',
                icon = 'fa-solid fa-circle',
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "WAITING" then return true end
                    return false
                end,
            },
            {
                type = "client",
                event = "electric:attemptStop",
                icon = "bi bi-arrow-right-circle-fill",
                label = "End Work",
                canInteract = function()
                    if exports["ps-playergroups"]:GetJobStage() == "ELECTRICIAN" then return true end
                    return false
                end,
            },
        },
        blipInfo = {
            sprite = 354,
            color = 5,
            scale = 1.0,
            text = "LS Water & Power",
            enable = true,
        },
    },
}