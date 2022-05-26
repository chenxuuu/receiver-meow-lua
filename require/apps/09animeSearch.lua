--查动画
--api key请用自己的
local key = XmlApi.Get("settings","trace.moe")

local function animeSearch(msg)
    local img = msg:match("%[CQ:image,file=.-,url=(.-)%]")

    if not img then return "未在消息中过滤出图片" end

    print("https://api.trace.moe/search?anilistInfo&token="..key.."&url="..img)
    local html = HttpGet("https://api.trace.moe/search?anilistInfo&token="..key.."&url="..img,nil,30000)
    if not html or html:len() == 0 then
        return "查找失败（网站炸了或图片大小超过了1MB）请稍后再试。"
    end
    local d,r,i = jsonDecode(html)
    if r and d.result and #d.result > 0 then
        return "搜索结果：\r\n"..
        "动画名："..d.result[1].anilist.title.native.."("..d.result[1].anilist.title.romaji..")\r\n"..
        (d.result[1].anilist.title.english and "英文名："..d.result[1].anilist.title.english.."\r\n" or "")..
        (d.result[1].similarity < 0.86 and "准确度："..tostring(math.floor(d.result[1].similarity*100)).."%"..
        "\r\n（准确度过低，请确保这张图片是完整的、没有裁剪过的动画视频截图）\r\n" or "")..
        (d.result[1].episode and "话数："..tostring(d.result[1].episode).."\r\n" or "")..
        "by trace.moe"
    else
        return "没搜到结果，请换一张完整的、没有裁剪过的动画视频截图"
    end
end



return {--查动画
check = function (data)
    return data.msg:find("查动画") or data.msg:find("搜动画") or
            data.msg:find("查番") or data.msg:find("搜番")
end,
run = function (data,sendMessage)
    sendMessage(cq.code.at(data.qq).."查询中。。。")
    sendMessage(cq.code.at(data.qq).."\r\n"..animeSearch(data.msg))
    return true
end,
explain = function ()
    return "🎞️查动画 加 没裁剪过的视频截图"
end
}
