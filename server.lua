local OnDuty = {}

local function getPlayerNameSafe(src)
    local name = GetPlayerName(src)
    if not name or name == '' then
        name = ('Player %s'):format(src)
    end
    return name
end

local function hasDepartmentPermission(src, dept)
    local department = Config.Departments[dept]
    if not department then return false end

    -- Uses FiveM ACE permissions.
    -- server.cfg example:
    -- add_ace group.BCSO BCSO.dutysystem allow
    return IsPlayerAceAllowed(src, department.ace)
end

local function stationAllowsDepartment(station, department)
    if not station or not station.departments then return false end

    for _, allowedDepartment in ipairs(station.departments) do
        if allowedDepartment == department then
            return true
        end
    end

    return false
end

local function buildDutyDataForTarget(target)
    local data = {}

    for src, duty in pairs(OnDuty) do
        local ped = GetPlayerPed(src)
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)
            local department = Config.Departments[duty.department]

            if department then
                data[#data + 1] = {
                    serverId = src,
                    name = duty.name,
                    department = duty.department,
                    departmentLabel = department.label,
                    coords = {
                        x = coords.x,
                        y = coords.y,
                        z = coords.z
                    },
                    blip = department.blip
                }
            end
        end
    end

    return data
end

local function canReceiveBlips(src)
    if not Config.BlipsOnlyVisibleToOnDuty then
        return true
    end

    return OnDuty[src] ~= nil
end

local function syncBlips()
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if canReceiveBlips(src) then
            TriggerClientEvent('vertexlabs-duty:client:updateBlips', src, buildDutyDataForTarget(src))
        else
            TriggerClientEvent('vertexlabs-duty:client:updateBlips', src, {})
        end
    end
end

RegisterCommand(Config.Command, function(source, args)
    local src = source
    local input = args[1]

    if src == 0 then
        print('This command must be used in game.')
        return
    end

    if not input then
        TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.usage)
        return
    end

    input = string.upper(input)

    if input == 'OFF' then
        if OnDuty[src] then
            OnDuty[src] = nil
            TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.offDuty)
            syncBlips()
        else
            TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.offDuty)
        end
        return
    end

    if not Config.Departments[input] then
        TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.invalidDepartment)
        return
    end

    if not hasDepartmentPermission(src, input) then
        TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.noPermission)
        return
    end

    OnDuty[src] = {
        department = input,
        name = getPlayerNameSafe(src),
        since = os.time()
    }

    TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.onDuty:format(Config.Departments[input].label))
    syncBlips()
end, false)

RegisterNetEvent('vertexlabs-duty:server:requestPatrolLoadout', function(stationIndex)
    local src = source
    local duty = OnDuty[src]

    if not duty then
        TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.mustBeOnDuty)
        return
    end

    local station = Config.Stations[stationIndex]
    if not station or not stationAllowsDepartment(station, duty.department) then
        TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.wrongStation)
        return
    end

    if not hasDepartmentPermission(src, duty.department) then
        TriggerClientEvent('vertexlabs-duty:client:notify', src, Config.Messages.noPermission)
        return
    end

    TriggerClientEvent('vertexlabs-duty:client:givePatrolLoadout', src, Config.PatrolLoadout)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if OnDuty[src] then
        OnDuty[src] = nil
        syncBlips()
    end
end)

CreateThread(function()
    while true do
        Wait(Config.BlipUpdateInterval)
        syncBlips()
    end
end)

exports('IsOnDuty', function(src)
    return OnDuty[src] ~= nil
end)

exports('GetDutyDepartment', function(src)
    return OnDuty[src] and OnDuty[src].department or nil
end)
