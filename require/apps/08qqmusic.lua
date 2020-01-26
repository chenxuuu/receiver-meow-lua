local function qqmusic(message)
    if message:find("点歌") == 1 then
        local songID = message:gsub("点歌 *","")
        if not tonumber(songID) then
            local html = asyncHttpGet("https://c.y.qq.com/soso/fcgi-bin/client_search_cp", "?ct=24&qqmusic_ver=1298&new_json=1&remoteplace=txt.yqq.song&searchid=&t=0&aggr=1&cr=1&catZhida=1&lossless=0&flag_qc=0&p=1&n=20&w="..message:gsub("点歌",""):urlEncode())
            local str = html:match("callback%((.+)%)")
            local j,r,e = jsonDecode(str)
            if r and j.data and j.data.song and j.data.song.list and j.data.song.list[1] then
                songID = j.data.song.list[1].id
            else
                return "机器人爆炸了，原因："..e
            end
        end
        if songID then
            return "[CQ:music,type=qq,id="..tostring(songID).."]"
        else
            return "机器人爆炸了，原因：根本没这首歌"
        end
    end
end

return {--点歌
check = function (data)
    return data.msg:find("点歌") == 1
end,
run = function (data,sendMessage)
    sys.taskInit(function()
        sendMessage(qqmusic(data.msg))
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=127932]点歌 加 qq音乐id或歌名"
end
}
