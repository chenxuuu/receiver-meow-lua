local mc = {}

function mc.getData(p)
    local onlineData = XmlApi.Get("minecraftData",p)
    local data = onlineData == "" and
    {
        time = 0,
        last = "offline",
        ltime = os.time(),
        money = 0,
    } or jsonDecode(onlineData)
    if not data.money then--如果没金币数据
        data.money = math.floor(data.time/60)
    end
    return data
end

--开始统计在线时长
local function startCount(p)
    local data = mc.getData(p)
    if data.last == "online" then return end--上次信息本来就是在线，停止记录
    data.last = "online"
    data.ltime = os.time()
    local d,r = jsonEncode(data)
    if r then
        XmlApi.Set("minecraftData",p,d)
    end
end

--结束统计在线时长
local function stopCount(p)
    local data = mc.getData(p)
    if data.last == "offline" then return end--上次信息本来就是离线，停止记录
    data.last = "offline"
    local last = data.time
    data.time = data.time + os.time() - data.ltime
    data.money = data.money + math.floor((data.time - last)/60)--加钱
    data.ltime = os.time()
    local d,r = jsonEncode(data)
    if r then
        XmlApi.Set("minecraftData",p,d)
    end
end

--添加在线的人
function mc.onlineAdd(p)
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
    table.insert(onlineResult,p)
    XmlApi.Set("minecraftData","[online]",table.concat(onlineResult,","))
    startCount(p)
end

--删除在线的人
function mc.onlineDel(p)
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
end

--删除所有在线的人
function mc.onlineClear()
    local onlineData = XmlApi.Get("minecraftData","[online]")
    local online = {}--存储在线所有人id
    if onlineData ~= "" then
        online = onlineData:split(",")
    end
    while #online > 0 do
        local player = table.remove(online,1)
        stopCount(player)
    end
    XmlApi.Set("minecraftData","[online]","")
end

return mc
