--导入需要的命名空间
--主库
import("ReceiverMeow","ReceiverMeow")
--luaenv库
import("ReceiverMeow","ReceiverMeow.LuaEnv")
import("ReceiverMeow","ReceiverMeow.GoHttp")
import("System.Text")

StateName = "lua虚拟机("..LuaEnvName..")"

Log.Info(StateName,"加载新虚拟机"..LuaEnvName)

--重写print函数，重定向到debug接口输出
function print(...)
    local r = {}
    for i=1,select('#', ...) do
        table.insert(r,tostring(select(i, ...)))
    end
    if #r == 0 then
        table.insert(r,"nil")
    end
    Log.Info(StateName,table.concat(r,"  "))
end

--加上需要require的路径
package.path = package.path..";./lua/require/?.lua;./lua/events/?.lua;"
package.cpath = package.cpath..";./lua/require/?.lua;./lua/events/?.lua;"

--加载字符串工具包
require("strings")

--安全的，带解析结果返回的json解析函数
--返回值：数据,是否成功,错误信息
JSON = require("JSON")
function jsonDecode(s)
    local result, info = pcall(function(t) return JSON:decode(t) end, s)
    if result then
        return info, true
    else
        return {}, false, info
    end
end
function jsonEncode(t)
    local result, info = pcall(function(t) return JSON:encode(t) end, t)
    if result then
        return info, true
    else
        return "", false, info
    end
end

--加载CQ库
cq = require("cq")

--唯一id
local idTemp = 0
function getId()
    idTemp = idTemp + 1--没必要判断是否溢出，溢出自动变成负数
    return idTemp
end

--封装一个简便的http get接口
function HttpGet(url,para,timeout,cookie)
    local r,e = pcall(function() return Utils.HttpGet(url,para or "",timeout or 5000,cookie or "") end)
    if r then
        return e,r
    else
        return nil,r,e
    end
end
asyncHttpGet = HttpGet

--封装一个简便的http post接口
function HttpPost(url,para,timeout,cookie,contentType)
    local r,e = pcall(function()
        return Utils.HttpPost(url,para or "",timeout or 5000,cookie or "",
        contentType or "application/x-www-form-urlencoded")
    end)
    if r then
        return e,r
    else
        return nil,r,e
    end
end
asyncHttpPost = HttpPost

--封装一个文件下载接口
function HttpDownload(url, path, timeout, cookie)
    local r,e = pcall(function()
        return Utils.HttpDownload(url,"", timeout or 15000,cookie,path)
    end)
    if r then
        return e,r
    else
        return nil,r,e
    end
end
--兼容老接口
asyncFileDownload = function(url, path, maxSize, timeout)
    HttpDownload(url, path, timeout)
end

--根据url显示图片
function asyncImage(url)
    return cq.code.image(url)
end

--加强随机数随机性
math.randomseed(tostring(Utils.Ticks()):reverse():sub(1, 6))

--获取随机字符串
function getRandomString(len)
    local str = "1234567890abcdefhijklmnopqrstuvwxyz"
    local ret = ""
    for i = 1, len do
        local rchr = math.random(1, string.len(str))
        ret = ret .. string.sub(str, rchr, rchr)
    end
    return ret
end

--分配各个事件
local events = {
    AppEnable = "AppEnable",--启动事件
    --FriendAdd = "",--好友已添加
    --FriendAddRequest = "",--好友请求
    GroupAddRequest = "GroupAddRequest",--加群请求
    GroupAddInvite = "GroupAddInvite",--机器人被邀请进群
    --GroupBanSpeak = "",--群禁言
    --GroupUnBanSpeak = "",--群解除禁言
    GroupManageSet = "GroupManageSet",--设置管理
    GroupManageRemove = "GroupManageRemove",--取消管理
    GroupMemberExit = "GroupMemberLeave",--群成员减少，主动退--┐---→统一处理
    GroupMemberRemove = "GroupMemberLeave",--群成员减少，被踢--┘
    GroupMemberInvite = "GroupMemberJoin",--群成员增加，被邀请--┐---→统一处理
    GroupMemberPass = "GroupMemberJoin",--群成员增加，申请的----┘
    GroupMessage = "Message",--群消息-------┐---→统一处理
    PrivateMessage = "Message",--私聊消息---┘
    GroupFileUpload = "GroupFileUpload",--有人上传文件
    -- GroupRecall = "",--撤回
    -- FriendRecall = "",
    -- Poke = "",--戳一戳
    -- LuckyKing = "",--群红包运气王
    -- Honor = "",--群成员荣誉变更
    TcpServer = "ReceiveTcp",--收到tcp客户端发来的数据
    MQTT = "MQTT",--处理MQTT连接逻辑
}

--每个虚拟机应该加载的事件（不包括group）
local envEvents = {
    main = {
        "AppEnable",
        --"FriendAdd",
        --"FriendAddRequest",
        "GroupAddRequest",
        "GroupAddInvite",
    },
    private = {
        "PrivateMessage",
        --"FriendRecall",
    }
}

local function regEvents(i,j)
    local f
    local _,info = pcall(function() f = require(j) end)
    if f then
        sys.tiggerRegister(i,f)
        Log.Debug(StateName,LuaEnvName.."注册事件"..i..","..j)
    else
        Log.Warn(StateName,LuaEnvName.."注册事件失败"..i..","..(info or "错误信息为空"))
    end
end

if envEvents[LuaEnvName] then
    for i=1,#envEvents[LuaEnvName] do
        regEvents(envEvents[LuaEnvName][i],events[envEvents[LuaEnvName][i]])
    end
else
    for i,j in pairs(events) do
        regEvents(i,j)
    end
end
