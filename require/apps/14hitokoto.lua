local function hitokoto(data)
    local say = asyncHttpGet("http://v1.hitokoto.cn")
    local types = {
    a = "Anime - 动画",
    b = "Comic – 漫画",
    c = "Game – 游戏",
    d = "Novel – 小说",
    e = "Myself – 原创",
    f = "Internet – 来自网络",
    g = "Other – 其他",
    }
    local function getText(s)
        if not s then return end
        local data = JSON:decode(s)
        if not s then return end
        local hitokoto,saytype,from
        if not pcall(function ()
            hitokoto,saytype,from = data.hitokoto, data.type, data.from
        end) then
            return
        end
        return hitokoto.."\r\n--"..from.."\r\n"..types[saytype]
    end
    return getText(say) or Utils.CQCode_At(data.qq).."\r\n加载失败啦"
end




return {--一言
check = function (data)
    return data.msg == "一言"
end,
run = function (data,sendMessage)
    sys.taskInit(function ()
        sendMessage(hitokoto(data))
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128226]一言"
end
}
