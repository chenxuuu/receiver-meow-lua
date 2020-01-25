return function (data)
    if data.group == 261037783 then
        CQApi:SetGroupMemberVisitingCard(data.group,data.qq,"可能是单推")
        return
    end
    CQApi:SetGroupMemberVisitingCard(data.group,data.qq,"没有名字的笨蛋")
end
