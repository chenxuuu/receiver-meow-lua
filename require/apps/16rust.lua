return {--测试代码
check = function (data)
    return data.msg:find("#rust") == 1
end,
run = function (data,sendMessage)
    sendMessage(cq.code.at(data.qq).."代码已提交，正在运行~")
    sys.taskInit(function ()
        local post = {
            version= "stable",
            optimize= "0",
            code=data.msg:sub(string.len("#rust")+1),
            edition= "2018",
        }
        if not post.code:find("fn main") then
            post.code = "fn main() {\r\n"..post.code.."\n}\n"
        end
        local html = asyncHttpPost("https://play.rust-lang.org/evaluate.json",
        jsonEncode(post),30000,nil,"application/json")
        local d,result,error = jsonDecode(html)
        if result then
            if d.error then
                sendMessage(cq.code.at(data.qq).."报错了qwq\r\n"..tostring(d.error))
            else
                sendMessage(cq.code.at(data.qq).."\r\n"..tostring(d.result))
            end
        else
            sendMessage(cq.code.at(data.qq).."代码服务器运行报错qwq")
        end
    end)
    return true
end,
explain = function ()
    return "☢️#rust运行rust代码"
end
}


