local function av(bv)
    local bvid = bv:match("bv(%w+)") or bv:match("BV(%w+)")
    local html
    if bvid then
        html = HttpGet("http://api.bilibili.com/x/web-interface/view?bvid="..bvid)
    else
        local av = bv:match("av(%d+)") or bv:match("AV(%d+)")
        html = HttpGet("http://api.bilibili.com/x/web-interface/view?aid="..av)
    end
    if not html then return "查找失败" end
    local j,r,e = jsonDecode(html)
    if j.code ~= 0 then return "数据解析失败啦" end
    local image = j.data.pic and asyncImage(j.data.pic)
    return (image and image.."\r\n" or "")..
    "http://www.bilibili.com/video/av"..j.data.aid.."\r\n"..j.data.title..
    "\r\n"..j.data.desc:gsub("<br/>","\r\n")..
    "\r\n分区："..(j.data.tname and j.data.tname or "")
end

return {--b站av号解析
    check = function (data)
        local msg = data.msg:gsub("%[CQ:.-%]","")--防止匹配到cq码
        return msg:find("av%d+") or msg:find("bv%w+") or msg:find("https://b23.tv/")
    end,
    run = function (data,sendMessage)
        local msg = data.msg:gsub("%[CQ:.-%]","")
        if msg:find("https://b23.tv/") then--短链接解码
            msg = msg:match("(https://b23.tv/%w+)")
            msg = HttpJump(msg)
        end
        sendMessage(av(msg))
        return true
    end,
    explain = function ()
        return "📺b站视频信息获取"
    end
}
