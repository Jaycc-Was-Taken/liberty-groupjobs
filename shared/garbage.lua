--Devyn Sanitation https://github.com/devin-monro/devyn-sanitation

Garbage = {}
Garbage.MaxGroupSize = 4 -- Max amount of people in a group that can start the job. Suggested 4 as there is only 4 seats in the truck.

Garbage.JobPayout = 44 -- Amount to get paid per bag grabbed. Divided evenly amoung the group

Garbage.BuffsEnabled = true -- True or False to enable the liberty buff system on payout.

Garbage.MaxBags1Person = 6 -- 1 person in group. Amount of bags to be picked up per site.
Garbage.MaxBags2People = 8 -- 2 people in group. Amount of bags to be picked up per site.
Garbage.MaxBags3People = 12 -- 3 people in group. Amount of bags to be picked up per site.
Garbage.MaxBags4People = 16 -- 4 people in group. Amount of bags to be picked up per site.

Garbage.Blip = vector3(-341.56, -1541.3, 26.72)

Garbage.TruckSpawns = {
    vector4(-326.37, -1524.49, 27.54, 267.03),
}

Garbage.Rewards = {
    {
        item  = "plastic",
        min = 2,
        max = 10,
    },
    {
        item  = "rubber",
        min = 2,
        max = 10,
    },
    {
        item  = "metalscrap",
        min = 2,
        max = 10,
    },
    {
        item  = "steel",
        min = 2,
        max = 10,
    },
}
Garbage.Locations = {
    [1] = {
        name = "forumdrive",
        coords = vector4(-168.07, -1662.8, 33.31, 137.5),
    },
    [2] = {
        name = "grovestreet",
        coords = vector4(118.06, -1943.96, 20.43, 179.5),
    },
    [3] = {
        name = "jamestownstreet",
        coords = vector4(297.94, -2018.26, 20.49, 119.5),
    },
    [4] = {
        name = "davisave",
        coords = vector4(424.98, -1523.57, 29.28, 120.08),
    },
    [5] = {
        name = "littlebighornavenue",
        coords = vector4(488.49, -1284.1, 29.24, 138.5),
    },
    [6] = {
        name = "vespucciblvd",
        coords = vector4(307.47, -1033.6, 29.03, 46.5),
    },
    [7] = {
        name = "elginavenue",
        coords = vector4(239.19, -681.5, 37.15, 178.5),
    },
    [8] = {
        name = "elginavenue2",
        coords = vector4(543.51, -204.41, 54.16, 199.5),
    },
    [9] = {
        name = "powerstreet",
        coords = vector4(268.72, -25.92, 73.36, 90.5),
    },
    [10] = {
        name = "altastreet",
        coords = vector4(267.03, 276.01, 105.54, 332.5),
    },
    [11] = {
        name = "didiondrive",
        coords = vector4(21.65, 375.44, 112.67, 323.5),
    },
    [12] = {
        name = "miltonroad",
        coords = vector4(-546.9, 286.57, 82.85, 127.5),
    },
    [13] = {
        name = "eastbourneway",
        coords = vector4(-683.23, -169.62, 37.74, 267.5),
    },
    [14] = {
        name = "eastbourneway2",
        coords = vector4(-771.02, -218.06, 37.05, 277.5),
    },
    [15] = {
        name = "industrypassage",
        coords = vector4(-1057.06, -515.45, 35.83, 61.5),
    },
    [16] = {
        name = "boulevarddelperro",
        coords = vector4(-1558.64, -478.22, 35.18, 179.5),
    },
    [17] = {
        name = "sandcastleway",
        coords = vector4(-1350.0, -895.64, 13.36, 17.5),
    },
    [18] = {
        name = "magellanavenue",
        coords = vector4(-1243.73, -1359.72, 3.93, 287.5),
    },
    [19] = {
        name = "palominoavenue",
        coords = vector4(-845.87, -1113.07, 6.91, 253.5),
    },
    [20] = {
        name = "southrockforddrive",
        coords = vector4(-635.21, -1226.45, 11.8, 143.5),
    },
    [21] = {
        name = "southarsenalstreet",
        coords = vector4(-587.74, -1739.13, 22.47, 339.5),
    },
}