--不可以色色！
--代码逻辑来源：https://github.com/RimoChan/yinglish

--分词成table
local function jb(s)
    local t = {}
    local r = Utils.Jieba(s)
    for i = 0, r.Count-1 do
        table.insert(t,r[i])
    end
    return t
end


local convert = {
    function (s) if s == "," or s == "，" then return "……" end end,
    function (s) if s == "!" or s == "！" then return "❤" end end,
    function (s) if #s > 3 and math.random() < 0.5 then return s:sub(1,3).."……"..s:sub(4) end end,
    function (s) return s end,
}


return function (s)
    local t = jb(s)
    
    local sese = {}
    for i=1,#t do
        for j=1,#convert do
            local cr = convert[j](t[i],n)
            if cr then
                table.insert(sese,cr)
                break
            end
        end
    end
    if math.random() < 0.5 then
        table.insert(sese,"❤")
    end
    return table.concat(sese)
end
