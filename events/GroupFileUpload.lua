return function (data)
    cq.sendGroupMsg(data.group,"用户"..cq.code.at(data.qq).."上传了文件\r\n"..
    data.file:ToString())
end
