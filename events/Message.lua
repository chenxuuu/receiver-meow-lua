--自动读取apps目录，加载所有功能
local apps = {}
import("System.IO")
local AppList = Directory.GetFiles(Utils.Path.."lua/require/apps/")

--按文件名排序
local tempList = {}
for i=0,AppList.Length-1 do
    local app = AppList[i]:match("/([^/]-)%.lua")
    if app then
        table.insert(tempList,app)
    end
end
table.sort(tempList)--排序

--加载每个文件
for i=1,#tempList do
    local t
    local _,info = pcall(function() t = require("apps."..tempList[i]) end)
    if t then
        table.insert(apps,t)
        Log.Debug(StateName,LuaEnvName.."加载app："..tempList[i])
    end
end
tempList = nil--释放临时table

return function (data)
    --封装一个发送消息接口
    --自动判断群聊与私聊
    local function sendMessage(s)
        if LuaEnvName ~= "private" then
            cq.sendGroupMsg(data.group,s)
        else
            cq.sendPrivateMsg(data.qq,s)
        end
    end

    --帮助列表每页最多显示数量
    local maxEachPage = 8
    --匹配是否需要获取帮助
    if data.msg:lower():find("help *%d*") == 1 or data.msg:find("帮助 *%d*") == 1 or data.msg:find("菜单 *%d*") == 1 then
        local page = data.msg:lower():match("help *(%d+)") or data.msg:match("帮助 *(%d+)") or
                    data.msg:match("菜单 *(%d+)") or 1
        page = tonumber(page)--获取页码
        local maxPage = math.ceil(#apps/maxEachPage)
        page = page > maxPage and maxPage or page

        --开始与结束序号
        local fromApp = (page - 1) * maxEachPage + 1
        local endApp = fromApp + maxEachPage - 1
        endApp = endApp > #apps and #apps or endApp

        local allApp = {}
        for i=fromApp,endApp do
            local appExplain = apps[i].explain and apps[i].explain()
            if appExplain then
                table.insert(allApp, appExplain)
            end
        end
        sendMessage("📃命令帮助("..tostring(page).."/"..tostring(maxPage).."页)\r\n"..
        table.concat(allApp, "\r\n").."\r\n"..
        "📄开源代码：\r\nhttps://www.chenxublog.com/qqrobot")
        return
    end

    --遍历所有功能
    for i=1,#apps do
        if apps[i].check and apps[i].check(data) then
            if apps[i].run(data,sendMessage) then
                break
            end
        end
    end
end

