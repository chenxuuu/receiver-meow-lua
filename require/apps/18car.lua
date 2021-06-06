
return {--b站av号解析
    check = function (data)
        return data.msg:lower():find("验车.+")  == 1
    end,
    run = function (data,sendMessage)
        local f,l = data.msg:lower():match("验车 *(%l+)[ -]*(%d+)")
        print(f,l)
        if f and l then
            local html = HttpGet("http://www."..XmlApi.Get("settings","jav")..".com/cn/vl_searchbyid.php?keyword="..f.."-"..l)
            local title = html:match([[<div id="video_title"><h3 class="post%-title text"><a href="/cn/%?v=.-" rel='bookmark' >(.-)</a></h3>]])
            local cover = html:match([[<img id="video_jacket_img" src="(.-)"]])
            local time = html:match([[<td class="header">发行日期:</td>.-<td class="text">(.-)</td>]])
            local len = html:match([[<td class="header">长度:</td>.-<td><span class="text">(.-)</span>]])
            if title and cover and time and len then
                if cover:find("//") == 1 then cover = cover:sub(3) end
                local para = jsonEncode({url=cover})
                local su = HttpPost("https://xn--ugt.cc/api/set.php",para)
                local j,r = jsonDecode(su)
                if r and j then
                    cover = "https://"..j.content.url
                else
                    cover = "获取失败"
                end
                sendMessage(cq.code.at(data.qq)..title.."\r\n官方封面："..cover.."\r\n发行时间："..time.."\r\n视频时长："..len.."分钟")
            else
                sendMessage(cq.code.at(data.qq).."没找到")
            end
        else
            sendMessage(cq.code.at(data.qq).."番号格式不正确")
        end
        return true
    end,
    explain = function ()
        return "🚕验车 字母 数字"
    end
}
