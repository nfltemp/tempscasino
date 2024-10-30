local QBCore = exports['qb-core']:GetCoreObject()

if not lib then
    lib = exports['ox_lib']:GetLib()
end

local gameState = {
    deck = {},
    playerHand = {},
    dealerHand = {},
    currentBet = 0,
    isPlaying = false
}

local function createDeck()
    local deck = {}
    local suits = {
        hearts = {
            symbol = "♥️",
            cards = {
                A = "🂱", 
                ["2"] = "🂲",
                ["3"] = "🂳",
                ["4"] = "🂴",
                ["5"] = "🂵",
                ["6"] = "🂶",
                ["7"] = "🂷",
                ["8"] = "🂸",
                ["9"] = "🂹",
                ["10"] = "🂺",
                J = "🂻", 
                Q = "🂽", 
                K = "🂾"  
            }
        },
        diamonds = {
            symbol = "♦️",
            cards = {
                A = "🃁",
                ["2"] = "🃂",
                ["3"] = "🃃",
                ["4"] = "🃄",
                ["5"] = "🃅",
                ["6"] = "🃆",
                ["7"] = "🃇",
                ["8"] = "🃈",
                ["9"] = "🃉",
                ["10"] = "🃊",
                J = "🃋",
                Q = "🃍",
                K = "🃎"
            }
        },
        clubs = {
            symbol = "♣️",
            cards = {
                A = "🃑",
                ["2"] = "🃒",
                ["3"] = "🃓",
                ["4"] = "🃔",
                ["5"] = "🃕",
                ["6"] = "🃖",
                ["7"] = "🃗",
                ["8"] = "🃘",
                ["9"] = "🃙",
                ["10"] = "🃚",
                J = "🃛",
                Q = "🃝",
                K = "🃞"
            }
        },
        spades = {
            symbol = "♠️",
            cards = {
                A = "🂡",
                ["2"] = "🂢",
                ["3"] = "🂣",
                ["4"] = "🂤",
                ["5"] = "🂥",
                ["6"] = "🂦",
                ["7"] = "🂧",
                ["8"] = "🂨",
                ["9"] = "🂩",
                ["10"] = "🂪",
                J = "🂫",
                Q = "🂭",
                K = "🂮"
            }
        }
    }
    local values = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    
    for suitName, suitData in pairs(suits) do
        for _, value in ipairs(values) do
            table.insert(deck, {
                value = value,
                suit = suitData.symbol,
                display = suitData.cards[value]
            })
        end
    end
    
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    
    return deck
end

local function calculateHandValue(hand)
    local value = 0
    local aces = 0
    
    for _, card in ipairs(hand) do
        if card.value == "A" then
            aces = aces + 1
            value = value + 11
        elseif card.value == "K" or card.value == "Q" or card.value == "J" then
            value = value + 10
        else
            value = value + tonumber(card.value)
        end
    end
    
    while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
    end
    
    return value
end

local function formatHand(hand, hideSecond)
    local formatted = {}
    for i, card in ipairs(hand) do
        if hideSecond and i == 2 then
            table.insert(formatted, "🂠")  -- Card back
        else
            table.insert(formatted, card.display)  -- Use the specific card emoji
        end
    end
    return table.concat(formatted, " ")
end

local showBettingMenu
local showRulesMenu
local dealerPlay
local showGameMenu
local startBlackjackGame

showBettingMenu = function()
    lib.registerContext({
        id = 'blackjack_betting',
        title = '🎰 Welcome to Blackjack',
        options = {
            {
                title = '💵 Small Bet ($50)',
                description = 'Place a modest bet of $50',
                icon = 'fas fa-dollar-sign',
                metadata = {
                    {label = 'Minimum Bet', value = '$50'},
                    {label = 'Maximum Win', value = '$100'}
                },
                onSelect = function()
                    print("Selected $50 bet") -- Debug print
                    startBlackjackGame(50)
                end
            },
            {
                title = '💰 Medium Bet ($100)',
                description = 'Place a medium bet of $100',
                icon = 'fas fa-coins',
                metadata = {
                    {label = 'Minimum Bet', value = '$100'},
                    {label = 'Maximum Win', value = '$200'}
                },
                onSelect = function()
                    startBlackjackGame(100)
                end
            },
            {
                title = '💎 High Roller ($500)',
                description = 'Place a high bet of $500',
                icon = 'fas fa-gem',
                metadata = {
                    {label = 'Minimum Bet', value = '$500'},
                    {label = 'Maximum Win', value = '$1000'}
                },
                onSelect = function()
                    startBlackjackGame(500)
                end
            },
            {
                title = '🎲 Custom Bet',
                description = 'Enter your own bet amount',
                icon = 'fas fa-dice',
                onSelect = function()
                    local input = lib.inputDialog('Custom Bet', {
                        {
                            type = 'number',
                            label = 'Bet Amount',
                            description = 'Enter bet amount (Minimum: $50)',
                            icon = 'fas fa-dollar-sign',
                            required = true,
                            min = 50,
                            -- Removed the max = 1000 line to allow unlimited betting
                        }
                    })
                    
                    if input then
                        local amount = tonumber(input[1])
                        if amount then
                            startBlackjackGame(amount)
                        end
                    end
                end
            },
            {
                title = '❓ How to Play',
                description = 'View game rules and payouts',
                icon = 'fas fa-question-circle',
                onSelect = function()
                    showRulesMenu()
                end
            }
        }
    })
    lib.showContext('blackjack_betting')
end

showRulesMenu = function()
    lib.registerContext({
        id = 'blackjack_rules',
        title = '📋 Blackjack Rules',
        menu = 'blackjack_betting',
        options = {
            {
                title = '🎯 Objective',
                description = 'Beat the dealer\'s hand without going over 21',
                metadata = {
                    {label = 'Blackjack Pays', value = '3:2'},
                    {label = 'Regular Win', value = '1:1'},
                    {label = 'Insurance', value = '2:1'}
                }
            },
            {
                title = '🃏 Card Values',
                description = 'A (1 or 11), Face Cards (10), Others (Face Value)',
            },
            {
                title = '🎮 Game Actions',
                description = 'Hit, Stand, Double Down, Split',
            },
            {
                title = '🔙 Back to Betting',
                description = 'Return to betting menu',
                onSelect = function()
                    showBettingMenu()
                end
            }
        }
    })
    lib.showContext('blackjack_rules')
end

dealerPlay = function()
    while calculateHandValue(gameState.dealerHand) < 17 do
        table.insert(gameState.dealerHand, table.remove(gameState.deck))
        Wait(500)
    end
    
    local playerValue = calculateHandValue(gameState.playerHand)
    local dealerValue = calculateHandValue(gameState.dealerHand)
    
    local outcomeTitle = ""
    local outcomeMessage = ""
    local handComparison = string.format([[
Your Hand (%d):    %s
Dealer's Hand (%d):    %s]], 
        playerValue, 
        formatHand(gameState.playerHand, false),
        dealerValue, 
        formatHand(gameState.dealerHand, false)
    )
    
    if playerValue > 21 then
        outcomeTitle = "🔴 Bust! You Lost!"
        outcomeMessage = string.format("You went over 21 and lost $%d\n\n%s", 
            gameState.currentBet, handComparison)
        TriggerServerEvent('blackjack:loseBet', gameState.currentBet)
    elseif dealerValue > 21 then
        outcomeTitle = "🟢 Dealer Bust! You Won!"
        outcomeMessage = string.format("Dealer went over 21! You won $%d\n\n%s", 
            gameState.currentBet * 2, handComparison)
        TriggerServerEvent('blackjack:winBet', gameState.currentBet)
    elseif playerValue > dealerValue then
        outcomeTitle = "🟢 You Won!"
        outcomeMessage = string.format("You beat the dealer! Won $%d\n\n%s", 
            gameState.currentBet * 2, handComparison)
        TriggerServerEvent('blackjack:winBet', gameState.currentBet)
    elseif dealerValue > playerValue then
        outcomeTitle = "🔴 Dealer Wins!"
        outcomeMessage = string.format("Dealer wins with %d vs your %d! You lost $%d\n\n%s", 
            dealerValue, playerValue, gameState.currentBet, handComparison)
        TriggerServerEvent('blackjack:loseBet', gameState.currentBet)
    else
        outcomeTitle = "🟡 Push! It's a Tie!"
        outcomeMessage = string.format("It's a tie! Your bet of $%d has been returned\n\n%s", 
            gameState.currentBet, handComparison)
        TriggerServerEvent('blackjack:tieBet', gameState.currentBet)
    end

    lib.registerContext({
        id = 'blackjack_results',
        title = outcomeTitle,
        description = outcomeMessage,
        options = {
            {
                title = '📊 Match Results',
                description = string.format([[
Dealer's Hand: %s (%d)
Your Hand: %s (%d)
%s]], 
                    formatHand(gameState.dealerHand, false), dealerValue,
                    formatHand(gameState.playerHand, false), playerValue,
                    dealerValue > playerValue and playerValue <= 21 
                        and string.format("💸 You lost $%d", gameState.currentBet)
                        or dealerValue < playerValue and playerValue <= 21 
                        and string.format("💰 You won $%d", gameState.currentBet * 2)
                        or dealerValue == playerValue and "🤝 Push - Bet Returned"
                        or playerValue > 21 and string.format("💸 Bust - Lost $%d", gameState.currentBet)
                ),
                icon = 'fas fa-chart-bar'
            },
            {
                title = '🎲 Play Again',
                description = 'Start a new game',
                onSelect = function()
                    gameState.isPlaying = false
                    showBettingMenu()
                end
            },
            {
                title = '🚶‍♂️ Leave Table',
                description = 'Exit the game',
                onSelect = function()
                    gameState.isPlaying = false
                end
            }
        }
    })

    lib.showContext('blackjack_results')
end

showGameMenu = function()
    local playerValue = calculateHandValue(gameState.playerHand)
    local dealerValue = calculateHandValue({gameState.dealerHand[1]})
    
    lib.registerContext({
        id = 'blackjack_game',
        title = '🎰 Blackjack Table',
        options = {
            {
                title = '🃏 Game Cards',
                description = string.format([[
Dealer:
• %d    %s    %s

Your Hand:
• %d    %s]], 
                    dealerValue,
                    gameState.dealerHand[1].display,
                    "🂠",
                    playerValue,
                    formatHand(gameState.playerHand, false)
                ),
                metadata = {
                    {label = 'Dealer\'s Visible Card', value = string.format('%s (Value: %d)', gameState.dealerHand[1].display, dealerValue)},
                    {label = 'Dealer\'s Hidden Card', value = '🂠 (Hidden)'},
                    {label = 'Your Cards', value = formatHand(gameState.playerHand, false)},
                    {label = 'Your Hand Value', value = string.format('%d', playerValue)},
                    {label = 'Current Bet', value = string.format('$%d', gameState.currentBet)},
                    {label = 'Game Status', value = playerValue > 21 and '🔴 Bust!' or playerValue == 21 and '🟡 Blackjack!' or '🟢 In Play'}
                }
            },
            {
                title = '👆 Hit',
                description = 'Draw another card',
                onSelect = function()
                    table.insert(gameState.playerHand, table.remove(gameState.deck))
                    local newValue = calculateHandValue(gameState.playerHand)
                    
                    if newValue > 21 then
                        QBCore.Functions.Notify('💥 Bust! You went over 21!', 'error')
                        dealerPlay()
                    else
                        showGameMenu()
                    end
                end
            },
            {
                title = '✋ Stand',
                description = 'Keep your current hand',
                onSelect = function()
                    dealerPlay()
                end
            },
            {
                title = '💰 Double Down',
                description = 'Double bet and take one card',
                disabled = playerValue > 11,
                onSelect = function()
                    QBCore.Functions.TriggerCallback('blackjack:checkMoney', function(hasEnough)
                        if hasEnough then
                            gameState.currentBet = gameState.currentBet * 2
                            table.insert(gameState.playerHand, table.remove(gameState.deck))
                            dealerPlay()
                        else
                            QBCore.Functions.Notify('Not enough money to double down!', 'error')
                            showGameMenu()
                        end
                    end, gameState.currentBet)
                end
            }
        }
    })

    lib.showContext('blackjack_game')
end

startBlackjackGame = function(bet)
    print("Starting blackjack game with bet: " .. tostring(bet)) -- Debug print
    
    QBCore.Functions.TriggerCallback('blackjack:checkMoney', function(hasEnough)
        print("Money check result: " .. tostring(hasEnough)) -- Debug print
        
        if hasEnough then
            -- Initialize game state
            gameState.deck = createDeck()
            gameState.playerHand = {}
            gameState.dealerHand = {}
            gameState.currentBet = bet
            gameState.isPlaying = true
            
            -- Deal initial cards
            table.insert(gameState.playerHand, table.remove(gameState.deck))
            table.insert(gameState.dealerHand, table.remove(gameState.deck))
            table.insert(gameState.playerHand, table.remove(gameState.deck))
            table.insert(gameState.dealerHand, table.remove(gameState.deck))
            
            print("Initial cards dealt, showing game menu") -- Debug print
            showGameMenu()
        else
            QBCore.Functions.Notify('Not enough money to place bet!', 'error')
        end
    end, bet)
end

CreateThread(function()
    local pedModel = GetHashKey("A_M_Y_SmartCasPat_01")
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end
    
    local blackjackPed = CreatePed(4, pedModel, 1993.972, 3050.766, 46.215, 145.177, false, true)
    FreezeEntityPosition(blackjackPed, true)
    SetEntityInvincible(blackjackPed, true)
    SetBlockingOfNonTemporaryEvents(blackjackPed, true)
    

    local blip = AddBlipForCoord(1993.972, 3050.766, 46.215)
    SetBlipSprite(blip, 679)  
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 50)  
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Temp's Casino & Bar")
    EndTextCommandSetBlipName(blip)
    
    exports.ox_target:addLocalEntity(blackjackPed, {
        {
            name = 'play_blackjack',
            icon = 'fas fa-play',
            label = 'Play Blackjack',
            onSelect = function()
                if not gameState.isPlaying then
                    showBettingMenu()
                else
                    QBCore.Functions.Notify('Game already in progress!', 'error')
                end
            end
        }
    })
end)
