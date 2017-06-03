local MainScene = class("MainScene",function ()
    local scene = cc.Scene:create()
    return scene
end)


function MainScene.create()
    local scene = MainScene.new()
    scene:addChild(scene:createLayer(),0)
    return scene
end

function MainScene:ctor()
    function onEvent(event)
        cclog(3,"MainScene event = %s",event)
        if event == "enter" then
            self:onEnter()
        elseif event ==  "exit" then
            self:onExit()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(onEvent)
end

function MainScene:createLayer()
    cclog(3,"enter main scene")
    local size = cc.Director:getInstance():getWinSize()
    local layer = cc.Layer:create()
    local bkg = cc.Sprite:create("mainbkg.png")
    bkg:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(bkg,0)

    local gametitle1 = cc.Sprite:create("title.png")
    gametitle1:setScale(1.2)
    gametitle1:setPosition(cc.p(size.width/2,size.height/2 + 340))
    layer:addChild(gametitle1,0)

    --按钮
    local startmenu = cc.MenuItemImage:create("startup.png","startdown.png")
    startmenu:registerScriptTapHandler(function ()
        local scene = require("GameScene").create()
        cc.Director:getInstance():replaceScene(scene)
        end)
    local settingmenu  = cc.MenuItemImage:create("settingup.png","settingdown.png")
    settingmenu:registerScriptTapHandler(function()
        local scene = require("SettingScene").create()
        cc.Director:getInstance():replaceScene(scene)
        end)
    local rankmenu = cc.MenuItemImage:create("rankup.png","rankdown.png")
    rankmenu:registerScriptTapHandler(function()
        local scene = require("RankScene").create()
        cc.Director:getInstance():replaceScene(scene)
        end)
    local mainmenu = cc.Menu:create(startmenu,settingmenu,rankmenu)
    mainmenu:setPosition(cc.p(size.width/2,size.height/2-200))
    mainmenu:alignItemsVerticallyWithPadding(25)
    layer:addChild(mainmenu,0)

    local plicy = cc.Label:createWithSystemFont("BiuBiuBiu All Right Reserved ™ @2017 chengdu","Arial",16)
    plicy:setColor(cc.c3b(0,0,0))
    plicy:setPosition(cc.p(size.width/2,size.height/2 - 440))

    layer:addChild(plicy,1)

    return layer
end

function  MainScene:onEnter()
   -- GameManager:setGameStats(GAME_BEGIN)
end

function MainScene:onExit()
    -- body
end

function MainScene:onCleanup()

end

function MainScene:onEnterTransitionFinish()
    if  DEBUG < 0 and not(AudioEngine.isMusicPlaying())then
        AudioEngine.playMusic("sound/EmpressofFire.mp3",true)
    end
end

function MainScene:onExitTransitionStart()
    -- body
end

return MainScene
