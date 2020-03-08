return function (data)
    if data.group == 261037783 then
        CQApi:SetGroupMemberVisitingCard(data.group,data.qq,"可能是单推")
        return
    end
    CQApi:SetGroupMemberVisitingCard(data.group,data.qq,"没有名字的笨蛋")
    if data.group == 241464054 then
        CQApi:SendGroupMessage(241464054,Utils.CQCode_At(data.qq)..
        "\r\n欢迎加入，请在群里发“绑定 自己的玩家id”来绑定账号，以便管理员审核该id的申请")
    end
end
