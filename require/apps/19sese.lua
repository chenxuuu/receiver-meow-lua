
return {--b站av号解析
    check = function (data)
        return data.msg == "色色开关"
    end,
    run = function (data,sendMessage)
        if LuaEnvName == "private" then return end --私聊不管
        if (XmlApi.Get("adminList",tostring(data.qq)) ~= "admin" or LuaEnvName == "private")
            and data.qq ~= Utils.Setting.AdminQQ then
            sendMessage(cq.code.at(data.qq).."你不是狗管理，想成为狗管理请找我的主人呢")
            return true
        end
        local status = XmlApi.Get("sese",tostring(data.group)) == "on"
        if status then
            XmlApi.Delete("sese",tostring(data.group))
            sendMessage("呼~~主人终于拔出来了呢❤")
        else
            XmlApi.Set("sese",tostring(data.group),"on")
            sendMessage("唔唔……唔❤……主人不要❤")
        end
        return true
    end,
    explain = function ()
        return "❤色色开关"
    end
}
