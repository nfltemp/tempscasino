local QBCore = exports['qb-core']:GetCoreObject()



QBCore.Functions.CreateCallback('blackjack:checkMoney', function(source, cb, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    print("Checking money for player: " .. source .. ", amount: " .. amount) -- Debug print
    
    if Player.PlayerData.money.cash >= amount then
        Player.Functions.RemoveMoney('cash', amount, "blackjack-bet")
        print("Player has enough money, removing: " .. amount) -- Debug print
        cb(true)
    else
        print("Player does not have enough money") -- Debug print
        cb(false)
    end
end)


RegisterNetEvent('blackjack:winBet')
AddEventHandler('blackjack:winBet', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local winAmount = amount * 2
        Player.Functions.AddMoney('cash', winAmount, "blackjack-win")
    end
end)

RegisterNetEvent('blackjack:loseBet')
AddEventHandler('blackjack:loseBet', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    -- Money was already removed when betting
end)

RegisterNetEvent('blackjack:tieBet')
AddEventHandler('blackjack:tieBet', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddMoney('cash', amount, "blackjack-tie")
    end
end)



QBCore.Functions.CreateCallback('casino:server:checkMoney', function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.cash >= price then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('casino:server:buyItem', function(itemName, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.money.cash >= price then
        if Player.Functions.AddItem(itemName, 1) then
            Player.Functions.RemoveMoney('cash', price, "casino-shop-purchase")
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add')
            TriggerClientEvent('QBCore:Notify', src, 'Purchase successful!', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Cannot carry more of this item!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash!', 'error')
    end
end)
