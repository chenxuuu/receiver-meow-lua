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
CQLog:Debug("lua插件","加载虚拟机"..name)

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
local rootPath = apiGetAsciiHex(apiGetPath())
rootPath = rootPath:gsub("[%s%p]", ""):upper()
rootPath = rootPath:gsub("%x%x", function(c)
                                    return string.char(tonumber(c, 16))
                                end)
package.path = package.path..
";"..rootPath.."data/app/com.papapoi.ReceiverMeow/lua/require/?.lua"

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





--测试http
local a = HttpWebClient.Get("https://qq.papapoi.com/delay?t=0",true)
local t = {}
for i=0,a.Length-1 do
    table.insert(t,string.char(a[i]))
end
print(table.concat(t))

sys.async("Native.Csharp.Tool","Native.Csharp.Tool.Http.HttpWebClient.Get",
{"https://qq.papapoi.com/delay?t=0",true},
function (r,d)
    print("cb",r,d)
end)


sys.tiggerRegister("groupMessage",function (data)
    -- AppData.CQLog:Debug("Lua收到消息",data.msg)
    -- sys.taskInit(function ()
    --     sys.wait(5000)
    --     AppData.CQApi:SendGroupMessage(data.group,"收到消息："..data.msg)
    -- end)
end)
