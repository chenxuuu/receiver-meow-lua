--[[
处理MQTT各消息的逻辑

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

--对各个topic进行订阅
local function subscribe()
    local topics = {
        "live/"..Utils.Setting.ClientID
    }
    for i=1,#topics do
        local result = Mqtt.Subscribe(topics[i], 0)
        Log.Debug(StateName,"MQTT订阅："..(result and "成功" or "失败")..","..topics[i])
    end
end

return function (message)
    --连接成功，马上订阅
    if message.t == "connected" then subscribe() return end

    if message.t == "receive" then
        Log.Debug(StateName,"MQTT收到消息："..message.topic..","..message.payload)
        --Mqtt.Publish("luaRobot/pub/"..Utils.Setting.ClientID, "publish test", 0)

        --直播开启的推送，监控源码见https://github.com/chenxuuu/v-live-check
        if message.topic == "live/"..Utils.Setting.ClientID then
            local liveInfo,r,e = jsonDecode(message.payload)--解析结果
            if r and liveInfo then
                cq.sendGroupMsg(261037783,
                    (liveInfo.image and asyncImage(liveInfo.image) .."\r\n" or "")..
                    liveInfo.name.."\r\n"..
                    (liveInfo.title or "无标题").."\r\n"..
                    ""..liveInfo.url)
            end
        end

    end
end

