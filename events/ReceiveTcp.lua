--[[
处理收到的tcp消息

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

local mc = require("minecraft")

local solve = {
    l = function (msg)
        mc.onlineAdd(msg)
        CQApi:SendGroupMessage(241464054,msg.."上线了")
        if XmlApi.Row("bindQq",msg) == "" then--自动撤销没在群里的人的白名单
            TcpServer.Send("cmdlp user "..msg.." permission set group.default")
            TcpServer.Send("cmdlp user "..msg.." permission unset group.whitelist")
        end
    end,
    d = function (msg)
        mc.onlineDel(msg)
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
        mc.onlineClear()
        TcpServer.Send("cmdworld create mine")
    end,
}


return function (message)
    local messageType = message:sub(1,1)
    if solve[messageType] then
        solve[messageType](message:sub(2))
    end
end
