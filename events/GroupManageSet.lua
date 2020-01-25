return function (data)
    CQApi:SendGroupMessage(data.group,"群成员"..Utils.CQCode_At(data.qq).."成为了狗管理！")
end
