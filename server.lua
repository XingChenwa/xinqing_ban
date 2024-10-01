local bannedList = {}
local bannedListUrl = 'https://raw.githubusercontent.com/XingChenwa/xinqing_ban/refs/heads/main/xinqing_ban.json'

function getIdentifierByType(identifiers, type)
    for _, v in pairs(identifiers) do
        if string.find(v, type) then
            return v
        end
    end
    return ''
end

function checkBanList(identifiers)
    for key, value in pairs(bannedList) do
        if value['license'] == getIdentifierByType(identifiers, 'license') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'license2') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'discord') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'fivem') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'steam') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'live') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'xbl') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'ip') then return true, value['reason'] end
    end

    return false, ''
end

AddEventHandler('playerConnecting', function(name, reject, deferrals)
    deferrals.defer()
    deferrals.update(string.format('联合封禁系统正在检查您是否被封禁...', name))

    local identifiers = GetPlayerIdentifiers(source)
    local isBanned, reason = checkBanList(identifiers)

    if isBanned then
        reject('联合封禁：此账户因违反规定已被本服务器或其他服务器联合永久封禁！')
        CancelEvent()
    else
        deferrals.done()
    end
end)

CreateThread(function()
    PerformHttpRequest(bannedListUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            bannedList = json.decode(response)
            print('FIVEM 联BAN系统：已加载到' .. tostring(#bannedList) .. '条封禁数据，并将会持续监听最新数据')
        else
            print('FIVEM 联BAN系统：获取联BAN数据失败！请确保您的服务器能正常访问GitHub' .. statusCode)
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })

    while true do
        PerformHttpRequest(bannedListUrl, function(statusCode, response, headers)
            if statusCode == 200 then
                bannedList = json.decode(response)
            end
        end, "GET", "", { ["Content-Type"] = "application/json" })

        Wait(1000 * 60 * 10)
    end
end)
