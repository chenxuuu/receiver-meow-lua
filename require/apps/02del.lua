--删除第一个匹配词条

--去除字符串开头的空格
local function kickSpace(s)
    if type(s) ~= "string" then return end
    while s:sub(1,1) == " " do
        s = s:sub(2)
    end
    return s
end

return {--!del
check = function (data)
    return (data.msg:find("！ *del *.+：.+") == 1 or data.msg:find("! *del *.+:.+") == 1)
    and not (data.msg:find("！ *deladmin *.+") == 1 or data.msg:find("! *deladmin *.+") == 1)
end,
run = function (data,sendMessage)
    if (XmlApi.Get("adminList",tostring(data.qq)) ~= "admin" or LuaEnvName == "private")
        and data.qq ~= Utils.Setting.AdminQQ then
        sendMessage(cq.code.at(data.qq).."你不是狗管理，想成为狗管理请找我的主人呢")
        return true
    end
    local keyWord,answer = data.msg:match("！ *del *(.+)：(.+)")
    if not keyWord then keyWord,answer = data.msg:match("! *del *(.-):(.+)") end
    keyWord = kickSpace(keyWord)
    answer = kickSpace(answer)
    if not keyWord or not answer or keyWord:len() == 0 or answer:len() == 0 then
        sendMessage(cq.code.at(data.qq).."格式错误，请检查") return true
    end
    XmlApi.DeleteOne(tostring(LuaEnvName == "private" and "common" or data.group),keyWord,answer)
    sendMessage(cq.code.at(data.qq).."\r\n🗑️删除完成！\r\n"..
    "词条："..keyWord.."\r\n"..
    "回答："..answer)
    return true
end,
explain = function ()
    return "🗑️ !del关键词:回答"
end
}
