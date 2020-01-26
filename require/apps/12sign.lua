local function sign(qq,msg,group)
    if msg == "开启签到" and qq == admin then
        XmlApi.Delete("settings","sign_open"..tostring(group))
        return "已开启群"..tostring(group).."的签到功能"
    elseif msg == "关闭签到" then
        XmlApi.Set("settings","sign_open"..tostring(group),"close")
        return "已关闭群"..tostring(group).."的签到功能"
    else
        local day = os.date("%Y年%m月%d日")--今天
        local signData = XmlApi.Get("sign",tostring(qq))
        local data = signData == "" and
        {
            last = 0,--上次签到时间戳
            count = 0,--连签计数
        } or jsonDecode(signData)

        if data.last == day then
            return "你已经签过到啦"
        end

        if data.last == os.date("%Y年%m月%d日",os.time()-3600*24) then
            data.count = data.count + 1
        else
            data.count = 1
        end
        data.last = day
        local j = jsonEncode(data)
        XmlApi.Set("sign",tostring(qq),j)

        local cards = XmlApi.Get("banCard",tostring(qq))
        cards = cards == "" and 0 or tonumber(cards) or 0
        local banCard = math.random(1,10)
        cards = cards + banCard
        XmlApi.Set("banCard",tostring(qq),tostring(cards+data.count-1))
        return "签到成功\r\n"..
        "抽中了"..tostring(banCard).."张禁言卡\r\n"..
        "附赠"..tostring(data.count-1).."张连签奖励\r\n"..
        "当前禁言卡数量："..tostring(cards)
    end
end

return {--签到
check = function (data)
    return ((data.msg == "签到" or data.msg:find("%[CQ:sign,") == 1 or data.msg == "关闭签到")
        and XmlApi.Get("settings","sign_open"..tostring(data.group)) ~= "close") or
        (data.msg == "开启签到" and data.qq ~= Utils.setting.AdminQQ )
end,
run = function (data,sendMessage)
    sendMessage(Utils.CQCode_At(data.qq)..sign(data.qq,data.msg,data.group))
    return true
end,
explain = function ()
    return "[CQ:emoji,id=9728][开启/关闭]签到"
end
}
