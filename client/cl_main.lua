local ox_inventory = exports.ox_inventory
local deliveryPeds = {}
Locale = {}
local menuOpen = false
local dropoffCount = 0
local distance = 0
local hasBox = false
local hasTargetMenu = false

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    else
        if Config.target == "qb_target" then
            local QBCore = exports['qb-core']:GetCoreObject()
        end
        Wait(0)
        createBlips()
        deliveryPeds = lib.callback.await('gfg_deliveries:getPeds', false)
        createPedInteractions()
    end
end)

function createPedInteractions()
    for k, ped in pairs(deliveryPeds) do
        local pedType = Config.DeliveryTypes[ped.deliveryType]
        ped.hasMenu = false

        local point = lib.points.new({
            coords = pedType.ped.coords,
            distance = Config.interactionDistance,
            deliveryType = k
        })

        function point:onEnter()
            entity = NetworkGetEntityFromNetworkId(ped.netId)
            entCoords = GetEntityCoords(entity)

            if Config.interactionMethod == "target" then
                if not ped.hasMenu then
                    ped.hasMenu = true
                    local pedOptions = {{
                        name = ped.deliveryType..'_ped',
                        icon = 'fa-solid fa-truck-ramp-box',
                        label = string.format(Lang('menuTitle'), ped.deliveryType),
                        onSelect = function()
                            TriggerEvent('gfg_deliveries:client:openMenu', ped)
                        end 
                    }}
                    exports.ox_target:addEntity(ped.netId, pedOptions)
                end
            end
            if Config.interactionMethod == "textui" then
                lib.showTextUI('[E] - '..string.format(Lang('interactionPrompt'), ped.deliveryType))
            end
            SetPedCombatAttributes(NetworkGetEntityFromNetworkId(ped.netId), 292, true)
            SetEntityInvincible(NetworkGetEntityFromNetworkId(ped.netId), true)
            FreezeEntityPosition(NetworkGetEntityFromNetworkId(ped.netId), true)
            SetBlockingOfNonTemporaryEvents(NetworkGetEntityFromNetworkId(ped.netId), true)
            if not IsPedUsingScenario(NetworkGetEntityFromNetworkId(ped.netId), ped.scenario) then
                TaskStartScenarioInPlace(NetworkGetEntityFromNetworkId(ped.netId), ped.scenario, 0, true)
            end
        end

        function point:onExit()
            if Config.interactionMethod == "textui" then
                lib.hideTextUI()
            end
        end

        if Config.interactionMethod == "textui" or Config.interactionMethod == "3dtext" then
            function point:nearby()
                if Config.interactionMethod == "3dtext" and not menuOpen then
                    DrawText3Ds(entCoords.x, entCoords.y, entCoords.z, '[E] - '..string.format(Lang('interactionPrompt'), ped.deliveryType))
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('gfg_deliveries:client:openMenu', ped)
                    end
                end
                if Config.interactionMethod == "textui" and not menuOpen then
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('gfg_deliveries:client:openMenu', ped)
                        lib.hideTextUI()
                    end
                else
                    lib.hideTextUI()
                end
            end
        end
    end
end

function toggleMenu()
    if menuOpen then
        menuOpen = false
    else
        menuOpen = true
    end
end

RegisterNetEvent('gfg_deliveries:client:openMenu')
AddEventHandler("gfg_deliveries:client:openMenu", function(ped)
    menuOpen = true
    pedType = Config.DeliveryTypes[ped.deliveryType]

    debug_print("Ped Type"..json.encode(pedType, {indent = true}), 2)

    -- sets the take job button disabled if on a job
    if onJob then
        takeJobButtonDisabled = true
        endJobButtonDisabled = false
    else
        takeJobButtonDisabled = false
        endJobButtonDisabled = true
    end

    -- Registers the menu
    lib.registerContext({
        id = 'deliveryMenu_'..ped.deliveryType,
        title = string.format(Lang('menuTitle'), ped.deliveryType),
        onExit = toggleMenu(),
        options = {
            {
                title = 'Stops',
                description = pedType.stops.maxAmount,
                icon = 'map-location-dot',
                metadata = {
                    {label = Lang('stopsDescription'), value = pedType.stops.maxAmount}
                }
            },
            {
                title = 'Boxes per Stop',
                description = pedType.boxes.maxAmount,
                icon = 'box',
                metadata = {
                    {label = Lang('boxesDescription'), value = pedType.boxes.maxAmount}
                }
            },
            {
                title = 'Vehicle',
                description = GetDisplayNameFromVehicleModel(pedType.vehicle.model),
                icon = 'truck',
                image = pedType.vehicle.image,
                metadata = {
                    {label = Lang('vehicleDescription'), value = GetDisplayNameFromVehicleModel(pedType.vehicle.model)}
                }
            },
            {
                title = Lang('takeJob'),
                description = string.format(Lang('takeJobDescription'), ped.deliveryType),
                icon = 'truck-fast',
                disabled = takeJobButtonDisabled,
                onSelect = function()
                    startJob(pedType, ped.deliveryType)
                end,
            },
            {
                title = Lang('endJob'),
                description = string.format(Lang('endJobDescription'), ped.deliveryType),
                icon = 'circle-stop',
                disabled = endJobButtonDisabled,
                metadata = {
                    {label = Lang('stopCount'), value = dropoffCount},
                    {label = Lang('boxCount'), value = boxesDropped},
                    {label = Lang('distanceCount'), value = distance},
                },
                onSelect = function()
                    endJob()
                end,
            },
        }
    }) 

    -- Opens the menu
    lib.showContext('deliveryMenu_'..ped.deliveryType)   
end)

-- Start Job Function
function startJob(pedType, deliveryType)
    -- Sets the client onJob to true
    onJob = true
    local spawnFound = false

    -- Creates the route vehicle
    for _, coords in pairs(pedType.vehicle.coords) do
        local checkCoords = vec3(coords.x, coords.y, coords.z)
        local nearbyVehicles = lib.getNearbyVehicles(checkCoords, 1, true)
        if #nearbyVehicles == 0 then
            spawnCoords = coords
            spawnFound = true
            break
        end
    end

    if not spawnFound then
        TriggerEvent('gfg_deliveries:client:notify', Lang('noSpawn'), Lang('noSpawnDescription'), 'success')
        onJob = false
        return
    end

    if lib.requestModel(pedType.vehicle.model, 1000) then
        truck = CreateVehicle(pedType.vehicle.model, spawnCoords, spawnCoords.w, true, false)
    end

    dropoffsAssigned = math.random(pedType.stops.minAmount, pedType.stops.maxAmount)
    debug_print("Dropoff Count: "..dropoffsAssigned, 1)

    -- Gives keys
    TriggerServerEvent('gfg_deliveries:server:giveKeys', GetVehicleNumberPlateText(truck))

    distance = 0
    dropoffCount = 0
    boxesDropped = 0

    -- Informs the client they ahve started a route
    TriggerEvent('gfg_deliveries:client:notify', string.format(Lang('menuTitle'), deliveryType), string.format(Lang('jobStarted'), dropoffsAssigned), 'success')

    -- Creates dropoff
    getDropoff()
end

function endJob()
    onJob = false
    TriggerServerEvent("gfg_deliveries:server:removeKeys", GetVehicleNumberPlateText(truck))
    DeleteVehicle(truck)
    TriggerServerEvent("gfg_deliveries:server:payout", distance, dropoffCount, boxesDropped, pedType)
    distance = 0
    dropoffCount = 0
    boxesDropped = 0
    if Config.interactionMethod == 'target' then
        exports.ox_target:removeZone(targetZoneMenu)
    end
    dropoffBox:remove()
    targetZone:remove()
    markerZone:remove()
    truckPoint:remove()
    RemoveBlip(dropoffBlip)
end


-- Get Dropoff Function
function getDropoff()
    randomDropoff = math.random(1, #pedType.stops.locations)
    debug_print("new Dropoff assigned", 1)

    dropoffDistance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), pedType.stops.locations[randomDropoff])

    pedType.stops.blip = pedType.stops.blip or Config.Defaults.stops.blip
    local sprite = pedType.stops.blip.sprite or Config.Defaults.stops.blip.sprite
    local scale = pedType.stops.blip.scale or Config.Defaults.stops.blip.scale
    local color = pedType.stops.blip.color or Config.Defaults.stops.blip.color

    dropoffBlip = AddBlipForCoord(pedType.stops.locations[randomDropoff])
    SetBlipSprite(dropoffBlip, sprite)
    SetBlipColour(dropoffBlip, color)
    SetBlipScale(dropoffBlip, scale)
    SetBlipHiddenOnLegend(dropoffBlip, false)
    SetBlipRoute(dropoffBlip, true)
    SetBlipDisplay(dropoffBlip, 8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(string.format(Lang('dropoffBlip'), dropoffCount))
    EndTextCommandSetBlipName(blip)

    -- Sets number of boxes for this stop
    boxCount = math.random(pedType.boxes.minAmount, pedType.boxes.maxAmount)

    TriggerEvent('gfg_deliveries:client:notify', Lang('dropoffAssigned'), '', 'inform')


    dropoffBox = lib.zones.sphere({
        coords = pedType.stops.locations[randomDropoff],
        radius = 10,
        debug = Config.enhancedDebug,
        onEnter = onDropoffEnter,
    })

    -- Creates zone for the target
    targetZone = lib.zones.sphere({
        coords = pedType.stops.targets[randomDropoff],
        radius = Config.interactionDistance,
        debug = Config.enhancedDebug,
        onEnter = targetOnEnter,
    })

    if Config.drawMarker.enable then
        markerZone = lib.zones.sphere({
            coords = pedType.stops.targets[randomDropoff],
            radius = 30,
            debug = Config.enhancedDebug,
        })
    end

    truckInteractionBone = pedType.vehicle.bone or Config.Defaults.vehicle.bone
    truckBoneIndex = GetEntityBoneIndexByName(truck, truckInteractionBone)
    truckBonePosition = GetEntityBonePosition_2(truck, truckBoneIndex)
    truckPoint = lib.points.new({
        coords = truckBonePosition,
        distance = Config.interactionDistance,
    })

    enteredDropoff = false

    function dropoffBox:onEnter()
        if not enteredDropoff then
            TriggerEvent('gfg_deliveries:client:notify', Lang('atDropoff'), string.format(Lang('atDropoffDescription'), boxCount), 'inform')
            truckInteractionBone = pedType.vehicle.bone or Config.Defaults.vehicle.bone
            truckBoneIndex = GetEntityBoneIndexByName(truck, truckInteractionBone)
            truckBonePosition = GetEntityBonePosition_2(truck, truckBoneIndex)
            RemoveBlip(dropoffBlip)
            enteredDropoff = true
        end
    end

    function dropoffBox:inside()
        if boxCount > 0 then 
            truckPoint:remove()
            truckBonePosition = GetEntityBonePosition_2(truck, truckBoneIndex)
            truckPoint = lib.points.new({
                coords = truckBonePosition,
                distance = Config.interactionDistance,
            })
        
            function truckPoint:onEnter()
                if Config.interactionMethod == "target" then
                    if not hasTruckMenu then
                        local truckOptions = {{
                            name = truck..'_target',
                            icon = 'fa-solid fa-truck-ramp-box',
                            label = Lang('grabBox'),
                            bones = {truckInteractionBone},
                            onSelect = function()
                                grabBox()
                            end 
                        }}
                        exports.ox_target:addLocalEntity(truck, truckOptions)
                        hasTruckMenu = true
                    end
                end
                if Config.interactionMethod == "textui" then
                    if not hasBox then
                        lib.showTextUI('[E] - '..Lang('grabBox'))
                    end
                end
            end
        
            function truckPoint:onExit()
                if Config.interactionMethod == "textui" then
                    lib.hideTextUI()
                end
            end
        
            if Config.interactionMethod == "textui" or Config.interactionMethod == "3dtext" then
                function truckPoint:nearby()
                    if Config.interactionMethod == "3dtext" and not hasBox and boxCount > 0 then
                        DrawText3Ds(truckBonePosition.x, truckBonePosition.y, truckBonePosition.z, '[E] - '..Lang('grabBox'))
                        if IsControlJustReleased(0, 38) then
                            grabBox()
                        end
                    end
                    if Config.interactionMethod == "textui" and not hasBox and boxCount > 0 then
                        if IsControlJustReleased(0, 38) then
                            grabBox()
                            lib.hideTextUI()
                        end
                    end
                end
            end 
        end   
    end

    function targetZone:onEnter()
        print("Entered Targert Zone")
        if Config.interactionMethod == "target" then
            if not hasTargetMenu then
                targetZoneMenu = exports.ox_target:addSphereZone({
                    coords = pedType.stops.targets[randomDropoff],
                    radius = 4,
                    debug = Config.enhancedDebug,
                    options = {
                        {
                            name = 'sphere',
                            icon = 'box',
                            label = Lang('deliverBox'),
                            onSelect = function()
                                deliverBox()
                            end
                        }
                    }
                })
                hasTargetMenu = true
            end
        end
        if Config.interactionMethod == "textui" then
            if not hasBox then
                lib.showTextUI('[E] - '..Lang('deliverBox'))
            end
        end
    end

    function targetZone:onExit()
        if Config.interactionMethod == "textui" then
            lib.hideTextUI()
        end
    end

    if Config.interactionMethod == "textui" or Config.interactionMethod == "3dtext" then
        function targetZone:inside()
            if Config.interactionMethod == "3dtext" and hasBox then
                DrawText3Ds(pedType.stops.targets[randomDropoff].x, pedType.stops.targets[randomDropoff].y, pedType.stops.targets[randomDropoff].z, '[E] - '..Lang('deliverBox'))
                if IsControlJustReleased(0, 38) then
                    deliverBox()
                end
            end
            if Config.interactionMethod == "textui" and hasBox then
                if IsControlJustReleased(0, 38) then
                    deliverBox()
                    lib.hideTextUI()
                end
            end
        end
    end

    function markerZone:inside()
        DrawMarker(Config.drawMarker.type, pedType.stops.targets[randomDropoff], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
        Config.drawMarker.scale.x, Config.drawMarker.scale.y, Config.drawMarker.scale.z, 
        Config.drawMarker.color.r, Config.drawMarker.color.g, Config.drawMarker.color.b, Config.drawMarker.color.alpha, 
        Config.drawMarker.bob, Config.drawMarker.faceCamera)
    end
end

function grabBox()
    if boxCount < 1 then
        TriggerEvent('gfg_deliveries:client:notify', Lang('allBoxesDelivered'), Lang('allBoxesDeliveredDescription'), 'inform')
        return
    end
    if hasBox then
        TriggerEvent('gfg_deliveries:client:notify', Lang('hasBox'), Lang('hasBoxDescription'), 'inform')
    else
        lib.requestAnimDict('anim@heists@box_carry@', 1000)

        TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
    
        lib.requestModel('prop_cs_cardbox_01', 1000)
    
        boxProp = CreateObject(GetHashKey('prop_cs_cardbox_01'), x, y, z, true, true, true)
        AttachEntityToEntity(boxProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x60F2), -0.1, 0.4, 0, 0, 90.0, 0, true, true, false, true, 5, true)
        hasBox = true
    end
end

function deliverBox()
    if hasBox then
        DeleteEntity(boxProp)
        ClearPedTasks(PlayerPedId())
        hasBox = false
        boxCount = boxCount - 1
        boxesDropped = boxesDropped + 1
        
        if boxCount < 1 then
            -- Stop is completed
            dropoffsAssigned = dropoffsAssigned - 1
            dropoffCount = dropoffCount + 1
            distance = distance + dropoffDistance

            debug_print("Stop #"..dropoffCount.." Completed, "..dropoffsAssigned.." more to go.", 1)

            if Config.interactionMethod == 'target' then
                exports.ox_target:removeZone(targetZoneMenu)
            end
            dropoffBox:remove()
            targetZone:remove()
            markerZone:remove()
            truckPoint:remove()

            if dropoffsAssigned == 0 then
                -- end job
                debug_print("All Stops completed", 1)
                TriggerEvent('gfg_deliveries:client:notify', Lang('stopsDone'), Lang('stopsDoneDescription'), 'inform')
                SetNewWaypoint(pedType.ped.coords.x, pedType.ped.coords.y)
            else
            -- Get New Dropoff
            hasTargetMenu = false
            getDropoff()
            TriggerEvent('gfg_deliveries:client:notify', Lang('nextDropoff'), string.format(Lang('nextDropoffDescription'), dropoffsAssigned), 'inform')
            end
        else
            TriggerEvent('gfg_deliveries:client:notify', Lang('boxDelivered'), string.format(Lang('boxDeliveredDescription'), boxCount), 'inform')
        end
    else
        TriggerEvent('gfg_deliveries:client:notify', Lang('noBox'), string.format(Lang('noBoxDescription'), boxCount), 'inform')
    end
end



























































-- Library Function [DO NOT TOUCH]
function createBlips()

    -- Creates a blip for every delivery type
    for k, v in pairs(Config.DeliveryTypes) do

        -- Sets default values if they are omitted.
        v.blip.sprite = v.blip.sprite or Config.Defaults.blip.sprite
        v.blip.scale = v.blip.scale or Config.Defaults.blip.scale
        v.blip.color = v.blip.color or Config.Defaults.blip.color

        -- Creates the blip
        local blip = AddBlipForCoord(v.ped.coords)
        SetBlipSprite(blip, v.blip.sprite)
        SetBlipScale(blip, v.blip.scale)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, v.blip.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

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