--去除字符串开头的空格
local function kickSpace(s)
    if type(s) ~= "string" then return end
    while s:sub(1,1) == " " do
        s = s:sub(2)
    end
    return s
end

return {--!list
    check = function (data)
        return data.msg:find("！ *list *.+") == 1 or data.msg:find("! *list *.+") == 1
    end,
    run = function (data,sendMessage)
        local keyWord = data.msg:match("！ *list *(.+)")
        if not keyWord then keyWord = data.msg:match("! *list *(.+)") end
        keyWord = kickSpace(keyWord)

        local gt,pt--消息内容table

        local glist
        if LuaEnvName ~= "private" then
            glist = XmlApi.GetList(tostring(data.group),keyWord)
            gt = {}
            for i=0,glist.Count-1 do
                table.insert(gt,glist[i])
            end
        end
        local plist = XmlApi.GetList("common",keyWord)
        pt = {}
        for i=0,plist.Count-1 do
            table.insert(pt,plist[i])
        end

        sendMessage(cq.code.at(data.qq).."\r\n🗂️当前词条回复如下：\r\n"..
        (gt and (table.concat(gt,"\r\n").."\r\n共"..tostring(#gt).."条")).."\r\n"..
        "全局词库内容：\r\n"..table.concat(pt,"\r\n").."\r\n共"..tostring(#pt).."条")
        return true
    end,
    explain = function ()
        return "🗂️ !list关键词"
    end
}
