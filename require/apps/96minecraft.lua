local mcApi = require("minecraft")
local function apiTcpSend(msg,cmd)
    if cmd then TcpServer.Send("cmd"..msg) return end
    msg = msg:gsub("%[CQ:.-%]","[特殊]"):gsub("\r","")
    TcpServer.Send(msg)
end

local function sendMessage(g,m)
    if g==241464054 then
        apiTcpSend("[群消息][接待喵]"..m)
    end
    CQApi:SendGroupMessage(g,m)
end

import('System')
local function cqSetGroupBanSpeak(g,q,t)
    local time = TimeSpan(0,0,t)
    CQApi:SetGroupMemberBanSpeak(g,q,time)
end

local function mc(msg,qq,group)
    if group == 241464054 then --玩家群
        local player = XmlApi.Get("bindQq",tostring(qq))
        local step = XmlApi.Get("bindStep",tostring(qq))
        apiTcpSend("[群消息]["..(player == "" and "无名氏"..tostring(qq) or player).."]"..msg)

        if msg:find("绑定") == 1 and player == "" then--绑定命令
            local player = msg:match("([a-zA-Z0-9_]+)")
            player = XmlApi.Row("bindQq",player) ~= "" and "" or player
            if player == "" then
                sendMessage(241464054,Utils.CQCode_At(qq).."id重复，换个吧")
            elseif player then

                XmlApi.Set("bindQq",tostring(qq),player)
                XmlApi.Set("bindStep",tostring(qq),"waiting")
                sendMessage(241464054,Utils.CQCode_At(qq).."绑定"..player.."成功！\r\n"..
                                    "请耐心等待管理员审核白名单申请哟~\r\n"..
                                    "如未申请请打开此链接：https://www.chenxublog.com/scf\r\n"..
                                    "如果过去24小时仍未被审核，请回复“催促审核”来进行催促")

                sendMessage(567145439, "接待喵糖拌管理：\r\n玩家"..player.."\r\n已成功绑定"..
                                    "\r\n下面是他的白名单申请内容")
                sys.taskInit(function ()
                    local form = mcApi.readForm(player)..
                    "\r\n如果符合要求，请回复“通过"..tostring(qq).."”来给予白名单"..
                    "\r\n如果不符合要求，请回复“不通过"..tostring(qq).."空格原因”来给打回去重填"
                    while form:len() > 0 do
                        sendMessage(567145439,form:sub(1,9000))
                        form = form:sub(9001)
                    end
                end)
            else
                sendMessage(241464054,Utils.CQCode_At(qq).."id不符合要求，仅允许数字、字母、下划线")
            end
            return true
        elseif player == "" then--没绑定id
            step = tonumber(step) or 0
            if step >= 3 then
                cqSetGroupBanSpeak(241464054,qq,10*60)
                sendMessage(241464054,Utils.CQCode_At(qq).."你没有绑定游戏id，请在十分钟后，发送“绑定”加上id，来绑定自己的id")
            else
                sendMessage(241464054,Utils.CQCode_At(qq).."你没有绑定游戏id，请发送“绑定”加上id，来绑定自己的id")
                XmlApi.Set("bindStep",tostring(qq),tostring(step+1))
            end
            return true
        elseif msg:find("查询.+") == 1 or msg == "查询" then--查询某玩家在线信息
            local p = msg == "查询" and player or msg:match("查询(%w+)")
            local data = mcApi.getData(p)
            if data.time == 0 then
                local tempqq = msg:match("%d+")
                if tempqq then
                    p = XmlApi.Get("bindQq",tostring(tempqq))
                    data = mcApi.getData(p)
                end
                if data.time == 0 then
                    sendMessage(241464054,Utils.CQCode_At(qq).."未查询到该玩家信息")
                    return true
                end
            end
            if data.last == "online" then
                data.time = data.time + os.time() - data.ltime
            end
            sendMessage(241464054,Utils.CQCode_At(qq)..
                p.."\r\n"..
                "当前状态："..(data.last == "online" and "在线" or "离线").."\r\n"..
                "累计在线："..string.format("%d小时%d分钟", math.floor(data.time/(60*60)), math.floor(data.time/60)%60)..
                (data.last == "online" and "" or "\r\n上次在线时间："..os.date("%Y年%m月%d日",data.ltime))..
                "\r\n在线奖励余额："..data.money.."\r\n在线时群里发“领取+数量”可取出")
            return true
        elseif msg:find("领取%d+") == 1 then
            local sum = msg:match("领取(%d+)")
            if not sum then return end
            sum = tonumber(sum)
            local data = mcApi.getData(player)
            if data.last == "offline" then--不在线
                sendMessage(241464054,Utils.CQCode_At(qq).."你绑定的id为"..player..
                    "，请上线后再操作")
                return true
            elseif data.money < sum then--余额不够
                sendMessage(241464054,Utils.CQCode_At(qq).."你余额只有"..data.money)
                return true
            else
                apiTcpSend("eco add "..player.." "..sum,true)
                data.money = data.money - sum
                local d,r = jsonEncode(data)
                XmlApi.Set("minecraftData",player,d)
                sendMessage(241464054,Utils.CQCode_At(qq).."领取成功，还剩"..data.money)
                return true
            end
        elseif msg == "在线" then
            local onlineData = XmlApi.Get("minecraftData","[online]")
            local online = {}--存储在线所有人id
            if onlineData ~= "" then
                online = onlineData:split(",")
            end
            sendMessage(241464054,Utils.CQCode_At(qq).."当前在线人数"..tostring(#online).."人："..
                                (onlineData=="" and "" or "\r\n"..onlineData))
            return true
        elseif msg == "激活" then--激活
            if step == "pass" or step == "done" then
                local data = mcApi.getData(player)
                if data.last == "offline" then
                    sendMessage(241464054,Utils.CQCode_At(qq).."你绑定的id为"..player..
                        "，请上线后再操作")
                else
                    sendMessage(241464054,Utils.CQCode_At(qq).."已给予玩家"..player.."权限")
                    apiTcpSend("lp user "..player.." permission set group.whitelist",true)
                    apiTcpSend("lp user "..player.." permission unset group.default",true)
                    if step == "pass" then
                        XmlApi.Set("bindStep",tostring(qq),"done")
                    end
                end
            elseif step == "waiting" then
                sendMessage(241464054,Utils.CQCode_At(qq).."你还没通过审核呢")
            end
            return true
        elseif msg == "催促审核" and step == "waiting" then--催促审核
            sendMessage(567145439, "接待喵糖拌管理：\r\n玩家"..player.."\r\n仅行了催促操作"..
                                "\r\n请及时检查该玩家是否已经提交白名单申请")
            sendMessage(241464054,Utils.CQCode_At(qq).."催促成功")

            sys.taskInit(function ()
                local form = mcApi.readForm(player)..
                "\r\n如果符合要求，请回复“通过"..tostring(qq).."”来给予白名单"..
                "\r\n如果不符合要求，请回复“不通过"..tostring(qq).."空格原因”来给打回去重填"
                while form:len() > 0 do
                    sendMessage(567145439,form:sub(1,9000))
                    form = form:sub(9001)
                end
            end)
            return true
        elseif msg:find("重置密码") == 1 and (step == "pass" or step == "done") then
            local password = getRandomString(6)
            apiTcpSend("flexiblelogin resetpw "..player.." "..password,true)
            sendMessage(241464054,Utils.CQCode_At(qq).."已重置，请看私聊")
            CQApi:SendPrivateMessage(qq,"密码重置成功，初始密码为："..password.."\r\n"..
            "请在登陆后使用命令/changepassword [密码] [确认密码]来修改密码")
            return true
        -- elseif cqGetMemberInfo(group,qq,true).Card ~= player then
        --     --群备注和实际名字不匹配
        --     CQApi:SetGroupMemberVisitingCard(group, qq, player)
        end
    elseif group == 567145439 then --管理群
        if msg:find("命令") == 1 then
            local cmd = msg:sub(("命令"):len()+1)
            apiTcpSend(cmd,true)
            sendMessage(group,Utils.CQCode_At(qq).."命令"..cmd.."已执行")
            return true
        elseif msg:find("删除 *%d+") == 1 then
            local qq = msg:match("删除 *(%d+)")
            local player = XmlApi.Get("bindQq",tostring(qq))
            if player ~= "" then
                XmlApi.Delete("bindStep",tostring(qq))
                XmlApi.Delete("bindQq",tostring(qq))
                apiTcpSend("lp user "..player.." permission set group.default",true)
                apiTcpSend("lp user "..player.." permission unset group.whitelist",true)
                sendMessage(567145439,"已删除玩家"..player.."的绑定信息")
            else
                sendMessage(567145439,"没找到这个玩家")
            end
            return true
        elseif msg:find("通过 *%d+") == 1 then
            local qq = msg:match("通过 *(%d+)")
            local player = XmlApi.Get("bindQq",tostring(qq))
            local step = XmlApi.Get("bindStep",tostring(qq))
            if player == "" then
                sendMessage(567145439,"该qq没有进行过绑定")
            elseif step ~= "waiting" then
                sendMessage(567145439,"玩家"..player.."不在待审核名单中")
            else
                XmlApi.Set("bindStep",tostring(qq),"pass")
                sendMessage(567145439,"已通过"..player.."的白名单申请")
                sendMessage(241464054,Utils.CQCode_At(tonumber(qq)).."你的白名单申请已经通过了哟~\r\n"..
                            "游戏上线后，在群里发送“激活”即可获取权限~\r\n"..
                            "你的id："..player)
                sys.taskInit(function ()--标记为已读取
                    mcApi.markForm(player)
                end)
            end
            return true
        elseif msg:find("不通过 *%d+ .+") == 1 then
            local qq,reason = msg:match("不通过 *(%d+) (.+)")
            local player = XmlApi.Get("bindQq",tostring(qq))
            local step = XmlApi.Get("bindStep",tostring(qq))
            if player == "" then
                sendMessage(567145439,"该qq没有进行过绑定")
            elseif step ~= "waiting" then
                sendMessage(567145439,"玩家"..player.."不在待审核名单中")
            else
                sendMessage(567145439,"已打回"..player.."的白名单申请，原因："..reason)
                sendMessage(241464054,Utils.CQCode_At(tonumber(qq)).."你的白名单申请并没有通过。\r\n"..
                            "原因："..reason.."\r\n"..
                            "请按照原因重新填写白名单：https://www.chenxublog.com/scf\r\n"..
                            "你的id："..player.."\r\n如果重新填完了，请发送“催促审核”来让管理重审")
                sys.taskInit(function ()--标记为已读取
                    mcApi.markForm(player)
                end)
            end
            return true
        elseif msg:find("查申请 *.+") == 1 then
            local player = msg:match("查申请 *(.+)")
            sys.taskInit(function ()--标记为已读取
                local form = mcApi.readForm(player)
                while form:len() > 0 do
                    sendMessage(567145439,form:sub(1,9000))
                    form = form:sub(9001)
                end
            end)
            return true
        elseif msg == "清空在线" then
            mcApi.onlineClear()
            sendMessage(567145439,Utils.CQCode_At(qq).."已清空所有在线信息")
            return true
        end
    end
end

return {--mc群管理逻辑
check = function (data)
    return data.group == 241464054 or data.group == 567145439
end,
run = function (data,sendMessage)
    return mc(data.msg,data.qq,data.group)
end
}
