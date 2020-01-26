local function getImage()
    local s = asyncHttpGet("http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=10")
    local t,result,error = jsonDecode(s)
    if result then
        if t.images and t.images[1] and t.images[1].url then
            return asyncImage("http://www.bing.com"..t.images[1].url).."\r\n"..t.images[1].copyright
        else
            return "图片加载失败啦"
        end
    else
        return "数据解析失败啦，错误原因："..error
    end
end

return {--必应美图
check = function (data)
    return data.msg:find("必应") == 1 and (data.msg:find("美图") or data.msg:find("壁纸"))
end,
run = function (data,sendMessage)
    sendMessage(Utils.CQCode_At(data.qq).."已经开始获取了哦")
    sys.taskInit(function ()
        sendMessage(getImage())
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=127964]必应壁纸"
end
}
