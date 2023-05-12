local ox_inventory = exports.ox_inventory
Locale = {}
deliveryPeds = {}
pedsCreated = false
print("^4GFG Deliveries. Version: "..GetResourceMetadata(GetCurrentResourceName(), 'version', 0).."^0")

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    for _, ped in pairs(GetAllPeds()) do
        local pedCoords = GetEntityCoords(ped)
        for k, deliveryLocation in pairs(Config.DeliveryTypes) do
            local deliveryCoords = vec3(deliveryLocation.ped.coords.x, deliveryLocation.ped.coords.y, deliveryLocation.ped.coords.z)
            local dist = #(pedCoords - deliveryCoords)
            if dist < 2 then
                DeleteEntity(ped)
            end
        end
    end

    -- Creates the necessary peds on resource start
    TriggerEvent("gfg_deliveries:server:initPeds")
end)

RegisterServerEvent("gfg_deliveries:server:initPeds")
AddEventHandler("gfg_deliveries:server:initPeds", function()
    print("^4Initializing Delivery Peds^0")

    -- Goes through every delivery type in config
    for k, deliveryType in pairs(Config.DeliveryTypes) do

        -- Sets the model to default if omitted
        deliveryType.ped.model = deliveryType.ped.model or Config.Defaults.ped.model

        -- Sets the ped scenario to default if omitted
        deliveryType.ped.scenario = deliveryType.ped.scenario or Config.Defaults.ped.scenario

        -- Creates the ped
        pedEntity = CreatePed(0, deliveryType.ped.model, deliveryType.ped.coords, true, false)

        -- Applies ped attributes
        FreezeEntityPosition(pedEntity, true)
        SetPedConfigFlag(pedEntity, 43, true) -- CPED_CONFIG_FLAG_DisablePlayerLockon
        SetPedConfigFlag(pedEntity, 128, false) -- CPED_CONFIG_FLAG_CanBeAgitated

        -- Sets the ped data for the internal tablea
        ped = {}
        ped.deliveryType = k
        ped.entity = pedEntity
        ped.netId = NetworkGetNetworkIdFromEntity(pedEntity)
        ped.scenario = deliveryType.ped.scenario

        deliveryPeds[ped.deliveryType] = ped
    end

    pedsCreated = true
    print("^2Delivery Peds Initialized^0")
    
end)

lib.callback.register('gfg_deliveries:getPeds', function(source)
    debug_print("Player: "..source.." is requesting peds.", 1)
    while not pedsCreated do
        Wait(500)
        print("^1Waiting for peds to be created^0")
    end

    debug_print("Peds are created, sending them to player: "..source, 1)
    return deliveryPeds
end)

RegisterServerEvent("gfg_deliveries:server:giveKeys")
AddEventHandler("gfg_deliveries:server:giveKeys", function(vehiclePlate)
    if Config.useKeys then
        local source = source
        local plate = vehiclePlate
        giveKeys(source, plate)
    end
end)

RegisterServerEvent("gfg_deliveries:server:removeKeys")
AddEventHandler("gfg_deliveries:server:removeKeys", function(vehiclePlate)
    if Config.useKeys then
        local source = source
        local plate = vehiclePlate
        removeKeys(source, plate)
    end
end)

RegisterServerEvent("gfg_deliveries:server:payout")
AddEventHandler("gfg_deliveries:server:payout", function(distance, dropoffCount, boxesDropped, pedType)
    local source = source

    -- Sets default vlaues for the reward if omitted
    pedType.reward = pedType.reward or Config.Defaults.reward
    pedType.reward.type = pedType.reward.type or Config.Defaults.reward.type
    pedType.reward.itemName = pedType.reward.itemName or Config.Defaults.reward.itemName
    pedType.reward.distanceMultiplier = pedType.reward.distanceMultiplier or Config.Defaults.reward.distanceMultiplier
    pedType.reward.boxWorth = pedType.reward.boxWorth or Config.Defaults.reward.boxWorth
    pedType.reward.amount = pedType.reward.amount or Config.Defaults.reward.amount

    -- Calculates reward amounts
    local dropoffPayout = dropoffCount * pedType.reward.amount
    local boxPayout = boxesDropped * pedType.reward.boxWorth
    local distancePayout = distance * pedType.reward.distanceMultiplier
    local totalPayout = dropoffPayout + boxPayout + distancePayout

    debug_print("Total Payout: "..totalPayout.." From (Dropoff Payout: "..dropoffPayout.." | Box Payout: "..boxPayout.." | Distance Payout: "..distancePayout..")", 1)

    if pedType.reward.type == 'item' then
        if Config.inventory == "ox_inventory" then
            exports.ox_inventory:AddItem(source, pedType.reward.itemName, totalPayout)
    
        elseif Config.inventory == "qb-inventory" then
            local Player = QBCore.Functions.GetPlayer(source)
            Player.Functions.AddItem(pedType.reward.itemName, totalPayout)
            
        elseif Config.inventory == "custom" then
            itemPayout(source, pedType.reward.itemName, totalPayout)
        end
    elseif pedType.reward.type == 'bank' then
        bankPayout(source, totalPayout)
    else
        print("^1No Valid Reward Type Found in reward.type^0")
    end


end)


-- Library Functions [DO NOT TOUCH]

function Lang(what)
	local Dict = Locale[Config.language]
	if not Dict[what] then return Locale["en"][what] end -- If we cant find a translation, use the english one.
	return Dict[what]
end

function debug_print(data, level)
    if level == 1 and Config.debug then
       print(data)
    elseif level == 2 and Config.enhancedDebug then
       print(data)
    elseif Config.debug then
        print("No level is defined for the following information:")
        print(data)
    end
end