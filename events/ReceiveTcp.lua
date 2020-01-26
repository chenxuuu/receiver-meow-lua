--[[
处理收到的tcp消息

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

--开始统计在线时长
local function startCount(p)
    local onlineData = XmlApi.Get("minecraftData",p)
    local data = onlineData == "" and
    {
        time = 0,
        last = "offline",
        ltime = os.time(),
    } or jsonDecode(onlineData)
    data.last = "online"
    data.ltime = os.time()
    local d,r = jsonEncode(data)
    if r then
        XmlApi.Set("minecraftData",p,d)
    end
end

local function startCountDay(p)
    local fname = "minecraftData"..os.date("%Y-%m-%d-",os.time())
    local onlineData = XmlApi.Get(fname,p)
    local data = onlineData == "" and
    {
        time = 0,
        last = "offline",
        ltime = os.time(),
    } or jsonDecode(onlineData)
    data.last = "online"
    data.ltime = os.time()
    local d,r = jsonEncode(data)
    if r then
        XmlApi.Set(fname,p,d)
    end
    CQApi:SendGroupMessage(241464054,"玩家"..p.."今日累计在线"..
        string.format("%d小时%d分钟",
            math.floor(data.time/(60*60)),
            math.floor(data.time/60)%60 )
        )
end

--结束统计在线时长
local function stopCount(p)
    local onlineData = XmlApi.Get("minecraftData",p)
    local data = onlineData == "" and
    {
        time = 0,
        last = "offline",
        ltime = os.time(),
    } or jsonDecode(onlineData)
    if data.last ~= "online" then return end--上次信息不是在线，停止记录
    data.last = "offline"
    data.time = data.time + os.time() - data.ltime
    data.ltime = os.time()
    local d,r = jsonEncode(data)
    if r then
        XmlApi.Set("minecraftData",p,d)
    end
end

local function stopCountDay(p)
    local fname = "minecraftData"..os.date("%Y-%m-%d-",os.time())
    local onlineData = XmlApi.Get(fname,p)
    local data = onlineData == "" and
    {
        time = 0,
        last = "offline",
        ltime = os.time(),
    } or jsonDecode(onlineData)
    if data.last ~= "online" then return end--上次信息不是在线，停止记录
    data.last = "offline"
    data.time = data.time + os.time() - data.ltime
    data.ltime = os.time()
    local d,r = jsonEncode(data)
    if r then
        XmlApi.Set(fname,p,d)
    end
    CQApi:SendGroupMessage(241464054,"玩家"..p.."今日累计在线"..
        string.format("%d小时%d分钟",
            math.floor(data.time/(60*60)),
            math.floor(data.time/60)%60 )
        )
end

--添加在线的人
local function onlineAdd(p)
    local onlineData = XmlApi.Get("minecraftData","[online]")
    local online = {}--存储在线所有人id
    if onlineData ~= "" then
        online = onlineData:split(",")
    end
    table.insert(online,p)
    XmlApi.Set("minecraftData","[online]",table.concat(online,","))
    startCount(p)
    startCountDay(p)
end

--删除在线的人
local function onlineDel(p)
    local onlineData = XmlApi.Get("minecraftData","[online]")
    local online = {}--存储在线所有人id
    if onlineData ~= "" then
        online = onlineData:split(",")
    end
    local onlineResult = {}
    while #online > 0 do
        local player = table.remove(online,1)
        if player ~= p then
            table.insert(onlineResult,player)
        end
    end
    XmlApi.Set("minecraftData","[online]",table.concat(onlineResult,","))
    stopCount(p)
    stopCountDay(p)
end

--删除所有在线的人
local function onlineClear()
    local onlineData = XmlApi.Get("minecraftData","[online]")
    local online = {}--存储在线所有人id
    if onlineData ~= "" then
        online = onlineData:split(",")
    end
    local onlineResult = {}
    while #online > 0 do
        local player = table.remove(online,1)
        stopCount(player)
    end
    XmlApi.Set("minecraftData","[online]","")
end

local solve = {
    l = function (msg)
        onlineAdd(msg)
        CQApi:SendGroupMessage(241464054,msg.."上线了")
        if XmlApi.Row("bindQq",msg) == "" then--自动撤销没在群里的人的白名单
            TcpServer.Send("cmdlp user "..msg.." permission set group.default")
            TcpServer.Send("cmdlp user "..msg.." permission unset group.whitelist")
        end
    end,
    d = function (msg)
        onlineDel(msg)
        CQApi:SendGroupMessage(241464054,msg.."掉线了")
    end,
    m = function (msg)
        if msg:find("%[主世界%]") or
           msg:find("%[旧世界%]") or
           msg:find("%[创造界%]") or
           msg:find("%[下界%]") or
           msg:find("%[末地%]") or
           msg:find("%[二周目%]") or
           msg:find("%[三周目%]") or
           msg:find("%[三周目雪世界%]") or
           msg:find("%[四周目%]") or
           msg:find("%[四周目雪世界%]") or
           msg:find("%[资源世界%]") then
            CQApi:SendGroupMessage(241464054,Utils.CQEnCode(msg))
        end
    end,
    c = function ()
        CQApi:SendGroupMessage(241464054,"服务器已启动完成")
        onlineClear()
        TcpServer.Send("cmdworld create mine")
    end,
}


return function (message)
    local messageType = message:sub(1,1)
    if solve[messageType] then
        solve[messageType](message:sub(2))
    end
end
