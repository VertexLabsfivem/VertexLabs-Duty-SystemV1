# VertexLabs-Duty-SystemV1 
Standalone FiveM duty system using ACE permissions.

## Features

- `/duty BCSO`, `/duty LSPD`, `/duty SASP`
- `/duty off`
- ACE permission checks
- Discord identifier examples
- On-duty police blips
- Police loadout station blips/icons
- Press `E` at a station to get Patrol Loadout
- Patrol Loadout gives Combat Pistol with ammo
- Blips can be restricted to on-duty officers only
- No ESX/QBCore required

## Install

1. Drop the `vertexlabs-duty` folder into your server resources.
2. Add this to `server.cfg`:

```cfg
ensure vertexlabs-duty
exec permissions_example.cfg
```

3. Edit `permissions_example.cfg` with your real Discord IDs.

## ACE examples

Use Discord role IDs or user IDs with `identifier.discord:`.

```cfg
add_ace group.BCSO BCSO.dutysystem allow
add_principal identifier.discord:YOUR_DISCORD_ROLE_ID group.BCSO

add_ace group.LSPD LSPD.dutysystem allow
add_principal identifier.discord:YOUR_DISCORD_ROLE_ID group.LSPD

add_ace group.SASP SASP.dutysystem allow
add_principal identifier.discord:YOUR_DISCORD_ROLE_ID group.SASP
```

If you prefer to assign permissions to a single Discord user instead of a role, use:

```cfg
add_principal identifier.discord:YOUR_DISCORD_USER_ID group.BCSO
```

## Commands

```text
/duty BCSO
/duty LSPD
/duty SASP
/duty off
```

## Patrol Loadout

Go on duty first, then go to a station marker and press `E`.

Default loadout:

```lua
WEAPON_COMBATPISTOL
120 ammo
```

Edit this in `config.lua`:

```lua
Config.PatrolLoadout = {
    label = 'Patrol Loadout',
    weapons = {
        {
            name = 'WEAPON_COMBATPISTOL',
            ammo = 120,
            equipNow = true
        }
    }
}
```

## Add/edit loadout stations

Edit `Config.Stations` in `config.lua`:

```lua
Config.Stations = {
    {
        name = 'Sandy Shores Sheriff Station',
        coords = vector3(1852.45, 3689.65, 34.27),
        departments = { 'BCSO', 'SASP' }
    }
}
```

## Add more departments

Edit `config.lua`:

```lua
Config.Departments.FBI = {
    label = 'Federal Bureau of Investigation',
    ace = 'FBI.dutysystem',
    blip = {
        sprite = 60,
        color = 40,
        scale = 0.85,
        shortRange = false
    }
}
```

Then add to permissions:

```cfg
add_ace group.FBI FBI.dutysystem allow
add_principal identifier.discord:YOURR_DISCORDROLEID_ID group.FBI
```
  
