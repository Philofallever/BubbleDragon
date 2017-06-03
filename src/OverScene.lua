local OverScene = class("OverScene",function ()
    local scene = cc.Scene:create()
    return scene
end)

function OverScene.create()
    local scene = OverScene.new()
    scene:addChild(scene:createLayer(),0)
    return scene
end

function OverScene.ctor()
    -- body
end



local function onBackClick()
    local scene = require("MainScene").create()
    cc.Director:getInstance():replaceScene(scene)
end


function OverScene:createLayer()
    cclog(2,"enter OverScene")
    local size = cc.Director:getInstance():getWinSize()
    local layer = cc.Layer:create()
    local bkg = cc.Sprite:create("overbkg.png")
    bkg:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(bkg,0)
    cclog(2,GameManager.failreason)

    local failtip = cc.Label:createWithSystemFont(FAILREASON[GameManager.failreason],"Arial",32)
    failtip:setColor(GRASSGREEN)
    failtip:setPosition(cc.p(size.width/2,size.height/2 + 150 ))
    failtip:setOpacity(0)
    failtip:runAction(cc.Spawn:create(cc.Blink:create(1,3),cc.FadeIn:create(0.5)))
    layer:addChild(failtip,0)

    local namebox = ccui.EditBox:create(cc.size(150,50),"name.png")
    namebox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    namebox:setPosition(cc.p(size.width/2+50,size.height/2+40))
    namebox:setPlaceHolder("bubble")
    namebox:setFontColor(cc.BLACK)
    layer:addChild(namebox,0)

    local gradelabel = cc.Label:createWithSystemFont(tostring(GameManager.grade),"Arial",48)
    gradelabel:setColor(GRASSGREEN)
    gradelabel:setAnchorPoint(0,0.5)
    gradelabel:setPosition(cc.p(size.width/2+40,size.height/2 -115))
    layer:addChild(gradelabel,0)

    local commit = cc.MenuItemImage:create("commiton.png","commitdown.png")
    local function onCommitClick()
        cclog(2,"commit tap")
        local name = namebox:getText()
        if #GameManager.rankinfo == 100 then
            table.remove(GameManager.rankinfo)
        end
        if name == "" or not name then
            name = "bubble" .. #GameManager.rankinfo+1
        end

        table.insert(GameManager.rankinfo,{name = name,grade = GameManager.grade})
        table.sort(GameManager.rankinfo,function ( a,b )
            return a.grade > b.grade
        end)

        local writablepath = cc.FileUtils:getInstance():getWritablePath()
        local rankfname = "rank.txt"
        local file = io.open(writablepath .. rankfname,"wb")
        local str = {}
        for i,v in ipairs(GameManager.rankinfo) do
            table.insert(str,string.format("{name = \"%s\",grade = %s},\n",v.name,v.grade))
        end
        file:write("local info = {\n" .. table.concat(str,"").."}\nreturn info")
        file:close()

        --结束后，重置一些数据
        GameManager:deleteStageInfo()
        GameManager.shoottimes = 0
        GameManager.grade = 0
        GameManager.failreason = 0
        GameManager:setGameTime(180)

        local scene = require("RankScene").create()
        cc.Director:getInstance():replaceScene(scene)
    end

    commit:registerScriptTapHandler(onCommitClick)
    local menu = cc.Menu:create(commit)
    menu:setPosition(cc.p(size.width/2,size.height/2 - 300))
    layer:addChild(menu,0)

    return layer
end

return OverScene
