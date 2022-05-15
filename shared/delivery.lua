Delivery = {}

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

DeliveryConfig = {
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

Delivery.PedList = {
    { model = "s_m_m_ups_02", 
    coords = vector3(152.57, -3210.22, 5.89),
    minZ = 3.89,
    maxZ = 7.89, 
    heading = 90.55, 
    gender = "male", 
    scenario = "WORLD_HUMAN_CLIPBOARD", 
    },
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
        coords = vector4(-1219.11, -910.3, 12.33, 297.15),
    },
    [4] = {
        name = "ltdgasoline2",
        coords = vector4(-705.79, -905.04, 19.22, 45.5),
    },
    [5] = {
        name = "robsliquor2",
        coords = vector4(-1484.79, -374.82, 40.16, 52.93),
    },
    [6] = {
        name = "ltdgasoline3",
        coords = vector4(-1825.81, 800.73, 138.11, 78.61),
    },
    [7] = {
        name = "robsliquor3",
        coords = vector4(-2963.09, 391.9, 15.04, 351.34),
    },
    [8] = {
        name = "247supermarket2",
        coords = vector4(-3045.99, 582.27, 7.91, 200.06),
    },
    [9] = {
        name = "247supermarket3",
        coords = vector4(-3249.43, 1000.55, 12.83, 174.48),
    },
    [10] = {
        name = "247supermarket4",
        coords = vector4(1731.06, 6421.65, 35.04, 67.29),
    },
    [11] = {
        name = "247supermarket5",
        coords = vector4(1704.96, 4917.81, 42.06, 276.76),
    },
    [12] = {
        name = "247supermarket6",
        coords = vector4(1956.45, 3746.15, 32.34, 126.67),
    },
    [13] = {
        name = "robsliquor4",
        coords = vector4(1164.8, 2714.13, 38.16, 89.47),
    },
    [14] = {
        name = "247supermarket7",
        coords = vector4(549.89, 2664.27, 42.16, 278.86),
    },
    [15] = {
        name = "247supermarket8",
        coords = vector4(2671.83, 3282.85, 55.24, 149.91),
    },
    [16] = {
        name = "247supermarket9",
        coords = vector4(2550.16, 381.15, 108.62, 178.68),
    },
    [17] = {
        name = "ltdgasoline4",
        coords = vector4(1163.44, -314.12, 69.21, 30.75),
    },
    [18] = {
        name = "robsliquor5",
        coords = vector4(1131.1, -983.98, 46.42, 185.9),
    },
    [19] = {
        name = "247supermarket10",
        coords = vector4(374.28, 333.4, 103.57, 75.88),
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