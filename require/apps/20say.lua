--- 判断文件是否存在
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

local pathHead = Utils.Path.."lua/require/say/"

local function qsay(q,n,s)
    --检查和获取头像
    local head_path = pathHead..q..".jpg"
    if not io.exists(head_path) then
        Utils.HttpDownload("https://q1.qlogo.cn/g","b=qq&nk="..q.."&s=100",10000,"",head_path)
    end
    --背景布
    local height = 159
    local tw = math.floor(Utils.GetTextWidth(s,pathHead.."yh.ttf",37))--微软雅黑字体，请自行下载
    local width = tw+166+70
    local pic = Utils.GetBitmap(width,height)
    Utils.PutBlock(pic,0,0,width,height,248, 246, 244)
    --放头像
    Utils.SetImage(pic,6,6,head_path,62,62)
    Utils.SetImage(pic,0,0,pathHead.."head_cover.png",76,77)
    --气泡开头
    Utils.SetImage(pic,77,42,pathHead.."s.png",35,92)
    --气泡中间
    local count = 0
    local lastx = 111
    while count < tw do
        if tw - count >= 37 then
            Utils.SetImage(pic,lastx,42,pathHead.."m.png",37,92)
            count = count + 37
            lastx = lastx + 37
        else
            local w = tw - count
            Utils.SetImage(pic,lastx - 37 + w,42,pathHead.."m.png",37,92)
            count = count + w
            lastx = lastx + w
        end
    end
    --气泡结尾
    Utils.SetImage(pic,lastx,42,pathHead.."e.png",25,92)
    --字
    Utils.PutText(pic,111,67,s,pathHead.."yh.ttf",37,0,0,0)
    --名
    Utils.PutText(pic,96,13,n,pathHead.."yh.ttf",24,124, 123, 122)
    local file = Utils.ImageBase64(pic):match("base64,(.+)")
    return cq.code.image("base64://"..file)
end

local function getName(group,qq)
    local info = cq.groupMemberInfo(group,qq)
    return info.card ~= "" and info.card or info.nickname
end

return {--
check = function (data)
    return data.msg:find("%[CQ:at,qq=%d+%] */.+") == 1
end,
run = function (data,sendMessage)
    local q,s = data.msg:match("%[CQ:at,qq=(%d+)%] */(.+)")
    if q and s then
        sendMessage(qsay(q,getName(data.group,tonumber(q)),s))
        return true
    end
end,
explain = function ()
    return "🗨at/话，生成聊天截图"
end
}
