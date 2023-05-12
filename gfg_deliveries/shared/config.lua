Config = {
    language = "en",                                            -- Language sets which Locale to use, you can find available locales in [gfg_deliveries/locale/], we will add more as they become available but feel free to add your own.
    debug = false,                                               -- Determines whether to send debug print statements to the client and server when using the script (Debug should only used in a development environment)
    enhancedDebug = false,                                       -- Determines whether to send enhanced debug print statements to the client and server when using the script (Enhanced Debug should only used in a development environment)
    interactionMethod = "3dtext",                               -- Determines the method in which players interact. Currently supported options are: "target", "textui", "3dtext".
    interactionDistance = 2,                                    -- Determines the distance from the interaction point that the interaction is activated.
    truckInteractionDistance = 0.5,                             -- Determines the distance from the truck bone that the interaction is available.
    drawMarker = {                                              -- Determines 3d marker variables.
        enable = true,                                          -- Determines whether to draw a 3d marker at the dropoff point.
        type = 3,                                               -- Determines the type of marker to draw.
        scale = vec3(1.0, 1.0, 0.5),                            -- Determines the scale of the marker.
        color = {r = 255, g = 255, b = 255, alpha = 100},       -- Determines the color and transparency of the marker.
        bob = true,                                             -- Determines wether the marker bobs up and down.
        faceCamera = true                                       -- Determines if the marker always faces the camera.
    },
    inventory = "ox_inventory",                                 -- Determines wich inventory resource to use. Currently supported options are: "ox_inventory", "qb_inventory" or "custom".
    useKeys = true,                                             -- Determines wether or not to trigger the give and remove keys function in sv_customize.lua.
}

Config.Defaults = {                                             -- Configuration for the default values used if specific variable for a delivery type are omitted.
    ped = {                                                     -- Determines default ped variables.
        model = 's_m_m_postal_01',                              -- Determines the default ped model.
        scenario = 'WORLD_HUMAN_CLIPBOARD',                     -- Determines the default ped scenario.
    },
    blip = {                                                    -- Determines default blip variables.
        sprite = 67,                                            -- Determines the default blip sprite.
        scale = 0.7,                                            -- Determines the default blip scale.
        color = 60,                                             -- Determines the default blip color.
    },
    reward = {                                                  -- Determines default reward variables.
        type = "item",                                          -- Determines the default reward type, supported options are "bank" and "item".
        itemName = "money",                                     -- Determines the default item reward name, only used if 'reward.type' is 'item'.
        distanceMultiplier = 0.2,                               -- Determines the default distance multiplier.
        boxWorth = 25,                                          -- Determines the default value for each package delivered.
        amount = 100                                            -- Determines the default value for each stop completed.
    },
    stops = {                                                   -- Determines default stop variables.
        blip = {                                                -- Determines default stop blip variables.
            sprite = 538,                                       -- Determines the default stop blip sprite.
            scale = 0.7,                                        -- Determines the default stop blip scale.
            color = 60                                          -- Determines the default stop blip color.
        }
    },
    vehicle = {                                                 -- Determines the default vehicle variables.
        bone = 'door_dside_r',                                  -- Determines the default vehicle interaction bone.
    }
}

Config.DeliveryTypes = {
    ['Go Postal'] = {                                           -- This is the name of the 'delivery type' (!!! WARNING !!! This needs to be unique).
        ped = {                                                 -- Determines ped variables.
            coords = vec4(78.6920, 111.8125, 81.1682, 243.2043),-- Determines the coords of the ped (Needs to be a vector4).
            model = 's_m_m_postal_01',                          -- Determines the ped model. (Optional)
            scenario = 'WORLD_HUMAN_CLIPBOARD',                 -- Determines the ped scenario. (Optional)
        },
        blip = {                                                -- Determines blip variables.
            label = "Go Postal Deliveries",                     -- Determines the label of the blip.
            sprite = 67,                                        -- Determines the blip sprite. (Optional)
            scale = 0.7,                                        -- Determines the blip scale. (Optional)
            color = 60,                                         -- Determines the blip color. (Optional)
        },
        vehicle = {                                             -- Determines the vehicle variables.
            model = -233098306, -- boxville2                    -- Determines the model of vehicle to be provided (Needs to be the signed hash).
            coords = {                                          -- Determines the locations where vehicles will be spawned.
                vec4(61.3824, 125.1748, 79.2214, 157.9575),     -- Needs to be a vector4.
                vec4(66.1251, 123.9437, 79.1611, 157.8927),
                vec4(69.6611, 122.9135, 79.1693, 154.1517),
                vec4(73.4137, 120.9988, 79.1908, 157.8834),
            },
            image = 'https://gtacars.net/images/5fba0818d071f7ff7a1f03d41d2564a0', -- Determines the image to be displayed in the menu.
            bone = 'door_dside_r',                              -- Determines the vehicle interaction bone. (Optional)
        },
        boxes = {                                               -- Determines the amount of boxes per stop.
            minAmount = 1,                                      -- Minimum amount.
            maxAmount = 2                                       -- Maximum amount.
        },
        reward = {                                              -- Determines reward variables. (Optional)
            type = "item",                                      -- Determines the reward type, supported options are "bank" and "item". (Optional)
            itemName = "money",                                 -- Determines the item reward name, only used if 'reward.type' is 'item'. (Optional)
            distanceMultiplier = 0.2,                           -- Determines the distance multiplier. (Optional)
            boxWorth = 25,                                      -- Determines the value for each package delivered. (Optional)
            amount = 100                                        -- Determines the value for each stop completed. (Optional)
        },
        stops = {                                               -- Determines stop variables.
            minAmount = 5,                                      -- Determines the minimum amount of stops.
            maxAmount = 10,                                     -- Determines the maximum amount of stops.
            blip = {                                            -- Determines stop blip variables. (Optional)
                sprite = 538,                                   -- Determines the stop blip sprite. (Optional)
                scale = 0.7,                                    -- Determines the stop blip scale. (Optional)
                color = 18,                                     -- Determines the stop blip color. (Optional)
            },
            locations = CommonDeliverys.locations,              -- Determines the stops that can be chosen for this delivery type.
            targets = CommonDeliverys.targets                   -- Determines the dropoff targets for this delivery type.
            -- Locations and targets need to be in the same order (1st entry in targets, is the dropoff target for the 1st entry in locations).
        }
    },
    ['Post-Op'] = {
        ped = {
            coords = vec4(-422.9762, -2788.4329, 6.0004, 315.3905),
            model = 's_m_m_ups_01'
        },
        blip = {
            label = "Post Op Deliveries",
        },
        vehicle = {
            model = 444171386, -- boxville4
            coords = {
                vec4(-413.3502, -2793.8215, 6.0004, 318.7370),
                vec4(-408.0440, -2799.0383, 6.0004, 314.3772),
            },
            image = 'https://gtacars.net/images/2ea6f9f4da281baa76e8492eb8685a50'
        },
        boxes = {
            minAmount = 1,
            maxAmount = 2
        },
        reward = {
            distanceMultiplier = 0.2,
            boxWorth = 35,
            amount = 125
        },
        stops = {
            minAmount = 5,
            maxAmount = 10,
            blip = {
                color = 31,
            },
            locations = CommonDeliverys.locations,
            targets = CommonDeliverys.targets
        }
    },
    ['24/7'] = {
        ped = {
            coords = vec4(801.4267, -2498.2400, 21.1458, 72.7055),
            model = 's_m_m_gentransport',
        },
        blip = {
            label = "24/7 Deliveries",
            sprite = 477,
            color = 2,
        },
        vehicle = {
            model = 904750859, -- mule
            coords = {
                vec4(782.4951, -2472.5037, 20.3712, 176.8277),
                vec4(786.5690, -2471.0957, 20.5752, 175.0144),
                vec4(793.4912, -2471.2219, 21.0176, 179.9093),
            },
            image = 'https://gtacars.net/images/f1889a6ca3c797dcb79d87d8a31643b4'
        },
        boxes = {
            minAmount = 2,
            maxAmount = 6
        },
        reward = {
            distanceMultiplier = 0.2,
            boxWorth = 50,
            amount = 150
        },
        stops = {
            minAmount = 1,
            maxAmount = 3,
            blip = {
                color = 2,
            },
            locations = {
                vec3(29.109, -1348.248, 29.496), -- Strawberry 247
                vec3(376.299, 322.467, 103.437), -- Downtown Vineood 247
                vec3(-3236.8264, 1004.4056, 12.4528), -- Chumash 247
                vec3(-3036.4502, 595.1279, 7.8125), -- Banham 247
                vec3(2563.3022, 385.6450, 108.4709),  -- Palomino Fwy 247
                vec3(543.8124, 2675.2800, 42.1542), -- Route 68 247 #1
                vec3(2683.9314, 3281.4089, 55.2405), -- Senora Fwy 247 
                vec3(1966.5757, 3738.2549, 32.2027), -- Sandy Shores 247
                vec3(1729.5510, 6408.2178, 34.3459), -- Procopio Truck stop 247
                vec3(1159.387, -325.542, 69.205), -- Mirror Park 247
                vec3(-52.216, -1755.597, 29.421), -- Davis 247
            },
            targets = {
                vec3(25.356, -1339.491, 29.497), -- Strawberry 247
                vec3(375.514, 334.839, 103.566), -- Downtown Vineood 247
                vec3(-3250.0178, 1001.1556, 12.8307), -- Chumash 247
                vec3(-3046.6392, 582.4778, 7.9089), -- Banham 247
                vec3(2549.4946, 381.7044, 108.6229),  -- Palomino Fwy 247
                vec3(549.7189, 2663.4678, 42.1565), -- Route 68 247 #1
                vec3(2671.2991, 3283.6487, 55.2411), -- Senora Fwy 247
                vec3(1956.6353, 3746.9175, 32.3437), -- Sandy Shores 247
                vec3(1731.7041, 6422.0830, 35.0372), -- Procopio Truck stop 247
                vec3(1163.135, -313.367, 69.205), -- Mirror Park 247
                vec3(-40.682, -1750.848, 29.421), -- Davis 247
            }
        }
    },
    ['Liqour'] = {
        ped = {
            coords = vec4(847.3294, -1945.6515, 27.9802, 119.3576),
            model = 's_m_m_gentransport',
        },
        blip = {
            label = "Liqour Deliveries",
            sprite = 477,
            color = 6,
        },
        vehicle = {
            model = 904750859, -- mule
            coords = {
                vec4(845.82, -1953.16, 28.95, 85.03),
                vec4(837.2485, -1935.9860, 28.9675, 175.3186),
            },
            image = 'https://gtacars.net/images/f1889a6ca3c797dcb79d87d8a31643b4'
        },
        boxes = {
            minAmount = 2,
            maxAmount = 6
        },
        reward = {
            distanceMultiplier = 0.2,
            boxWorth = 50,
            amount = 150
        },
        stops = {
            minAmount = 1,
            maxAmount = 3,
            blip = {
                color = 6,
            },
            locations = {
                vec3(-1226.046, -903.225, 12.338), -- Vespucci liqour
                vec3(-1490.124, -382.535, 40.175), -- MorningWood Liqour
                vec3(1144.8458, -980.3021, 46.2167), -- Murietta Heights Liqour
                vec3(-2977.1069, 391.2003, 15.0254), -- Great Ocean Hwy Liqour
                vec3(1166.7745, 2698.6431, 37.9721), -- Route 68 Liqour
                vec3(1395.1881, 3596.7114, 34.9819), -- Sandy Shores Liqour
            },
            targets = {
                vec3(-1222.817, -912.563, 12.326), -- Vespucci liqour
                vec3(-1481.55, -377.794, 40.163), -- MorningWood Liqour
                vec3(1130.7246, -979.8616, 46.4158), -- Murietta Heights Liqour
                vec3(-2963.5098, 387.9053, 15.0433), -- Great Ocean Hwy Liqour
                vec3(1168.8506, 2713.7915, 38.1577), -- Route 68 Liqour
                vec3(1390.3180, 3608.1401, 34.9809), -- Sandy Shores Liqour
            }
        }
    },
}