local QBCore = exports['qb-core']:GetCoreObject()

-- Helper function to load animation dictionary
local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(5)
    end
end

-- Helper function to load model
local function loadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(5)
    end
end

-- Create Dancers
CreateThread(function()
    Wait(1000) -- Wait a bit to ensure everything is loaded
    for _, dancer in ipairs(Config.Dancers) do
        loadModel(dancer.model)
        
        -- Get ground Z coordinate
        local groundZ = 0
        local ground, z = GetGroundZFor_3dCoord(dancer.coords.x, dancer.coords.y, dancer.coords.z, false)
        if ground then
            groundZ = z
        else
            groundZ = dancer.coords.z
        end
        
        local ped = CreatePed(4, GetHashKey(dancer.model), 
            dancer.coords.x, 
            dancer.coords.y, 
            groundZ, 
            dancer.coords.w, 
            false, true)
            
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        loadAnimDict(dancer.animation.dict)
        TaskPlayAnim(ped, dancer.animation.dict, dancer.animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end)

-- Create Budtender with Joint
CreateThread(function()
    Wait(1000) -- Wait a bit to ensure everything is loaded
    loadModel(Config.Budtender.model)
    
    -- Get ground Z coordinate
    local groundZ = 0
    local ground, z = GetGroundZFor_3dCoord(Config.Budtender.coords.x, Config.Budtender.coords.y, Config.Budtender.coords.z, false)
    if ground then
        groundZ = z
    else
        groundZ = Config.Budtender.coords.z
    end
    
    local budtender = CreatePed(4, GetHashKey(Config.Budtender.model), 
        Config.Budtender.coords.x, 
        Config.Budtender.coords.y, 
        groundZ, 
        Config.Budtender.coords.w, 
        false, true)
    
    FreezeEntityPosition(budtender, true)
    SetEntityInvincible(budtender, true)
    SetBlockingOfNonTemporaryEvents(budtender, true)

    -- Load and play smoking animation
    loadAnimDict(Config.Budtender.animation.dict)
    TaskPlayAnim(budtender, 
        Config.Budtender.animation.dict, 
        Config.Budtender.animation.name, 
        8.0, -8.0, -1, 1, 0, false, false, false)

    -- Attach joint prop
    local jointProp = CreateObject(GetHashKey(Config.Budtender.prop.model), 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(jointProp, budtender, 
        GetPedBoneIndex(budtender, Config.Budtender.prop.bone), 
        Config.Budtender.prop.offset.x, Config.Budtender.prop.offset.y, Config.Budtender.prop.offset.z,
        Config.Budtender.prop.rotation.x, Config.Budtender.prop.rotation.y, Config.Budtender.prop.rotation.z,
        false, false, false, false, 2, true)

    -- Add shop interaction
    exports.ox_target:addLocalEntity(budtender, {
        {
            name = 'casino_shop',
            icon = 'fas fa-shopping-cart',
            label = 'Open Shop',
            onSelect = function()
                OpenShopMenu()
            end
        }
    })
end)

-- Create Props
CreateThread(function()
    for _, prop in ipairs(Config.Props) do
        local propObject = CreateObject(GetHashKey(prop.model), 
            prop.coords.x, 
            prop.coords.y, 
            prop.coords.z, 
            true, false, false)
        
        SetEntityHeading(propObject, prop.coords.w)
        FreezeEntityPosition(propObject, true)
    end
end)

-- Shop Menu with enhanced UI
function OpenShopMenu()
    local options = {}
    
    for _, item in ipairs(Config.ShopItems) do
        table.insert(options, {
            title = string.format('🏷️ %s', item.label),
            description = item.description,
            icon = item.icon,
            iconColor = GetItemColor(item.name),
            metadata = {
                {label = '💰 Price', value = string.format('$%d', item.price)},
                {label = '📦 Item', value = item.name},
                {label = '📝 Description', value = item.description}
            },
            onSelect = function()
                PurchaseConfirmation(item)
            end
        })
    end

    lib.registerContext({
        id = 'casino_shop_menu',
        title = '🎰 Temp\'s Casino Shop',
        options = options,
        menu = 'casino_main_menu'
    })

    lib.showContext('casino_shop_menu')
end

-- Helper function to get color based on item type
function GetItemColor(itemName)
    local colors = {
        joint = '#00FF00',         -- Green for cannabis
        tosti = '#FFA500',         -- Orange for food
        dry_pscioblyn = '#9370DB', -- Purple for mushrooms
        xtcbaggy = '#FF69B4',      -- Pink for pills
        whiskey = '#8B4513'        -- Brown for whiskey
    }
    return colors[itemName] or '#FFFFFF'
end

-- Purchase confirmation dialog
function PurchaseConfirmation(item)
    lib.registerContext({
        id = 'purchase_confirmation',
        title = '🛒 Confirm Purchase',
        menu = 'casino_shop_menu',
        options = {
            {
                title = string.format('Buy %s', item.label),
                description = string.format('Confirm purchase for $%d?', item.price),
                icon = item.icon,
                iconColor = GetItemColor(item.name),
                metadata = {
                    {label = '💰 Price', value = string.format('$%d', item.price)},
                    {label = '📝 Description', value = item.description}
                },
                onSelect = function()
                    BuyItem(item)
                end
            },
            {
                title = '↩️ Back to Shop',
                description = 'Return to shop menu',
                icon = 'fas fa-arrow-left',
                onSelect = function()
                    OpenShopMenu()
                end
            }
        }
    })

    lib.showContext('purchase_confirmation')
end

-- Buy Item Function
function BuyItem(item)
    QBCore.Functions.TriggerCallback('casino:server:checkMoney', function(hasMoney)
        if hasMoney then
            TriggerServerEvent('casino:server:buyItem', item.name, item.price)
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
        end
    end, item.price)
end 