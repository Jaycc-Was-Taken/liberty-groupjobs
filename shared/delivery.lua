Delivery = {}
Delivery = {
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
Delivery.MaxGroupSize = 4 -- Max amount of people in a group that can start the job. Suggested 4 as there is only 4 seats in the truck.
Delivery.JobPayout = 130 -- Amount to get paid per stop. Divided evenly amoung the group
Delivery.BuffsEnabled = true -- True or False to enable the liberty buff system on payout.
Delivery.MaxJobs1Person = 4 -- 1 person in group. Amount of jobsites completed before the script sends them to return to the depot and end the run
Delivery.MaxJobs2People = 6 -- 2 people in group. Amount of jobsites completed before the script sends them to return to the depot and end the run
Delivery.MaxJobs3People = 9 -- 3 people in group. Amount of jobsites completed before the script sends them to return to the depot and end the run
Delivery.MaxJobs4People = 12 -- 4 people in group. Amount of jobsites completed before the script sends them to return to the depot and end the run
Delivery.Blip = {
    vector3(150.28, -3194.66, 5.86),
}
Delivery.BoxPickup = {
    coords = vector3(148.23, -3178.82, 5.86),
    length = 5.2,
    width = 1,
    heading = 270,
    minZ = 3.86,
    maxZ = 7.86,
    name = "boxpickup",
}
Delivery.VanSpawns = {
    vector4(161.92, -3204.0, 5.96, 272.03),
    vector4(161.03, -3196.5, 5.98, 271.88)
}
Delivery.Routes = {
    [1] = {
        name = "hardwarepeleto",
        coords = vector4(-437.84, 6147.86, 31.48, 315.46),
    },
    [2] = {
        name = "247supermarket",
        coords = vector4(31.62, -1315.87, 29.52, 179.5),
    },
    [3] = {
        name = "robsliquor",
        coords = vector4(-1226.54, -907.56, 12.33, 305.21),
    },
    [4] = {
        name = "ltdgasoline2",
        coords = vector4(-713.82, -909.1, 19.22, 180.63),
    },
    [5] = {
        name = "robsliquor2",
        coords = vector4(-1486.02, -382.54, 40.16, 48.46),
    },
    [6] = {
        name = "ltdgasoline3",
        coords = vector4(-1829.18, 792.08, 138.26, 219.8),
    },
    [7] = {
        name = "robsliquor3",
        coords = vector4(-2969.69, 387.72, 15.04, 358.92),
    },
    [8] = {
        name = "247supermarket2",
        coords = vector4(-3045.12, 587.22, 7.91, 286.81),
    },
    [9] = {
        name = "247supermarket3",
        coords = vector4(-3246.94, 1004.79, 12.83, 271.24),
    },
    [10] = {
        name = "247supermarket4",
        coords = vector4(1734.01, 6417.8, 35.04, 157.05),
    },
    [11] = {
        name = "247supermarket5",
        coords = vector4(1706.49, 4927.02, 42.06, 59.33),
    },
    [12] = {
        name = "247supermarket6",
        coords = vector4(1961.36, 3746.61, 32.34, 212.12),
    },
    [13] = {
        name = "robsliquor4",
        coords = vector4(1169.12, 2707.57, 38.16, 91.2),
    },
    [14] = {
        name = "247supermarket7",
        coords = vector4(545.4, 2665.74, 42.16, 7.82),
    },
    [15] = {
        name = "247supermarket8",
        coords = vector4(2675.79, 3285.74, 55.24, 240.74),
    },
    [16] = {
        name = "247supermarket9",
        coords = vector4(2552.33, 385.29, 108.62, 270.34),
    },
    [17] = {
        name = "ltdgasoline4",
        coords = vector4(1155.89, -319.68, 69.21, 192.11),
    },
    [18] = {
        name = "robsliquor5",
        coords = vector4(1136.86, -978.75, 46.42, 189.3),
    },
    [19] = {
        name = "247supermarket10",
        coords = vector4(378.02, 330.27, 103.57, 164.85),
    },
    [20] = {
        name = "hardware",
        coords = vector4(89.33, -1745.44, 30.08, 143.5),
    },
    [21] = {
        name = "hardware2",
        coords = vector4(2704.09, 3457.55, 55.53, 339.5),
    },
}
Delivery.Locales = {
    --QB Notify
    ['group-busy'] = 'Your group is already doing something!',
    ['not-leader'] = 'You are not the group leader.',
    ['not-on-run'] = 'Your group isn\'t doing a run.',
    ['package-error'] = 'You already have a package',
    ['all-packages-error'] = 'You have all the packages you need, head to the delivery point.',
    ['group-too-big'] = 'You have too many people in your group, come back with '..Delivery.MaxGroupSize..'or less.',
    ['go-load-boxes'] = 'Load the boxes from the shelves in to the van.',
    ['paycheck-notify'] = ' added to your pay check for the On a Delivery Run.',

    --Draw Text
    ['deliver-package'] = '[E] Deliver Package',

    --QB Target
    ['load-package'] = 'Load Package',
    ['unload-package'] = 'Unload Package',
    ['grab-package'] = 'Grab Package',
    ['start-run'] = 'Start Delivery Run',
    ['stop-run'] = 'Stop Working',
    ['get-new-run'] = 'Get Another Delivery',

    --Progress Bar
    ['delivering-package'] = 'Delivering Package...',
    ['loading-package'] = 'Loading Package...',
    ['unloading-package'] = 'Unloading Package...',
}