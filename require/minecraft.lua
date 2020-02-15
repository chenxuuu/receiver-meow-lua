local mc = {}

local formList = {"commit3","basic1","basic2","basic3","basic4","basic5",
"basic6","basic7","basic8","basic9","basic10","basic11","basic12","basic13",
"basic14","basic15",--"commit4","mc1","mc2","mc3","mc4","mc5","mc6","mc7","mc8",
--"mc9","mc10","mc11",
"commit5","text1","text2","text3","text4","text5","text6",
"text7","text8","text9","commit6","last1","last2","last3","last4",}

local formTitle = {
commit3 = "基本信息",
basic1 = "从哪里知道的这个服务器？",
basic2 = "你的id（不允许中文、仅限英文和下划线）",
basic3 = "帐号是正版还是盗版？",
basic4 = "写上自己QQ号，用于接收初始密码和过审通知，此项重要勿填错",
basic5 = "年龄",
basic6 = "minecraft的熟悉程度？",
basic7 = "对糖拌服的了解程度",
basic8 = "请问你是否有去过其他服务器？如果有的话，请简述你的经历，并带上对那个服务器的评价。",
basic9 = "请问你是从哪个Minecraft版本开始玩的？",
basic10 = "您是否会将游戏帐号与他人共享？",
basic11 = "是否会加糖拌苦力怕官方群？（填完会给你加群密码，记得加群）",
basic12 = "是否服从服务器的相关规定以及管理组相关人员决定？",
basic13 = "如果你违反了服务器的相关条例，你会怎么做？",
basic14 = "是否会卷入玩家纠纷中",
basic15 = "是否有在其他MC网站/服务器进行过技术研讨或是管理方面的事务？如果有，请描述一下",
commit4 = "游戏常识性问题",
mc1 = "下面哪个mod，不是服务器现在有的？",
mc2 = "以下哪件事情在糖拌服是允许的？",
mc3 = "在Minecraft1.2.5版本中喂什么可以让猪繁殖？",
mc4 = "下面关于红石的说法错误的是？",
mc5 = "下面关于甘蔗的叙述错误的是？",
mc6 = "下面关于僵尸的说法中错误的是？",
mc7 = "以下哪个附魔是普通玩家无法附魔出的？",
mc8 = "下面关于龙蛋的说法错误的是？",
mc9 = "下面关于床的说法错误的是？",
mc10 = "糖拌服中发现自己东西被偷了，想查询方块记录看看是谁偷的，怎么做？",
mc11 = "你觉得选择题你能对几题？",
commit5 = "简答题",
text1 = "请给出你认为你可以通过审核的理由",
text2 = "请想象当op玩脱导致你损失时你将会做什么？想什么？",
text3 = "在服务器里生活有什么注意事项？",
text4 = "请简单的阐述一下对糖拌服的第一印象和对糖拌服运营情况的评价",
text5 = "请说出你对高频、大型红石电路与刷怪塔的看法",
text6 = "假如你的建筑被熊孩子破坏了，请简述对熊孩子的正确做法",
text7 = "请写出服务器建造常识",
text8 = "会被封禁的行为有哪些",
text9 = "会被处予三年以上、七年以下的封禁处罚的行为有哪些",
commit6 = "收尾",
last1 = "怎样才会有白名单",
last2 = "审核的管理是不是24小时都盯着电脑",
last3 = "豆腐脑是甜的好还是咸的好",
last4 = "如果可以，请给予此申请表单一些建议或意见",
}

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

--获取某人的表单
function mc.GetForm(id)
    local unread = asyncHttpGet("https://www.sweetcreeper.com/form/get.php","m=unread")
    if not unread:find(",") then
        return
    end
    unread = unread:sub(1,-2):split(",")
    for i=#unread,1,-1 do
        local html = asyncHttpGet("https://www.sweetcreeper.com/form/get.php","m=get&id="..
            unread[i])
        local d,r,e = jsonDecode(html)
        if r and d.basic2 == id then
            return d
        end
    end
end

function mc.readForm(id)
    local form = mc.GetForm(id)
    if not form then
        return "这人没提交申请，发“查申请id”可以手动查"
    end
    local r = {}
    for i=1,#formList do
        if form[formList[i]] then
            table.insert(r,"["..tostring(i).."]"..
            formTitle[formList[i]].."\r\n"..form[formList[i]])
        end
    end
    return table.concat(r,"\r\n")
end

function mc.markForm(id)
    local unread = asyncHttpGet("https://www.sweetcreeper.com/form/get.php","m=unread")
    if not unread:find(",") then
        return
    end
    unread = unread:sub(1,-2):split(",")
    for i=#unread,1,-1 do
        local html = asyncHttpGet("https://www.sweetcreeper.com/form/get.php","m=get&id="..
            unread[i])
        local d,r,e = jsonDecode(html)
        if r and d.basic2 == id then
            asyncHttpGet("https://www.sweetcreeper.com/form/get.php","m=mark&id="..
                unread[i])
        end
    end
end

return mc
