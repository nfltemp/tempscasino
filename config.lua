Config = {}

Config.AI = {
    SpawnLocation = vector4(1992.083, 3055.646, 46.215, 187.6515),
    MaxPeds = 5,
    SpawnDistance = 30.0,
    DespawnDistance = 50.0,
    SpawnInterval = 480000,
    SpawnChance = 75,
    CheckInterval = 1000,
    BarRadius = 20.0,
    Behaviors = {
        {name = "friendly", chance = 40},
        {name = "aggressive", chance = 20},
        {name = "dancer", chance = 40}
    },
    Models = {
        friendly = {
            "a_f_y_hippie_01",
            "a_m_y_hipster_01",
            "a_f_y_tourist_01",
            "a_m_y_tourist_01"
        },
        aggressive = {
            "a_m_y_mexthug_01",
            "g_m_y_lost_01",
            "g_m_y_lost_02",
            "g_m_y_lost_03"
        },
        dancers = {
            "a_f_y_hippie_01",
            "a_f_y_clubcust_01"
        }
    }
}

Config.Props = {
    {
        model = "prop_tv_flat_01",
        coords = vector4(1990.084, 3044.493, 47.581, 146.757)
    }
}

Config.Dancers = {
    {
        model = "a_f_y_hippie_01",
        coords = vector4(1989.028, 3045.406, 46.215, 323.9055),
        animation = {
            dict = "mini@strip_club@private_dance@part1",
            name = "priv_dance_p1"
        }
    },
    {
        model = "a_f_y_hippie_01",
        coords = vector4(1995.895, 3049.77, 46.215, 154.1287),
        animation = {
            dict = "mini@strip_club@private_dance@part1",
            name = "priv_dance_p1"
        }
    }
}

Config.Budtender = {
    model = "a_f_y_hippie_01",
    coords = vector4(1983.189, 3053.467, 46.215, 242.9348),
    animation = {
        dict = "amb@world_human_aa_smoke@male@idle_a",
        name = "idle_c"
    },
    prop = {
        model = "p_cs_joint_01",
        bone = 28422,
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(34.0, 13.0, 0.0)
    }
}

Config.ShopItems = {
    {
        name = "joint",
        price = 10,
        label = "Joint",
        icon = "fas fa-cannabis",
        description = "Premium quality joint for relaxation"
    },
    {
        name = "tosti",
        price = 5,
        label = "Tosti",
        icon = "fas fa-bread-slice",
        description = "Delicious grilled sandwich"
    },
    {
        name = "dry_pscioblyn",
        price = 15,
        label = "Magic Mushrooms",
        icon = "fas fa-mushroom",
        description = "Experience a magical journey"
    },
    {
        name = "xtcbaggy",
        price = 20,
        label = "XTC",
        icon = "fas fa-pills",
        description = "Party enhancer, use responsibly"
    },
    {
        name = "whiskey",
        price = 25,
        label = "Whiskey",
        icon = "fas fa-glass-whiskey",
        description = "Premium aged whiskey"
    }
}
