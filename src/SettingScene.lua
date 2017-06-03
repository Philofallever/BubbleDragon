local SettingScene = class("SettingScene",function ()
    local scene = cc.Scene:create()
    return scene
end)

function SettingScene.create()
    local scene = SettingScene.new()
    scene:addChild(scene:createLayer(),0)
    return scene
end

function SettingScene.ctor()
    -- body
end



local function onBackClick()
    local scene = require("MainScene").create()
    cc.Director:getInstance():replaceScene(scene)
end


function SettingScene:createLayer()
    cclog(3,"enter SettingScene")
    local size = cc.Director:getInstance():getWinSize()
    local layer = cc.Layer:create()
    local bkg = cc.Sprite:create("settingbkg.png")
    bkg:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(bkg,0)

    local onitem = cc.MenuItemImage:create("on.png","off.png")
    local offitem = cc.MenuItemImage:create("off.png","on.png")
    local callback = function ()
        cclog(2,"music touched")
    end
    local musictoggle = cc.MenuItemToggle:create(onitem,offitem)
    musictoggle:registerScriptTapHandler(callback)

    local menu = cc.Menu:create(musictoggle)
    menu:setPosition((cc.p(size.width/2+80,size.height/2+90)))
    layer:addChild(menu,0)

    local commit = cc.MenuItemImage:create("commiton.png","commitdown.png")
    commit:registerScriptTapHandler(onBackClick)

    local menu_back = cc.Menu:create(commit)
    menu_back:setPosition(cc.Director:getInstance():convertToGL(cc.p(size.width/2,size.height/2 + 200)))
    layer:addChild(menu_back,0)

    return layer
    -- body
end



return SettingScene
