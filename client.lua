local ActiveBlips = {}
local StationBlips = {}

local function notify(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

local function drawHelpText(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

RegisterNetEvent('vertexlabs-duty:client:notify', function(msg)
    notify(msg)
end)

local function removeBlips()
    for _, blip in pairs(ActiveBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    ActiveBlips = {}

    for _, blip in pairs(StationBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    StationBlips = {}
end

local function createStationBlips()
    if not Config.LoadoutBlip.enabled then return end

    for index, station in ipairs(Config.Stations) do
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, Config.LoadoutBlip.sprite or 110)
        SetBlipColour(blip, Config.LoadoutBlip.color or 3)
        SetBlipScale(blip, Config.LoadoutBlip.scale or 0.75)
        SetBlipAsShortRange(blip, Config.LoadoutBlip.shortRange ~= false)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.LoadoutBlip.label or 'Police Loadout')
        EndTextCommandSetBlipName(blip)

        StationBlips[index] = blip
    end
end

local function createOrUpdateBlip(unit)
    local key = tostring(unit.serverId)

    if not ActiveBlips[key] or not DoesBlipExist(ActiveBlips[key]) then
        ActiveBlips[key] = AddBlipForCoord(unit.coords.x, unit.coords.y, unit.coords.z)
    else
        SetBlipCoords(ActiveBlips[key], unit.coords.x, unit.coords.y, unit.coords.z)
    end

    local blip = ActiveBlips[key]
    local cfg = unit.blip or {}

    SetBlipSprite(blip, cfg.sprite or 60)
    SetBlipColour(blip, cfg.color or 3)
    SetBlipScale(blip, cfg.scale or 0.85)
    SetBlipAsShortRange(blip, cfg.shortRange or false)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('[%s] %s'):format(unit.department, unit.name))
    EndTextCommandSetBlipName(blip)
end

RegisterNetEvent('vertexlabs-duty:client:updateBlips', function(units)
    local keep = {}

    for _, unit in ipairs(units) do
        local key = tostring(unit.serverId)
        keep[key] = true
        createOrUpdateBlip(unit)
    end

    for key, blip in pairs(ActiveBlips) do
        if not keep[key] then
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
            ActiveBlips[key] = nil
        end
    end
end)

RegisterNetEvent('vertexlabs-duty:client:givePatrolLoadout', function(loadout)
    local ped = PlayerPedId()

    for _, weapon in ipairs(loadout.weapons or {}) do
        GiveWeaponToPed(ped, joaat(weapon.name), weapon.ammo or 0, false, weapon.equipNow or false)
    end

    notify(Config.Messages.loadoutGiven)
end)

CreateThread(function()
    createStationBlips()

    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        for index, station in ipairs(Config.Stations) do
            local distance = #(playerCoords - station.coords)

            if distance <= Config.StationDrawDistance then
                sleep = 0
                local marker = Config.LoadoutMarker

                DrawMarker(
                    marker.type or 2,
                    station.coords.x, station.coords.y, station.coords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    marker.size.x, marker.size.y, marker.size.z,
                    marker.color.r, marker.color.g, marker.color.b, marker.color.a,
                    marker.bobUpAndDown or false,
                    marker.faceCamera or false,
                    2,
                    false,
                    nil,
                    nil,
                    false
                )

                if distance <= Config.StationInteractDistance then
                    drawHelpText(Config.Messages.pressE)

                    if IsControlJustReleased(0, 38) then -- E / INPUT_CONTEXT
                        TriggerServerEvent('vertexlabs-duty:server:requestPatrolLoadout', index)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        removeBlips()
    end
end)
