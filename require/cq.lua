--CQ接口处理库
local cq = {}

local function hg(p,t)
    local r = Http.Send(p,(jsonEncode(t)))
    Log.Debug("HTTP接口返回",r)
    return jsonDecode(r)
end

--发送私聊信息
function cq.sendPrivateMsg(qq,msg,autoEscape)
    local r = hg("send_private_msg",{
        user_id = qq,
        message = msg,
        auto_escape = autoEscape and true or false
    })
    if r.status == "ok" and r.data.message_id then
        return r.data.message_id
    else
        Log.Warn("发送失败，报错信息：",r.wording)
    end
end

--发送群信息
function cq.sendGroupMsg(group,msg,autoEscape)
    local r
    if type(group) == "string" then
        r =  hg("send_guild_channel_msg",{
            guild_id = group:match("c(.+),.+"),
            channel_id = group:match("c.+,(.+)"),
            message = msg,
        })
    else
        r =  hg("send_group_msg",{
            group_id = group,
            message = msg,
            auto_escape = autoEscape and true or false
        })
    end
    if r.status == "ok" and r.data.message_id then
        return r.data.message_id
    else
        Log.Warn("发送失败，报错信息：",r.wording)
    end
end

--撤回信息
function cq.deleteMsg(id)
    return hg("delete_msg",{
        message_id = id
    }).status
end

--给好友点赞
function cq.like(qq,times)
    return hg("send_like",{
        user_id = qq,
        times = times
    }).status
end

--踢人
function cq.groupKick(group,qq,rejectAdd)
    return hg("set_group_kick",{
        group_id = group,
        user_id = qq,
        reject_add_request = rejectAdd and true or false
    }).status
end

--禁言某qq
function cq.groupBan(group,qq,duration)
    return hg("set_group_ban",{
        group_id = group,
        user_id = qq,
        duration = duration
    }).status
end

--禁言匿名
function cq.groupBanAnonymous(group,flag,duration)
    return hg("set_group_anonymous_ban",{
        group_id = group,
        anonymous = flag,
        duration = duration
    }).status
end

--全员禁言
function cq.groupBanAll(group,enable)
    return hg("set_group_whole_ban",{
        group_id = group,
        enable = enable and true or false
    }).status
end

--设置管理员
function cq.groupAdmin(group,qq,enable)
    return hg("set_group_admin",{
        group_id = group,
        user_id = qq,
        enable = enable and true or false
    }).status
end

--设置群是否可匿名
function cq.groupAnonymous(group,enable)
    return hg("set_group_anonymous",{
        group_id = group,
        enable = enable and true or false
    }).status
end

--修改某人群备注（群名片）
function cq.groupCard(group,qq,card)
    return hg("set_group_card",{
        group_id = group,
        user_id = qq,
        card = card
    }).status
end

--修改群名
function cq.groupName(group,name)
    return hg("set_group_name",{
        group_id = group,
        group_name = name,
    }).status
end

--退群
function cq.groupLeave(group,dismiss)
    return hg("set_group_leave",{
        group_id = group,
        is_dismiss = dismiss and true or false--解散
    }).status
end

--设置群组专属头衔
function cq.groupTitle(group,qq,name,duration)
    return hg("set_group_special_title",{
        group_id = group,
        user_id = qq,
        special_title = name,
        duration = duration or -1
    }).status
end

--处理加好友请求
function cq.friendAddRequest(tag,approve,name)
    return hg("set_friend_add_request",{
        flag = tag,
        approve = approve and true or false,
        remark = name or ""
    }).status
end

--处理加群请求／邀请
function cq.groupAddRequest(tag,rtype,approve,reason)
    return hg("set_group_add_request",{
        flag = tag,
        sub_type = rtype,
        approve = approve and true or false,
        reason = reason or ""
    }).status
end

--获取登录号信息，返回包含qq和nickname的table
function cq.loginInfo()
    local d = hg("get_login_info",{}).data
    return {
        qq = d.user_id,
        nickname = d.nickname
    }
end

--获取陌生人信息
function cq.qqInfo(qq,refresh)
    return hg("get_stranger_info",{
        user_id = qq,
        no_cache = refresh and true or false
    }).data
end

--获取好友列表
function cq.friendList()
    return hg("get_friend_list",{}).data
end

--获取群信息
function cq.groupInfo(group,refresh)
    return hg("get_group_info",{
        group_id = group,
        no_cache = refresh and true or false
    }).data
end

--获取群列表
function cq.groupList()
    return hg("get_group_list",{}).data
end

--获取群成员信息
function cq.groupMemberInfo(group,qq,refresh)
    return hg("get_group_member_info",{
        group_id = group,
        user_id = qq,
        no_cache = refresh and true or false
    }).data
end

--获取群成员列表
function cq.groupMemberList(group)
    return hg("get_group_member_list",{
        group_id = group,
    }).data
end

--获取群荣誉信息
--要获取的群荣誉类型，可传入 talkative performer legend strong_newbie emotion，或传入 all 获取所有数据
function cq.groupHonor(group,t)
    return hg("get_group_honor_info",{
        group_id = group,
        ["type"] = t
    }).data
end

--获取 Cookies
function cq.cookie(domain)
    return hg("get_cookies",{
        domain = domain,
    }).data.cookies
end

--获取 CSRF Token
function cq.csrfToken()
    return hg("get_csrf_token",{}).data.token
end

--获取 QQ 相关接口凭证
function cq.credentials(domain)
    return hg("get_credentials",{
        domain = domain,
    }).data
end

--获取语音文件路径
function cq.record(file,format)
    return hg("get_record",{
        file = file,
        out_format = format
    }).data.file
end

--获取图片文件路径
function cq.record(file)
    return hg("get_image",{
        file = file,
    }).data.file
end

--获取运行状态
function cq.status()
    return hg("get_status",{}).data
end

--获取go cqhttp版本信息
function cq.info()
    return hg("get_version_info",{}).data
end


--从消息中过滤出图片文件名
function cq.getImage(msg)
    return msg:match("%[CQ:image,.*file=(.-%.image),")
end

--图片 OCR
function cq.ocr(img)
    if img:find("%[") then--说明没转换
        img = cq.getImage(img)
    end
    if not img then return end
    local r = hg("ocr_image",{
        image = img,
    }).data
    if not r then return end
    local text = {}
    for i,j in pairs(r.texts) do
        if j.confidence > 50 then
            table.insert(text,j.text)
        end
    end
    return table.concat(text,"\n")
end

--cq码
cq.code = {}

--QQ 表情
--id表对应见https://github.com/richardchien/coolq-http-api/wiki/%E8%A1%A8%E6%83%85-CQ-%E7%A0%81-ID-%E8%A1%A8
function cq.code.face(id)
    return "[CQ:face,id="..tostring(id).."]"
end

--发图片
--flash表示闪照
--文件参数例子
--绝对路径，例如 file:///C:\\Users\Richard\Pictures\1.png，格式使用 file URI
--网络 URL，例如 http://i1.piimg.com/567571/fdd6e7b6d93f1ef0.jpg
--Base64 编码，例如 base64://iVBORw0KGgoAAAANSUhEUgAAA...
function cq.code.image(file,flash)
    return "[CQ:image,file="..CQ.Encode(file)..(flash and ",type=flash" or "").."]"
end

--发语音
--文件参数例子
--绝对路径，例如 file:///C:\\Users\1.amr，格式使用 file URI
--网络 URL，例如 http://i1.piimg.com/567571/1.amr
--Base64 编码，例如 base64://iVBORw0KGgoAAAANSUhEUgAAA...
function cq.code.record(file)
    return "[CQ:record,file="..CQ.Encode(file).."]"
end

--发视频
--文件参数例子
--绝对路径，例如 file:///C:\\Users\1.amr，格式使用 file URI
--网络 URL，例如 http://i1.piimg.com/567571/1.amr
--Base64 编码，例如 base64://iVBORw0KGgoAAAANSUhEUgAAA...
function cq.code.video(file)
    return "[CQ:video,file="..CQ.Encode(file).."]"
end

--at某人 all表示全体
function cq.code.at(qq)
    return "[CQ:at,qq="..tostring(qq).."]"
end

--魔法表情猜拳
function cq.code.rps()
    return "[CQ:rps]"
end

--魔法表情骰子
function cq.code.dice()
    return "[CQ:dice]"
end

--窗口抖动（现在是最简的戳一戳）
function cq.code.shake()
    return "[CQ:shake]"
end

--戳一戳
--类型与id见https://git.io/JLGOk
function cq.code.poke(t,id)
    return "[CQ:poke,type="..t..",id="..id.."]"
end

--匿名发消息标志
function cq.code.anonymous()
    return "[CQ:anonymous]"
end

--链接分享
function cq.code.share(url,title,content,image)
    return "[CQ:share,url="..CQ.Encode(url)..",title="..CQ.Encode(title)..
    ",content="..CQ.Encode(content)..",image="..CQ.Encode(image).."]"
end

--好友/群名片
--t可选group、qq
function cq.code.contact(t,id)
    return "[CQ:contact,type="..t..",id="..id.."]"
end

--位置
function cq.code.location(lat,lon,title,content)
    return "[CQ:location,lat="..lat..",lon="..lon..",title="..CQ.Encode(title)..
    ",content="..CQ.Encode(content).."]"
end

--音乐简单卡片
--t可选qq 163 xm （QQ 音乐、网易云音乐、虾米音乐）
function cq.code.music(t,id)
    return "[CQ:music,type="..t..",id="..id.."]"
end

--音乐复杂卡片
function cq.code.musicFull(url,audio,title,content,image)
    return "[CQ:music,type=custom,url="..CQ.Encode(url)..",audio="..CQ.Encode(audio)..
    ",title="..CQ.Encode(title)..",content="..CQ.Encode(content)..",image="..CQ.Encode(image).."]"
end

--回复
function cq.code.reply(id)
    return "[CQ:reply,id="..id.."]"
end

--xml消息
function cq.code.xml(xml)
    return "[CQ:xml,data="..CQ.Encode(xml).."]"
end

--json消息
function cq.code.xml(json)
    return "[CQ:json,data="..CQ.Encode(json).."]"
end

return cq
