return {--!addadmin
check = function (data)
    return data.msg == "开机" and data.qq == Utils.Setting.AdminQQ
end,
run = function (data,sendMessage)
    local last = tonumber(XmlApi.Get("settings","lastOnline"))
    if last and os.time() - last > 60 then
        sendMessage("开机控制器不在线。。")
        return true
    end
    if Mqtt.Publish(XmlApi.Get("settings","poweronTopic"), XmlApi.Get("settings","poweronPayload"), 0) then
        sendMessage("已向你电脑发送开机指令")
    else
        sendMessage("我发不出去开机指令，你查查啥问题")
    end
    return true
end,
}
