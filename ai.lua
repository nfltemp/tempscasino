local QBCore = exports['qb-core']:GetCoreObject()

-- Animation sets
local Animations = {
    friendly = {
        {dict = "anim@amb@casino@hangout@ped_male@stand@02b@idles", anim = "idle_a"},
        {dict = "anim@amb@casino@valet_scenario@pose_d@", anim = "base_a_m_y_vinewood_01"},
        {dict = "anim@amb@casino@hangout@ped_female@stand@02a@idles", anim = "idle_a"}
    },
    dancing = {
        {dict = "anim@amb@nightclub@dancers@crowddance_facedj@hi_intensity", anim = "hi_dance_facedj_09_v2_female^6"},
        {dict = "anim@amb@nightclub@dancers@crowddance_groups@hi_intensity", anim = "hi_dance_crowd_09_v1_female^6"}
    }
}

-- Helper functions
local function loadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(1)
    end
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

-- Get random behavior based on probabilities
local function getRandomBehavior()
    local total = 0
    local rand = math.random(100)
    for _, behavior in ipairs(Config.AI.Behaviors) do
        total = total + behavior.chance
        if rand <= total then
            return behavior.name
        end
    end
    return "friendly"
end

-- AI behavior functions
local function friendlyBehavior(ped)
    CreateThread(function()
        while DoesEntityExist(ped) do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Set movement capabilities
            SetPedPathCanUseClimbovers(ped, true)
            SetPedPathCanUseLadders(ped, true)
            SetPedPathAvoidFire(ped, false)
            SetPedPathPreferToAvoidWater(ped, false)
            
            -- Set ped attributes
            SetPedCombatAttributes(ped, 17, true) -- BF_CanFightArmedPedsWhenNotArmed
            SetPedFleeAttributes(ped, 0, false) -- Prevent fleeing
            
            -- Clear any existing tasks first
            ClearPedTasks(ped)
            
            -- Set movement style
            RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
            while not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK") do
                Wait(1)
            end
            SetPedMovementClipset(ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", 0.5)
            
            -- Make them move towards player
            TaskGoToEntity(ped, playerPed, -1, 1.0, 2.0, 1073741824, 0)
            
            -- Add some random variations
            if math.random(100) < 30 then
                -- Sometimes play a random animation
                local anim = Animations.friendly[math.random(#Animations.friendly)]
                loadAnimDict(anim.dict)
                TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                Wait(3000) -- Wait for animation to play
            end
            
            Wait(5000) -- Update target position every 5 seconds
        end
    end)
end

local function aggressiveBehavior(ped)
    CreateThread(function()
        while DoesEntityExist(ped) do
            local playerPed = PlayerPedId()
            
            -- Set movement capabilities
            SetPedPathCanUseClimbovers(ped, true)
            SetPedPathCanUseLadders(ped, true)
            SetPedPathAvoidFire(ped, false)
            SetPedPathPreferToAvoidWater(ped, false)
            
            -- Set combat attributes
            SetPedCombatAttributes(ped, 46, true)
            SetPedCombatAttributes(ped, 0, true)
            SetPedFleeAttributes(ped, 0, false)
            
            if math.random(100) < 30 then
                -- Become hostile
                GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, true)
                TaskCombatPed(ped, playerPed, 0, 16)
                SetPedKeepTask(ped, true)
                break
            else
                -- Intimidating behavior
                local playerCoords = GetEntityCoords(playerPed)
                TaskGoToEntity(ped, playerPed, -1, 1.0, 2.0, 1073741824, 0)
            end
            
            Wait(math.random(5000, 10000))
        end
    end)
end

local function dancerBehavior(ped)
    CreateThread(function()
        while DoesEntityExist(ped) do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Set movement capabilities
            SetPedPathCanUseClimbovers(ped, true)
            SetPedPathCanUseLadders(ped, true)
            SetPedPathAvoidFire(ped, false)
            SetPedPathPreferToAvoidWater(ped, false)
            
            -- Set ped attributes
            SetPedCombatAttributes(ped, 17, true)
            SetPedFleeAttributes(ped, 0, false)
            
            -- Clear any existing tasks
            ClearPedTasks(ped)
            
            if math.random(100) < 50 then
                -- Dance
                local anim = Animations.dancing[math.random(#Animations.dancing)]
                loadAnimDict(anim.dict)
                TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                Wait(math.random(10000, 15000))
            else
                -- Move towards player
                TaskGoToEntity(ped, playerPed, -1, 1.0, 2.0, 1073741824, 0)
                Wait(5000)
            end
        end
    end)
end

-- Main spawn function
local function spawnRandomPed()
    local behavior = getRandomBehavior()
    local modelList = Config.AI.Models[behavior] or Config.AI.Models.friendly
    local model = modelList[math.random(#modelList)]
    
    loadModel(model)
    
    local offset = vector3(
        math.random(-2, 2),
        math.random(-2, 2),
        0
    )
    
    local groundZ = 0
    local ground, z = GetGroundZFor_3dCoord(
        Config.AI.SpawnLocation.x + offset.x,
        Config.AI.SpawnLocation.y + offset.y,
        Config.AI.SpawnLocation.z,
        false
    )
    if ground then
        groundZ = z
    else
        groundZ = Config.AI.SpawnLocation.z
    end
    
    local ped = CreatePed(4, GetHashKey(model), 
        Config.AI.SpawnLocation.x + offset.x,
        Config.AI.SpawnLocation.y + offset.y,
        groundZ,
        Config.AI.SpawnLocation.w,
        true, false)
    
    if not DoesEntityExist(ped) then return nil end
    
    SetPedRandomComponentVariation(ped, 0)
    SetPedRandomProps(ped)
    
    if behavior == "friendly" then
        friendlyBehavior(ped)
    elseif behavior == "aggressive" then
        aggressiveBehavior(ped)
    elseif behavior == "dancer" then
        dancerBehavior(ped)
    end
    
    return ped
end

-- Bar area check
local barArea = {
    center = vector3(1992.083, 3055.646, 46.215),
    radius = 20.0
}

local function isPlayerInBar()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - barArea.center)
    return distance <= barArea.radius
end

-- Main thread for AI spawning
CreateThread(function()
    while true do
        if isPlayerInBar() then
            if math.random(100) <= Config.AI.SpawnChance then
                local peds = GetGamePool('CPed')
                local aiPedCount = 0
                
                for _, ped in ipairs(peds) do
                    if not IsPedAPlayer(ped) and GetPedType(ped) ~= 28 then
                        aiPedCount = aiPedCount + 1
                    end
                end
                
                if aiPedCount < Config.AI.MaxPeds then
                    spawnRandomPed()
                end
            end
            Wait(Config.AI.SpawnInterval)
        else
            local peds = GetGamePool('CPed')
            for _, ped in ipairs(peds) do
                if not IsPedAPlayer(ped) and GetPedType(ped) ~= 28 then
                    DeleteEntity(ped)
                end
            end
            Wait(5000)
        end
    end
end)

-- Initial spawn thread
CreateThread(function()
    Wait(5000)
    
    if isPlayerInBar() then
        for i = 1, math.random(1, Config.AI.MaxPeds) do
            if math.random(100) <= Config.AI.SpawnChance then
                spawnRandomPed()
                Wait(1000)
            end
        end
    end
end)