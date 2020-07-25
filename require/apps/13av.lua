local function av(bv)
    local bvid = bv:match("bv(%w+)") or bv:match("BV(%w+)")
    local html
    if bvid then
        html = asyncHttpGet("http://api.bilibili.com/x/web-interface/view?bvid="..bvid)
    else
        local av = bv:match("av(%d+)") or bv:match("AV(%d+)")
        html = asyncHttpGet("http://api.bilibili.com/x/web-interface/view?aid="..av)
    end
    if not html then return "查找失败" end
    local j,r,e = jsonDecode(html)
    if j.code ~= 0 then return "数据解析失败啦" end
    local image = j.data.pic and asyncImage(j.data.pic)
    return (image and image.."\r\n" or "")..
    "av"..j.data.aid..",标题："..j.data.title..
    "\r\n"..j.data.desc:gsub("<br/>","\r\n")..
    "\r\n分区："..(j.data.tname and j.data.tname or "")
end

return {--b站av号解析
    check = function (data)
        return data.msg:lower():find("av%d+") or data.msg:lower():find("bv%w+") or
        data.msg:find("%[CQ:rich,title=&#91;QQ小程序&#93;哔哩哔哩,") == 1
    end,
    run = function (data,sendMessage)
        if data.msg:find("%[CQ:rich,title=&#91;QQ小程序&#93;哔哩哔哩,") == 1 then
            sendMessage("关爱PC端用户，少发小程序，从我做起\r\n"..
            "标题："..(data.msg:match([[desc":"(.-)"]]) or "获取失败").."\r\n"..
            "链接："..(data.msg:match([["qqdocurl":"(.-)%?]]) or "获取失败"))
        else
            sys.taskInit(function ()
                sendMessage(av(data.msg))
            end)
        end
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=127902]b站av号解析"
    end
}
