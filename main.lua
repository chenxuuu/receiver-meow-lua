--导入需要的命名空间
import("com.papapoi.ReceiverMeow","Native.Csharp.App.Common")
--Utils接口
import("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv")
--HttpTool和HttpWebClient
import("Native.Csharp.Tool","Native.Csharp.Tool.Http")

import("System.Text")

--简化某些函数的语法
CQLog = AppData.CQLog
CQApi = AppData.CQApi
CQLog:Debug("lua插件","加载新虚拟机"..name)

--重写print函数，重定向到debug接口输出
function print(...)
    local r = {}
    for i=1,select('#', ...) do
        table.insert(r,tostring(select(i, ...)))
    end
    if #r == 0 then
        table.insert(r,"nil")
    end
    CQLog:Debug("lua插件("..name..")",table.concat(r,"  "))
end

--加上需要require的路径
local rootPath = Utils.GetAsciiHex(CQApi.AppDirectory)
rootPath = rootPath:gsub("[%s%p]", ""):upper()
rootPath = rootPath:gsub("%x%x", function(c)
                                    return string.char(tonumber(c, 16))
                                end)
package.path = package.path..
";"..rootPath.."lua/require/?.lua"

--加载字符串工具包
require("strings")

--重载几个可能影响中文目录的函数
local oldrequire = require
require = function (s)
    local s = apiGetAsciiHex(s):fromHex()
    return oldrequire(s)
end
local oldloadfile = loadfile
loadfile = function (s)
    local s = apiGetAsciiHex(s):fromHex()
    return oldloadfile(s)
end

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

--唯一id
local idTemp = 0
function getId()
    idTemp = idTemp + 1--没必要判断是否溢出，溢出自动变成负数
    return idTemp
end

--封装一个异步的http get接口
function asyncHttpGet(url,para,timeout,cookie)
    local delayFlag = "http_get_"..os.time()..getId()--基本没有重复可能性的唯一标志
    sys.async("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv.Utils.HttpGet",
            {url or "",para or "",timeout or 5000,cookie or ""},
    function (r,d)
        sys.publish(delayFlag,r,d)
    end)
    return sys.waitUntil(delayFlag, timeout)
end

--封装一个异步的http post接口
function asyncHttpPost(url,para,timeout,cookie,contentType)
    local delayFlag = "http_post_"..os.time()..getId()--基本没有重复可能性的唯一标志
    sys.async("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv.Utils.HttpPost",
            {url or "",para or "",timeout or 5000,cookie or "",
                contentType or "application/x-www-form-urlencoded"},
    function (r,d)
        sys.publish(delayFlag,r,d)
    end)
    return sys.waitUntil(delayFlag, timeout)
end

--加强随机数随机性
math.randomseed(tostring(os.time()):reverse():sub(1, 6))

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

sys.tiggerRegister("groupMessage",function (data)
    -- AppData.CQLog:Debug("Lua收到消息",data.msg)
    -- sys.taskInit(function ()
    --     sys.wait(5000)
    --     AppData.CQApi:SendGroupMessage(data.group,"收到消息："..data.msg)
    -- end)
end)
