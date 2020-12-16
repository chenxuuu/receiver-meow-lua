return {--!deladmin
check = function (data)
    return (data.msg:find("！ *deladmin *.+") == 1 or data.msg:find("! *deladmin *.+") == 1) and
    data.qq == Utils.Setting.AdminQQ
end,
run = function (data,sendMessage)
    local keyWord = data.msg:match("(%d+)")
    if keyWord and XmlApi.Get("adminList",keyWord) == "" then
        sendMessage(cq.code.at(data.qq).."\r\n狗管理"..keyWord.."已经挂了")
    else
        XmlApi.Delete("adminList",keyWord)
        sendMessage(cq.code.at(data.qq).."\r\n已宰掉狗管理"..keyWord)
    end
    return true
end,
}
