--删除所有匹配词条

--去除字符串开头的空格
local function kickSpace(s)
    if type(s) ~= "string" then return end
    while s:sub(1,1) == " " do
        s = s:sub(2)
    end
    return s
end

return {--!delall
check = function (data)
    return data.msg:find("！ *delall *.+") == 1 or data.msg:find("! *delall *.+") == 1
end,
run = function (data,sendMessage)
    if (XmlApi.Get("adminList",tostring(data.qq)) ~= "admin" or LuaEnvName == "private")
        and data.qq ~= Utils.setting.AdminQQ then
        sendMessage(Utils.CQCode_At(data.qq).."你不是狗管理，想成为狗管理请找我的主人呢")
        return true
    end
    local keyWord = data.msg:match("！ *delall *(.+)")
    if not keyWord then keyWord = data.msg:match("! *delall *(.+)") end
    keyWord = kickSpace(keyWord)
    XmlApi.Delete(tostring(LuaEnvName == "private" and "common" or data.group),keyWord)
    sendMessage(Utils.CQCode_At(data.qq).."\r\n[CQ:emoji,id=128465]删除完成！\r\n"..
    "词条："..keyWord)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128465] !delall关键词"
end
}
