RegisterNetEvent('gfg_deliveries:client:notify')
AddEventHandler("gfg_deliveries:client:notify", function(title, description, notifType)
    lib.notify({
        title = title,
        description = description,
        type = notifType
    })
end)


-- Here you can customize the 3d text box if it is used.
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 245, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 255, 255, 245, 68)
end