--[[
处理MQTT各消息的逻辑

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

--对各个topic进行订阅
local function subscribe()
    local topics = {
        --"live/"..Utils.Setting.ClientID,
        "/8266/test_online"
    }
    for i=1,#topics do
        local result = Mqtt.Subscribe(topics[i], 0)
        Log.Debug(StateName,"MQTT订阅："..(result and "成功" or "失败")..","..topics[i])
    end
end

local topicAction = {
    ["/8266/test_online"] = function (payload)
        XmlApi.Set("settings","lastOnline",tostring(os.time()))
    end,
}
return function (message)
    --连接成功，马上订阅
    if message.t == "connected" then subscribe() return end

    if message.t == "receive" then
        Log.Debug(StateName,"MQTT收到消息："..message.topic..","..message.payload)
        --Mqtt.Publish("luaRobot/pub/"..Utils.Setting.ClientID, "publish test", 0)
        if topicAction[message.topic] then
            topicAction[message.topic](message.payload)
        end


    end
end

