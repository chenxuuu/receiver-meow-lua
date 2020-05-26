--插件启动后调用的文件
--目前仅用来注册各种开机后会运行的东西
--并且当前文件的功能，仅在账号为chenxu自己的测试qq下运行

--检查GitHub的最新commit记录
function checkGitHub(url,save)
    local githubRss = asyncHttpGet(url)
    if githubRss or githubRss ~= "" then--获取成功的话
        local xml2lua = loadfile(CQApi.AppDirectory.."lua/require/xml2lua.lua")()
        --Uses a handler that converts the XML to a Lua table
        local handler = loadfile(CQApi.AppDirectory.."lua/require/xmlhandler/tree.lua")()
        local parser = xml2lua.parser(handler)
        parser:parse(githubRss)
        local lastUpdate = handler.root.feed.updated
        if lastUpdate and lastUpdate ~= XmlApi.Get("settings",save) then
            XmlApi.Set("settings",save,lastUpdate)
            for i,j in pairs(handler.root.feed.entry) do
                --缩短网址
                local shortUrl = asyncHttpPost("https://git.io/create","url="..j.link._attr.href:urlEncode())
                shortUrl = (not shortUrl or shortUrl == "") and j.link._attr.href or "https://biu.papapoi.com/"..shortUrl
                --返回结果
                local toSend = "更新时间(UTC)："..(lastUpdate):gsub("T"," "):gsub("Z"," ").."\r\n"..
                "提交内容："..j.title.."\r\n"..
                "查看变动代码："..shortUrl
                return true,toSend
            end
        end
    end
end
--检查GitHub的最新发布版本记录
function checkGitRelease(url,save)
    local release = asyncHttpGet(url)
    local d,r,e = jsonDecode(release)
    if not r or not d then return end
    if d.id and tostring(d.id) ~= XmlApi.Get("settings",save) then
        XmlApi.Set("settings",save,tostring(d.id))
        --缩短网址
        local shortUrl = asyncHttpPost("https://git.io/create","url="..d.html_url:urlEncode())
        shortUrl = (not shortUrl or shortUrl == "") and d.html_url or "https://biu.papapoi.com/"..shortUrl

        --返回结果
        local toSend = "更新时间(UTC)："..(d.created_at):gsub("T"," "):gsub("Z"," ").."\r\n"..
        "版本："..d.tag_name.."\r\n"..
        d.name.."\r\n"..
        d.body.."\r\n"..
        "查看更新："..shortUrl
        return true,toSend
    end
end

return function ()
    --防止多次启动
    if AppFirstStart then return end
    AppFirstStart = true

    --仅限作者的机器人号用这个功能
    if CQApi:GetLoginQQId() ~= 751323264 and CQApi:GetLoginQQId() ~= 3617883457 then return end

    --服务器空间定期检查任务，十分钟一次
    CQLog:Debug("lua插件","加载服务器空间定期检查任务")
    sys.timerLoopStart(function ()
        CQLog:Debug("lua插件","执行服务器空间定期检查任务")
        local free = Utils.GetHardDiskFreeSpace("D")
        if free < 1024 * 10 then--空间小于10G
            CQApi:SendGroupMessage(567145439,
            Utils.CQCode_At(961726194)..
            "你的小垃圾服务器空间只有"..tostring(Utils.GetHardDiskFreeSpace("D")).."M空间了知道吗？快去清理")
        end
    end,600 * 1000)

    --mc服务器定时重启
    CQLog:Debug("lua插件","加载mc服务器定时重启任务")
    sys.taskInit(function ()
        while true do
            local delay
            local time = os.date("*t")
            local next = os.date("*t",os.time())
            if time.hour >=12 then
                next = os.date("*t",os.time()+3600*24)
                next.hour = 12
                next.min = 0
                next.sec = 0
                delay = os.time(next) - os.time()
            else
                next.hour = 12
                next.min = 0
                next.sec = 0
                delay = os.time(next) - os.time()
            end
            CQLog:Debug("lua插件","mc自动重启，延时"..delay.."秒")
            sys.wait(delay * 1000)
            CQLog:Debug("lua插件","mc自动重启，开始执行")
            if Utils.GetHardDiskFreeSpace("D") > 1024 * 10 then
                CQApi:SendGroupMessage(241464054,
                    "一分钟后，将自动进行服务器例行重启与资源世界回档，请注意自己身上的物品")
                TcpServer.Send("一分钟后，将自动进行服务器例行重启与资源世界回档，请注意自己身上的物品")
                sys.wait(60000)
                TcpServer.Send("cmdstop")
                sys.wait(3600*1000)
                TcpServer.Send("cmdworld create mine")
            end
        end
    end)

    --检查GitHub更新
    sys.taskInit(function ()
        while true do
            CQLog:Debug("lua插件","检查GitHub更新，开始执行")
            local r,info = pcall(function ()
                local cr,ct = checkGitRelease("https://api.github.com/repos/chenxuuu/receiver-meow/releases/latest","githubRelease")
                if cr and ct then CQApi:SendGroupMessage(931546484, "接待喵lua插件发现插件版本更新\r\n"..ct) end
            end)
            if not r then print(info) end
            CQLog:Debug("lua插件","检查GitHub更新，结束执行")
            sys.wait(600*1000)
        end
    end)
end
