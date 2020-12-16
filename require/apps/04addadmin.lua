return {--!addadmin
check = function (data)
    return (data.msg:find("！ *addadmin *.+") == 1 or data.msg:find("! *addadmin *.+") == 1) and
    data.qq == Utils.Setting.AdminQQ
end,
run = function (data,sendMessage)
    local keyWord = data.msg:match("(%d+)")
    if keyWord and XmlApi.Get("adminList",keyWord) == "admin" then
        sendMessage(cq.code.at(data.qq).."\r\n"..keyWord.."已经是狗管理了")
    else
        XmlApi.Set("adminList",keyWord,"admin")
        sendMessage(cq.code.at(data.qq).."\r\n已添加狗管理"..keyWord)
    end
    return true
end,
}
