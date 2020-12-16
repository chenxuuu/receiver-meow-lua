--插件启动后调用的文件
--目前仅用来注册各种开机后会运行的东西
--并且当前文件的功能，仅在账号为chenxu自己的测试qq下运行

return function ()
    --防止多次启动
    if AppFirstStart then return end
    AppFirstStart = true

    --仅限作者的机器人号用这个功能
    if cq.loginInfo().qq ~= 751323264 and cq.loginInfo().qq ~= 3617883457 then return end

    --服务器空间定期检查任务，十分钟一次
    Log.Debug(StateName,"加载服务器空间定期检查任务")
    sys.timerLoopStart(function ()
        Log.Debug(StateName,"执行服务器空间定期检查任务")
        local free = Utils.GetHardDiskFreeSpace("D")
        if free < 1024 * 10 then--空间小于10G
            cq.sendGroupMsg(567145439,
            cq.code.at(961726194)..
            "你的小垃圾服务器空间只有"..tostring(Utils.GetHardDiskFreeSpace("D")).."M空间了知道吗？快去清理")
        end
    end,600 * 1000)

    --mc服务器定时重启
    Log.Debug(StateName,"加载mc服务器定时重启任务")
    sys.taskInit(function ()
        while true do
            local delay
            local time = os.date("*t")
            local next = os.date("*t",os.time())
            if time.hour >=3 then
                next = os.date("*t",os.time()+3600*24)
                next.hour = 3
                next.min = 0
                next.sec = 0
                delay = os.time(next) - os.time()
            else
                next.hour = 3
                next.min = 0
                next.sec = 0
                delay = os.time(next) - os.time()
            end
            Log.Debug(StateName,"mc自动重启，延时"..delay.."秒")
            sys.wait(delay * 1000)
            Log.Debug(StateName,"mc自动重启，开始执行")
            if Utils.GetHardDiskFreeSpace("D") > 1024 * 10 then
                cq.sendGroupMsg(241464054,
                    "一分钟后，将自动进行服务器例行重启与资源世界回档，请注意自己身上的物品")
                TcpServer.Send("一分钟后，将自动进行服务器例行重启与资源世界回档，请注意自己身上的物品")
                sys.wait(60000)
                TcpServer.Send("cmdstop")
                sys.wait(3600*1000)
                TcpServer.Send("cmdworld create mine")
            end
        end
    end)
end
