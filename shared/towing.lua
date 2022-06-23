Towing = {}

Towing.TimetoTow = 15000

Towing.JobPayout = math.random(250, 300) -- Amount of cash to pay per job site finished. This is divided evenly among group members.

Towing.MaxJobs1Person = 4 -- 1 person in group. Amount of jobsites completed before the script sends them to return to the depot and end the run
Towing.MaxJobs2People = 8 -- 2 people in group. Amount of jobsites completed before the script sends them to return to the depot and end the run

Towing.MaxGroupSize = 2 -- Max amount of people ina  group that can start a run. 4 is recommended as there are only 4 seats in the truck.



Towing.DropOffZones = {
    vector3(-240.47, -1175.4, 23.04)
    }
Towing.TruckSpawns = {
    vector4(-209.07, -1183.13, 23.14, 90.63),
    vector4(-192.28, -1183.21, 23.14, 90.82),
}

Towing.Vehicles = {
    ["flatbed"] = "Flatbed",
}

Towing.CarModels = {
    "zion",
    "oracle",
    "chino",
    "baller2",
    "stanier",
    "washington",
    "buffalo",
    "feltzer2",
    "asea",
    "fq2",
    "jackal",
	'felon', 
	'sentinel', 
	'windsor',
	'dominator', 
	'dukes', 
	'ellie', 
	'cavalcade', 
	'dubsta2', 
	'asterope', 
	'ingot',
	'primo', 
	'futo', 
    'sultan',
    'dilettante',
    'tornado2',
    'manana',
    'regina',
    'emperor',
    'rancherxl',
    'dynasty',
    'virgo',
    'virgo2',
    'virgo3',
    'voodo',
    'peyote',    

}

Towing.Locations = {
                -- [1] =  {coords = vector3(-191.26, -1174.11, 23.04)}, -- for debug
                [1] = {coords = vector3(391.26, -1290.94, 32.9)},
                [2] = {coords = vector3(299.5, -1202.71, 28.52)},
                [3] = {coords = vector3(233.26, -774.03, 30.09)},
                [4] = {coords = vector3(172.76, -687.98, 32.47)},
                [5] =  {coords = vector3(2563.97, 397.81, 107.94)},
                [6] =  {coords = vector3(-3062.8, 410.56, 6.06)},
                [7] =  {coords = vector3(-3051.34, 637.54, 7.02)},
                [8] =  {coords = vector3(-3221.61, 996.33, 11.83)},
                [9] =  {coords = vector3(-3208.28, 1091.8, 9.87)},
                [10] = {coords = vector3(-3155.47, 1292.83, 14.22)},
                [11] = {coords = vector3(-2972.54, 2021.4, 34.24)},
                [12] = {coords = vector3(-2546.66, 2348.65, 32.46)},
                [13] = {coords = vector3(-2459.76, 3634.27, 13.73)},
                [14] = {coords = vector3(-2298.59, 4152.39, 37.95)},
                [15] = {coords = vector3(-2188.72, 4260.13, 48.01)},
                [16] = {coords = vector3(-2068.96, 4445.15, 58.14)},
                [17] = {coords = vector3(-1486.87, 4992.26, 62.26)},
                [18] = {coords = vector3(-773.58, 5530.8, 32.87)},
                [19] = {coords = vector3(-726.99, 5821.05, 16.67)},
                [20] = {coords = vector3(-419.61, 6087.0, 30.67)},
                [21] = {coords = vector3(-405.14, 6224.23, 30.72)},
                [22] = {coords = vector3(-29.3, 6495.72, 30.9)},
                [23] = {coords = vector3(2299.84, 5028.21, 43.3)},
                [24] = {coords = vector3(2170.29, 4884.86, 40.07)},
                [25] = {coords = vector3(2147.39, 3021.31, 44.5)},
                [26] = {coords = vector3(1763.28, 3366.03, 39.27)},
                [27] = {coords = vector3(1706.81, 3568.01, 34.92)},
                [28] = {coords = vector3(1588.3, 3735.35, 33.94)},
                [29] = {coords = vector3(119.62, -287.12, 45.66)},
                [30] = {coords = vector3(137.92, -376.43, 42.61)},
                [31] = {coords = vector3(-47.02, -786.47, 43.52)},
                [32] = {coords = vector3(-291.5, -616.93, 32.77)},
                [33] = {coords = vector3(-310.81, -686.64, 32.46)},
                [34] = {coords = vector3(-487.83, -615.8, 30.52)},
                [35] = {coords = vector3(-660.3, -621.14, 24.66)},
                [36] = {coords = vector3(-791.48, -588.89, 29.48)},
                [37] = {coords = vector3(-1136.1, -757.99, 18.37)},
                [38] = {coords = vector3(-1200.81, -729.69, 20.45)},
                [39] = {coords = vector3(-1517.97, -546.8, 32.48)},
                [40] = {coords = vector3(-1662.52, -298.23, 51.04)},
                [41] = {coords = vector3(-1899.73, -332.76, 48.59)},
                [42] = {coords = vector3(-1774.56, -516.74, 38.15)},
                [43] = {coords = vector3(-1483.88, -661.3, 28.29)},
                [44] = {coords = vector3(-1482.89, -736.89, 24.7)},
                [45] = {coords = vector3(-1585.47, -1030.24, 12.37)},
                [46] = {coords = vector3(-1652.66, -921.38, 7.71)},
                [47] = {coords = vector3(-1847.69, -614.68, 10.56)},
                [48] = {coords = vector3(-2044.42, -469.76, 10.98)},
                [49] = {coords = vector3(-2165.99, -389.26, 12.65)},
                [50] = {coords = vector3(-1645.86, -239.28, 54.14)},
                [51] = {coords = vector3(-1312.6, 250.38, 61.41)},
                [52] = {coords = vector3(-939.25, 307.87, 70.51)},
                [53] = {coords = vector3(-447.57, 222.1, 82.42)},
                [54] = {coords = vector3(-376.96, 298.48, 84.24)},
                [55] = {coords = vector3(-312.07, 229.19, 87.16)},
                [56] = {coords = vector3(-205.43, 301.47, 96.3)},
                [57] = {coords = vector3(-87.56, 205.07, 94.64)},
                [58] = {coords = vector3(-136.2, 195.69, 89.28)},
                [59] = {coords = vector3(-104.06, 87.77, 70.84)},
                [60] = {coords = vector3(57.75, 18.84, 68.71)},
                [61] = {coords = vector3(227.55, -39.88, 69.02)},
                [62] = {coords = vector3(486.19, -34.44, 77.07)},
                [63] = {coords = vector3(490.66, -51.75, 88.2)},
                [64] = {coords = vector3(680.08, 259.14, 93.0)},
                [65] = {coords = vector3(626.71, 164.76, 95.67)},
                [66] = {coords = vector3(422.47, 240.87, 102.54)},
                [67] = {coords = vector3(357.45, 282.35, 102.75)},
                [68] = {coords = vector3(178.11, 380.98, 108.35)},
                [69] = {coords = vector3(-226.41, -268.27, 48.35)},
                [70] = {coords = vector3(-348.49, -1404.51, 29.46)},
                [71] = {coords = vector3(-250.59, -249.24, 35.87)},
                [72] = {coords = vector3(-221.96, -1490.1, 30.63)},
                [73] = {coords = vector3(-53.99, -1688.59, 28.84)},
                [74] = {coords = vector3(-8.0, -1743.62, 28.65)},
                [75] = {coords = vector3(171.94, -1810.53, 28.16)},
                [76] = {coords = vector3(92.96, -1829.27, 25.22)},
                [77] = {coords = vector3(276.35, -2070.06, 16.4)},
                [78] = {coords = vector3(320.83, -2021.76, 20.14)},
                [79] = {coords = vector3(404.38, -1918.59, 24.28)},
                [80] = {coords = vector3(463.99, -1899.79, 24.73)},
                [81] = {coords = vector3(594.34, -1874.71, 24.3)},
                [82] = {coords = vector3(472.15, -1574.73, 28.47)},
                [83] = {coords = vector3(438.71, -1479.37, 28.65)},
                [84] = {coords = vector3(421.06, -1277.3, 29.61)},
                [85] = {coords = vector3(9.68, -593.35, 30.98)},
}