return {--通用回复
check = function ()
    return true
end,
run = function (data,sendMessage)
    if data.qq == 1000000 then
        return true
    end
    local replyGroup = LuaEnvName ~= "private" and XmlApi.RandomGet(tostring(data.group),data.msg) or ""
    local replyCommon = XmlApi.RandomGet("common",data.msg)
    if replyGroup == "" and replyCommon ~= "" then
        sendMessage(replyCommon)
    elseif replyGroup ~= "" and replyCommon == "" then
        sendMessage(replyGroup)
    elseif replyGroup ~= "" and replyCommon ~= "" then
        sendMessage(math.random(1,10)>=5 and replyCommon or replyGroup)
    else
        return false
    end
    return true
end
}
