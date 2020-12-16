return function (data)
    if data.group == 261037783 then
        cq.groupCard(data.group,data.qq,"可能是单推")
        return
    end
    cq.groupCard(data.group,data.qq,"没有名字的笨蛋")
    if data.group == 241464054 then
        cq.sendGroupMsg(241464054,cq.code.at(data.qq)..
        "\r\n欢迎加入，请在群里发“绑定 自己的玩家id”来绑定账号，以便管理员审核该id的申请")
    end
end
