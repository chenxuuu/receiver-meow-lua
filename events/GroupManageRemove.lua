return function (data)
    CQApi:SendGroupMessage(data.group,"群成员"..Utils.CQCode_At(data.qq).."变回了人类！")
end
