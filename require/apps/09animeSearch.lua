--查动画
--api key请用自己的
local key = XmlApi.Get("settings","trace.moe")

local function animeSearch(msg)
    local pCheck = Utils.GetPictureWidth(msg) / Utils.GetPictureHeight(msg)
    if pCheck < 1.4 or pCheck > 1.8 then
        return "别拿表情忽悠我、请换一张完整的、没有裁剪过的动画视频截图"
    elseif pCheck ~= pCheck then --0/0 == IND
        return "未在消息中过滤出图片"
    end

    local imagePath = Utils.GetImagePath(msg)--获取图片路径

    if imagePath == "" then return "未在消息中过滤出图片" end

    --imagePath = Utils.GetAsciiHex(imagePath):fromHex()--转码路径，以免乱码找不到文件

    local base64 = Utils.Base64File(imagePath)--获取base64结果
    local html = asyncHttpPost("https://trace.moe/api/search?token="..key,
    "image=data:image/jpeg;base64,"..base64,15000)
    if not html or html:len() == 0 then
        return "查找失败，网站炸了，请稍后再试。或图片大小超过了1MB"
    end
    local d,r,i = jsonDecode(html)
    if r then
        return "搜索结果：\r\n"..
        "动画名："..d.docs[1].title_native.."("..d.docs[1].title_romaji..")\r\n"..
        (d.docs[1].title_chinese and "译名："..d.docs[1].title_chinese.."\r\n" or "")..
        (d.docs[1].similarity < 0.86 and "准确度："..tostring(math.floor(d.docs[1].similarity*100)).."%"..
        "\r\n（准确度过低，请确保这张图片是完整的、没有裁剪过的动画视频截图）\r\n" or "")..
        (d.docs[1].episode and "话数："..tostring(d.docs[1].episode).."\r\n" or "")..
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
    sys.taskInit(function ()
        sendMessage(cq.code.at(data.qq).."\r\n"..animeSearch(data.msg))
    end)
    return true
end,
explain = function ()
    return "🎞️查动画 加 没裁剪过的视频截图"
end
}
