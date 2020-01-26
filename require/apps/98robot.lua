return {--@触发QQ智能机器人
check = function (data)
    return data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") and
    data.msg:gsub("%[CQ:.-%]",""):len() > 2
end,
run = function (data,sendMessage)
    sys.taskInit(function ()
        local text = data.msg:gsub("%[CQ:.-%]",""):gsub(" ","")--过滤掉特殊内容的消息
        local appid = XmlApi.Get("settings","qqai_APPID")--应用信息
        local appkey = XmlApi.Get("settings","qqai_APPKEY")
        --原始请求数据
        local rawBody = "app_id="..appid.."&"..
                        "nonce_str="..getRandomString(20).."&"..
                        "question="..text:urlEncode().."&"..
                        "session="..tostring(data.qq).."&"..
                        "time_stamp="..tostring(os.time())
        local sign = Utils.MD5Encrypt(rawBody.."&app_key="..appkey)
        rawBody = rawBody.."&sign="..sign:upper()
        local http = asyncHttpGet("https://api.ai.qq.com/fcgi-bin/nlp/nlp_textchat?"..rawBody)
        local d,r = jsonDecode(http)
        if r then
            if d and d.ret ~= 0 then return end--没结果
            if d and d.data and d.data.answer then
                sendMessage(Utils.CQCode_At(data.qq)..d.data.answer)
                return true
            end
        end
    end)
end,
explain = function ()--功能解释，返回为字符串，若无需显示解释，返回nil即可
    return "👾 @机器人，进行聊天"
end
}
