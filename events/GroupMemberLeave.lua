return function (data)
    if data.group == 261037783 then return end--dd提醒群不提醒这种东西
    cq.sendGroupMsg(data.group,tostring(data.qq).."永远地离开了这个世界。。")
    if data.group == 241464054 then
        local player = XmlApi.Get("bindQq",tostring(data.qq))
        if player ~= "" then
            TcpServer.Send("lp user "..player.." permission set group.default",true)
            TcpServer.Send("lp user "..player.." permission unset group.whitelist",true)
        end
        XmlApi.Delete("bindStep",tostring(data.qq))
        XmlApi.Delete("bindQq",tostring(data.qq))
    end
end
