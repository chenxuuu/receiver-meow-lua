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

--遍历所有YouTube账号直播状态
function v2bAll(channels)
    CQLog:Debug("lua插件", "y2b检查：开始")
    local cs = {}
    local ds = {}
    for i=1,#channels do
        table.insert(cs,channels[i][1])
        ds[channels[i][1]] = channels[i][2]
    end
    local html = asyncHttpGet("https://y2b.papapoi.com/mapi?c="..table.concat(cs,","),nil,60000)

    if not html or html == "" then return end--获取失败了
    local liveInfos,r,e = jsonDecode(html)--解析接口结果
    if not r or not liveInfos then return end --获取失败了
    CQLog:Debug("lua插件", "y2b检查：服务器花费时间"..tostring(liveInfos.time))

    for i,j in pairs(liveInfos.data) do

        while true do
            if j.error then
                CQLog:Debug("lua插件", "y2b检查：返回错误"..j.error)
                break
            end

            local isopen = j.live
            local lastStatus = XmlApi.Get("settings","youtuber_"..i)--获取上次状态
            if isopen then
                if lastStatus == "live" then break end--上次提醒过了
                XmlApi.Set("settings","youtuber_"..i,"live")
                --推给tg机器人
                asyncHttpGet("https://y2b.papapoi.com/bot?pw="..XmlApi.Get("settings","tgbotpw").."&t=image"..
                            "&text="..string.urlEncode("频道："..ds[i].."，"..
                            "标题："..j.title.."，"..
                            "youtube："..j.url).."&image="..string.urlEncode(j.thumbnail))
                CQApi:SendGroupMessage(261037783,
                    asyncImage(j.thumbnail:gsub("i.ytimg.com","y2b.papapoi.com")).."\r\n"..
                    "频道："..ds[i].."\r\n"..
                    "标题："..j.title.."\r\n"..
                    "y2b："..j.url)
                CQLog:Debug("lua插件", "y2b检查："..i.. "开播")
            elseif lastStatus == "live" then--没开播
                XmlApi.Delete("settings","youtuber_"..i)
            end
            --CQLog:Debug("lua插件", "y2b检查："..i.. "结束")
            break
        end
    end
end

--b站
function blive(id)
    id = tostring(id)
    local html = asyncHttpGet("https://api.live.bilibili.com/room/v1/Room/get_info?room_id="..id)
    if not html or html == "" then return end--获取失败了
    local d,r,e = jsonDecode(html)
    if not r or not d then return end --获取失败了
    local lastStatus = XmlApi.Get("settings","bilibili_live_"..id)--获取上次状态
    if d and d.data and d.data.live_status == 1 then
        if lastStatus == "live" then return end--上次提醒过了
        XmlApi.Set("settings","bilibili_live_"..id,"live")
        return {
            title = d.data.title,
            image = d.data.user_cover,
            url = "https://live.bilibili.com/"..id,
        }
    elseif lastStatus == "live" then--没开播
        XmlApi.Delete("settings","bilibili_live_"..id)
    end
end
function checkb(id,name)
    local v = blive(id)
    --CQLog:Debug("lua插件", "b站直播检查："..tostring(id))
    if v then
        --推给tg机器人
        asyncHttpGet("https://y2b.papapoi.com/bot?pw="..XmlApi.Get("settings","tgbotpw").."&t=image"..
                    "&text="..string.urlEncode("频道："..name.."，"..
                    "标题："..v.title.."，"..
                    "b站房间："..v.url).."&image="..string.urlEncode(v.image))
        CQApi:SendGroupMessage(261037783,
            asyncImage(v.image).."\r\n"..
            "频道："..name.."\r\n"..
            "标题："..v.title.."\r\n"..
            "b站房间："..v.url)
        CQLog:Debug("lua插件", "b站直播检查："..tostring(id) .. "状态更新")
    end
end

--twitcasting
function twitcasting(id)
    local html = asyncHttpGet("https://twitcasting.tv/"..id)
    if not html or html == "" then return end--获取失败了
    local info = html:match([[TwicasPlayer.start%((.-})%);]])
    local d,r,e = jsonDecode(info)
    if not r or not d then return end --获取信息失败了
    local lastStatus = XmlApi.Get("settings","twitcasting_live_"..id)--获取上次状态
    if d.isOnlive then
        if lastStatus == "live" then return end--上次提醒过了
        XmlApi.Set("settings","twitcasting_live_"..id,"live")
        return "https:"..d.posterImage
    elseif lastStatus == "live" then--没开播
        XmlApi.Delete("settings","twitcasting_live_"..id)
    end
end
function checkt(id,name)
    local v = twitcasting(id)
    --CQLog:Debug("lua插件", "twitcasting直播检查："..tostring(id))
    if v then
        asyncHttpGet("https://y2b.papapoi.com/bot?pw="..XmlApi.Get("settings","tgbotpw").."&t=image"..
                    "&text="..string.urlEncode("频道："..name.."，"..
                    "twitcasting：https://twitcasting.tv/"..id).."&image="..string.urlEncode(v))
        CQApi:SendGroupMessage(261037783,
            asyncImage(v).."\r\n"..
            "频道："..name.."\r\n"..
            "twitcasting：https://twitcasting.tv/"..id)
        CQLog:Debug("lua插件", "twitcasting直播检查："..tostring(id) .. "状态更新")
    end
end

--检查fc2是否开播
function fc2(channel)
    local html = asyncHttpGet("https://y2b.papapoi.com/fc2?c="..channel)
    if not html or html == "" then return end--获取失败了
    local liveInfo,r,e = jsonDecode(html)--解析接口结果
    if not r or not liveInfo then return end --获取失败了
    local isopen = liveInfo.live
    local lastStatus = XmlApi.Get("settings","fc2_"..channel)--获取上次状态
    if isopen then
        if lastStatus == "live" then return end--上次提醒过了
        XmlApi.Set("settings","fc2_"..channel,"live")
        return {
            --cover = --不敢上图
            name = liveInfo.name,
            --url = liveInfo.url,--不敢上链接
        }
    elseif lastStatus == "live" then--没开播
        XmlApi.Delete("settings","fc2_"..channel)
    end
end
function checkfc2(channel)
    local v = fc2(channel[1])
    CQLog:Debug("lua插件", "fc2直播检查："..tostring(channel[1]))
    if v then
        asyncHttpGet("https://y2b.papapoi.com/bot?pw="..XmlApi.Get("settings","tgbotpw").."&t=text"..
                    "&text="..string.urlEncode("频道："..channel[2].."，"..
                    "标题："..v.name.."，"..
                    "fc2："..channel[1]))
        CQApi:SendGroupMessage(261037783,
        "频道："..channel[2].."\r\n"..
        "标题："..v.name.."\r\n"..
        "fc2："..channel[1])
        CQLog:Debug("lua插件", "fc2直播检查："..tostring(channel[1]) .. "状态更新")
    end
end

local y2bList = {
    --要监控的y2b频道
    {"UCWCc8tO-uUl_7SJXIKJACMw","那吊人🍥"}, --mea
    {"UCQ0UDLQCjY0rmuxCDE38FGg","夏色祭🏮"}, --祭
    {"UC1opHUrw8rvnsadT-iGp7Cg","湊-阿库娅⚓"}, --aqua
    {"UCrhx4PaF3uIo9mDcTxHnmIg","paryi🐇"}, --paryi
    {"UChN7P9OhRltW3w9IesC92PA","森永みう🍫"}, --miu
    {"UC8NZiqKx6fsDT3AVcMiVFyA","犬山💙"}, --犬山
    {"UCH0ObmokE-zUOeihkKwWySA","夢乃栞-Yumeno_Shiori🍄"}, --大姐
    {"UCjCrzObDrkYN-mELiCiSPAQ","夢乃栞II-Yumeno_Shiori🍄II"}, --大姐新频道
    {"UCIaC5td9nGG6JeKllWLwFLA","有栖マナ🐾"}, --mana
    {"UCn14Z641OthNps7vppBvZFA","千草はな🌼"}, --hana
    {"UC0g1AE0DOjBYnLhkgoRWN1w","本间向日葵🌻"}, --葵
    {"UCNMG8dXjgqxS94dHljP9duQ","yyut🎹"}, --yyut
    {"UCL9dLCVvHyMiqjp2RDgowqQ","高槻律🚺"}, --律
    {"UCkPIfBOLoO0hVPG-tI2YeGg","兔鞠mari🥕"}, --兔鞠mari
    {"UCIdEIHpS0TdkqRkHL5OkLtA","名取纱那🍆"}, --名取纱那
    {"UCBAopGXGGatkiB1-qFRG9WA","兔纱🎀"}, --兔纱
    {"UCZ1WJDkMNiZ_QwHnNrVf7Pw","饼叽🐥"}, --饼叽
    {"UC8gSN9D-1FL0BGBQt7p8gFQ","森永みう🍫小号"}, --森永
    {"UCzAxQCoeJrmYkHr0cHfD0Nw","yua🔯"},--yua
    {"UCerH0KOGyPaC5WueExiicZQ","杏💣🍠"},--Anzu
    {"UCPf-EnX70UM7jqjKwhDmS8g","玛格罗那🐟"},--魔王
    {"UCGcD5iUDG8xiywZeeDxye-A","织田信姬🍡"},--织田信
}


local bList = {
    --要监控的bilibili频道
    {14917277,"湊-阿库娅⚓"}, --夸哥
    {14052636,"夢乃栞-Yumeno_Shiori🍄"}, --大姐
    {12235923,"那吊人🍥"}, --吊人
    {4895312,"paryi🐇"}, --帕里
    {7962050,"森永みう🍫"}, --森永
    {13946381,"夏色祭🏮"}, --祭
    {10545,"A姐💽"}, --adogsama
    {12770821,"千草はな🌼"}, --hana
    {3822389,"有栖マナ🐾"}, --mana
    {4634167,"犬山💙"}, --犬山
    {43067,"HAN佬🦊"}, --han佬
    {21302477,"本间向日葵🌻"}, --葵
    {947447,"高槻律🚺"}, --律
    {3657657,"饼叽🐥"},   --饼叽
    {7408249,"兔纱🎀"}, --兔纱
    {21602686,"新科娘☭"},--新科娘
    {80387576,"织田信姬🍡"},--织田信
}

local tList = {
    --要监控的twitcasting频道
    {"kaguramea_vov","那吊人🍥"}, --吊人
    {"morinaga_miu","森永miu🍫"}, --miu
    {"norioo_","海苔男🍡"}, --海苔男
    {"natsuiromatsuri","夏色祭🏮"},--夏色祭
    {"kagura_pepper","神乐七奈🌶"}, --狗妈
    {"c:yumeno_shiori","shiori大姐🍄"}, --p家大姐
    {"maturin_love221","爱小姐☂︎"}, --test
    {"nana_kaguraaa","神乐七奈🌶"}, --狗妈
    {"re2_takatsuki","高槻律🚺"},--律
    {"hukkatunoyuyuta","ゆゆうた🎹"},--yyut
    {"merrysan_cas_","球王🏀"},--球王
}

local fc2List = {
    --要监控的fc2频道
    {"78847652","shiori🍄"}, --大姐
}

return function (data)
    --防止多次启动
    if AppFirstStart then return end
    AppFirstStart = true

    if CQApi:GetLoginQQId() ~= 751323264 then return end--仅限官方群里的机器人号用这个功能

    --服务器空间定期检查任务，十分钟一次
    CQLog:Debug("lua插件","加载服务器空间定期检查任务")
    sys.timerLoopStart(pcall,600 * 1000,function ()
        CQLog:Debug("lua插件","执行服务器空间定期检查任务")
        local free = Utils.GetHardDiskFreeSpace("D")
        if free < 1024 * 10 then--空间小于10G
            CQApi:SendGroupMessage(567145439,
            Utils.CQCode_At(961726194)..
            "你的小垃圾服务器空间只有"..tostring(Utils.GetHardDiskFreeSpace("D")).."M空间了知道吗？快去清理")
        end
    end)

    --mc服务器定时重启
    CQLog:Debug("lua插件","加载mc服务器定时重启任务")
    sys.taskInit(function ()
        while true do
            local delay
            local time = os.date("*t")
            if time.hour >=3 then
                local next = os.date("*t",os.time()+3600*24)
                next.hour = 3
                next.min = 0
                next.sec = 0
                delay = os.time(next) - os.time()
            else
                next.hour = 3
                next.min = 0
                next.sec = 0
                delay = os.time(time) - os.time()
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
                local r,t = checkGitHub("https://github.com/chenxuuu/receiver-meow/commits/master.atom","githubLastUpdate")
                if r and t then CQApi:SendGroupMessage(567145439, "接待喵lua插件在GitHub上有更新啦\r\n"..t) end
                r,t = checkGitRelease("https://api.github.com/repos/chenxuuu/receiver-meow/releases/latest","githubRelease")
                if r and t then CQApi:SendGroupMessage(931546484, "接待喵lua插件发现插件版本更新\r\n"..t) end
            end)
            if not r then print(info) end
            CQLog:Debug("lua插件","检查GitHub更新，结束执行")
            sys.wait(600*1000)
        end
    end)


    sys.taskInit(function ()
        while true do
            CQLog:Debug("lua插件","检查直播，开始执行")
            local r,info = pcall(function ()
                --检查要监控的y2b频道
                v2bAll(y2bList)
                --检查b站
                for i=1,#bList do
                    checkb(bList[i][1],bList[i][2])
                end
                --检查twitcasting
                for i=1,#tList do
                    checkt(tList[i][1],tList[i][2])
                end
                --fc2检查
                for i=1,#fc2List do
                    checkfc2(fc2List[i])
                end
            end)
            if not r then print(info) end
            CQLog:Debug("lua插件","检查直播，结束执行")
            sys.wait(60*1000)--一分钟后继续检查一次
        end
    end)
end
