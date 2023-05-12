-- Item Payout Function
function itemPayout(source, item, amount)
    --[[
        source = The player server ID to receive the item
        item = The item name (e.x. 'money')
        amount = the calculated amount they should receive
    ]]

     -- Place your custom inventory exports here 

end

-- Bank Payout Function
function bankPayout(source, amount)
    --[[
        source = The player server ID to receive the payout
        amount = the calculated amount they should receive
    ]]

    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney('bank', amount)
end


-- Key Functions, Only needed if you use a key system.
function giveKeys(source, plate)
    if Config.inventory == "ox_inventory" then
        exports.ox_inventory:AddItem(source, 'carkeys', 1, {plate = plate, name = "Job Vehicle"})
    end
end

function removeKeys(source, plate)
    if Config.inventory == "ox_inventory" then
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        for k, v in pairs(playerItems) do
            if v.name == 'carkeys' and tostring(v.metadata.plate):match( "^%s*(.-)%s*$" ) == plate:match( "^%s*(.-)%s*$" ) then
                local xPlayer = ESX.GetPlayerFromId(source)
                exports.ox_inventory:RemoveItem(source, 'carkeys', 1, false, v.slot)
                break
            end
        end
    end
end
