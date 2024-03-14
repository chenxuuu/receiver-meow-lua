--[[
处理MQTT各消息的逻辑

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

--对各个topic进行订阅
local function subscribe()
    local topics = {
        --"live/"..Utils.Setting.ClientID,
        "/8266/test_online",
        "/tg/receive",--tg消息
    }
    for i=1,#topics do
        local result = Mqtt.Subscribe(topics[i], 0)
        Log.Debug(StateName,"MQTT订阅："..(result and "成功" or "失败")..","..topics[i])
    end
end

local messageEvent
local robot_qq
local tg_bot = "@xxxxxxbot "
local topicAction = {
    ["/8266/test_online"] = function (payload)
        XmlApi.Set("settings","lastOnline",tostring(os.time()))
    end,
    ["/tg/receive"] = function (payload)
        --data.msg, data.from
        local data = jsonDecode(payload)
        local to = data.from
        data.qq = 0
        data.group = data.from
        data.send = function(qq,msg)
            local s = jsonEncode({
                msg = msg,
                to = to
            })
            Mqtt.Publish("/tg/send", s, 0)
        end
        cq.code.at = function() return "" end
        if not robot_qq then
            robot_qq = cq.loginInfo().qq
        end
        if data.msg:find(tg_bot) then
            data.msg = data.msg:gsub(tg_bot,"[CQ:at,qq="..robot_qq.."]")
        end
        if not messageEvent then
            local _,info = pcall(function() messageEvent = require("Message") end)
        end
        if messageEvent then
            messageEvent(data)
        end
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

