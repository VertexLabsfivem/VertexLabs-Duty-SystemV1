Config = {}

-- Command used in game: /duty
Config.Command = 'duty'

-- If true, only on-duty police can see other police blips.
-- If false, everyone can see on-duty police blips.
Config.BlipsOnlyVisibleToOnDuty = true

-- How often blip positions update, in milliseconds.
Config.BlipUpdateInterval = 2000

-- Draw distance for station loadout markers.
Config.StationDrawDistance = 25.0
Config.StationInteractDistance = 2.0

-- Patrol loadout given when pressing E at a station while on duty.
Config.PatrolLoadout = {
    label = 'Patrol Loadout',
    weapons = {
        {
            name = 'WEAPON_COMBATPISTOL',
            ammo = 450,
            equipNow = true
        },
        {
            name = 'WEAPON_FLASHLIGHT',
            ammo = 0,
            equipNow = false
        },
        {
            name = 'WEAPON_STUNGUN',
            ammo = 100,
            equipNow = false
        },
        
        {
            name = 'WEAPON_CARBINERIFLE',
            ammo = 1500,
            equipNow = false
        }, 
        {
            name = 'WEAPON_PUMPSHOTGUN',
            ammo = 450,
            equipNow = true
        },
    }
}

-- Station marker + map icon settings.
Config.LoadoutMarker = {
    type = 2,
    size = { x = 0.35, y = 0.35, z = 0.35 },
    color = { r = 0, g = 150, b = 255, a = 180 },
    bobUpAndDown = true,
    faceCamera = true
}

Config.LoadoutBlip = {
    enabled = true,
    label = 'Police Loadout',
    sprite = 110, -- weapon/gun style icon
    color = 3,
    scale = 0.75,
    shortRange = true
}

-- Add/edit station coords here.
Config.Stations = {
    {
        name = 'Sandy Shores Sheriff Station',
        coords = vector3(1852.45, 3689.65, 34.27),
        departments = { 'BCSO', 'SASP' }
    },
    {
        name = 'Paleto Bay Sheriff Station',
        coords = vector3(-448.18, 6012.87, 31.72),
        departments = { 'BCSO', 'SASP' }
    },
    {
        name = 'Mission Row Police Station',
        coords = vector3(452.10, -980.00, 30.69),
        departments = { 'LSPD' }
    }
}

-- Departments.
-- ace = permission node that must be allowed for the player.
-- Example server.cfg:
-- add_ace group.BCSO BCSO.dutysystem allow
Config.Departments = {
    BCSO = {
        label = 'Blaine County Sheriff Office',
        ace = 'BCSO.dutysystem',
        blip = {
            sprite = 60,
            color = 3,
            scale = 0.85,
            shortRange = false
        }
    },

    LSPD = {
        label = 'Los Santos Police Department',
        ace = 'LSPD.dutysystem',
        blip = {
            sprite = 60,
            color = 29,
            scale = 0.85,
            shortRange = false
        }
    },

    SASP = {
        label = 'San Andreas State Police',
        ace = 'SASP.dutysystem',
        blip = {
            sprite = 60,
            color = 38,
            scale = 0.85,
            shortRange = false
        }
    }
}

Config.Messages = {
    noPermission = '~r~You do not have permission to go on duty for this department.',
    invalidDepartment = '~r~Invalid department. Example: /duty BCSO',
    onDuty = '~g~You are now on duty as %s.',
    offDuty = '~y~You are now off duty.',
    usage = '~b~Usage: /duty BCSO, /duty LSPD, /duty SASP, or /duty off',
    mustBeOnDuty = '~r~You must be on duty to use the patrol loadout.',
    wrongStation = '~r~Your department cannot use this station loadout.',
    loadoutGiven = '~g~Patrol Loadout equipped: Combat Pistol.',
    pressE = '~b~Press ~INPUT_CONTEXT~ to get your Patrol Loadout'
}
