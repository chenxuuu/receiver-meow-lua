--[[
处理MQTT各消息的逻辑

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

--对各个topic进行订阅
local function subscribe()
    local topics = {
        "luaRobot/sub/"..Utils.setting.ClientID
    }
    for i=1,#topics do
        local result = Mqtt.Subscribe(topics[i], 0)
        CQLog:Debug("lua插件","MQTT订阅："..(result and "成功" or "失败")..","..topics[i])
    end
end

return function (message)
    --连接成功，马上订阅
    if message.t == "connected" then subscribe() return end

    if message.t == "receive" then
        CQLog:Debug("lua插件","MQTT收到消息："..message.topic..","..message.payload)
        Mqtt.Publish("luaRobot/pub/"..Utils.setting.ClientID, "publish test", 0)
    end
end



--luaRobot/pub/a06a52aa-f758-47f0-933a-2a6eed405302
--luaRobot/sub/a06a52aa-f758-47f0-933a-2a6eed405302
