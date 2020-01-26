import('System')
local function cqSetGroupBanSpeak(g,q,t)
    local time = TimeSpan(10000*t)
    CQApi:SetGroupMemberBanSpeak(g,q,time)
end

local function banPlay(msg,qq,g)
    if LuaEnvName == "private" then
        return "私聊抽你[CQ:emoji,id=128052]的奖呢"
    end
    local cards = XmlApi.Get("banCard",tostring(qq))
    cards = cards == "" and 0 or tonumber(cards) or 0
    if msg == "抽奖" then
        if math.random() > 0.9 then
            local banTime = math.random(1,60)
            cqSetGroupBanSpeak(g,qq,banTime*60)
            return Utils.CQCode_At(qq).."恭喜你抽中了禁言"..tostring(banTime).."分钟"
        else
            local banCard = math.random(-5,6)
            cards = cards + banCard
            XmlApi.Set("banCard",tostring(qq),tostring(cards))
            return Utils.CQCode_At(qq).."恭喜你抽中了"..tostring(banCard).."张禁言卡\r\n"..
                    "当前禁言卡数量："..tostring(cards)
        end
    elseif msg == "禁言卡" then
        return Utils.CQCode_At(qq).."当前禁言卡数量："..tostring(cards)
    elseif msg:find("%d+") then
        if cards <= 0 then
            return Utils.CQCode_At(qq).."你只有"..tostring(cards).."张禁言卡，无法操作"
        end
        XmlApi.Set("banCard",tostring(qq),tostring(cards-1))
        local v = tonumber(msg:match("(%d+)"))
        local banTime = math.random(1,60)
        cqSetGroupBanSpeak(g,v,banTime*60)
        return Utils.CQCode_At(qq).."已将"..tostring(v).."禁言"..tostring(banTime).."分钟"
    else
        return "未匹配到任何命令"
    end
end

return {--抽奖
    check = function (data)
        return data.msg == "抽奖" or data.msg:find("禁言") == 1
    end,
    run = function (data,sendMessage)
        sendMessage(banPlay(data.msg,data.qq,data.group))
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=128142]抽奖/禁言卡"
    end
}
