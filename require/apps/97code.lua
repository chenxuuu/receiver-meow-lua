return {--测试代码
check = function (data)
    return data.msg:find("#lua") == 1
end,
run = function (data,sendMessage)
    if data.qq == Utils.setting.AdminQQ then
        local result, info = pcall(function ()
            print = function (...)
                local r = {}
                for i=1,select('#', ...) do
                    table.insert(r,tostring(select(i, ...)))
                end
                if #r == 0 then
                    table.insert(r,"nil")
                end
                sendMessage(table.concat(r,"  "))
            end
            load(Utils.CQDeCode(data.msg:sub(5)))()
        end)
        if result then
            sendMessage(Utils.CQCode_At(data.qq).."成功运行")
        else
            sendMessage(Utils.CQCode_At(data.qq).."运行失败\r\n"..tostring(info))
        end
    else
        sendMessage(Utils.CQCode_At(data.qq).."\r\n"..
            Utils.CQEnCode(Utils.RunSandBox(Utils.CQDeCode(data.msg:sub(5)))))
    end
    return true
end,
explain = function ()
    return "[CQ:emoji,id=9000]#lua运行lua代码"
end
}
