local RankScene = class("RankScene",function ()
    local scene = cc.Scene:create()
    return scene
end)

function RankScene.create()
    local scene = RankScene.new()
    scene:addChild(scene:createLayer(),0)
    return scene
end

function RankScene.ctor()
    -- body
end



local function onBackClick()
    local scene = require("MainScene").create()
    cc.Director:getInstance():replaceScene(scene)
end

local function createRankNode(i,name,grade)
    local node = cc.Node:create()
    node:setContentSize(480,50)
    local rank = cc.Label:createWithSystemFont("第" .. i .."名","Arial",24)
    rank:setColor(cc.BLACK)
    rank:setAnchorPoint(0,0)
    node:addChild(rank)
    local name = cc.Label:createWithSystemFont(name,"Arial",24)
    name:setAnchorPoint(0,0)
    name:setColor(LIGHTPURPLE)
    name:setPosition(cc.p(120,0))
    node:addChild(name)
    local grade = cc.Label:createWithSystemFont(tostring(grade),"Arial",24)
    grade:setAnchorPoint(0,0)
    grade:setColor(cc.BLACK)
    grade:setPosition(cc.p(260,0))
    node:addChild(grade)
    return node
end


function RankScene:createLayer()
    cclog(2,"enter RankScene")
    local size = cc.Director:getInstance():getWinSize()
    local layer = cc.Layer:create()
    local rankbkg = cc.Sprite:create("rank.png")
    rankbkg:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(rankbkg,0)
    local scrollview  = ccui.ScrollView:create()
    scrollview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    scrollview:setScrollBarEnabled(false)
    scrollview:setBounceEnabled(true)
    scrollview:setContentSize(480,560)

    scrollview:setInnerContainerSize(cc.size(480,50*#GameManager.rankinfo+1))
    for i,info in ipairs(GameManager.rankinfo) do
        local ranknode = createRankNode(i,info.name,info.grade)
        ranknode:setAnchorPoint(0,0)
        scrollview:addChild(ranknode,0,i)

        ranknode:setPosition(0,scrollview:getInnerContainerSize().height - 50 *i)
    end
    -- layer:addChild(createRankNode(1,"nisdsd",2222):setPosition(cc.p(300,200)))
    scrollview:setAnchorPoint(0,1)
    -- scrollview:jumpToBottom()
    scrollview:setPosition(cc.p(size.width/2-150,size.height/2+285))
    layer:addChild(scrollview)

    local confirmitem = cc.MenuItemImage:create("confirmon.png","confirmdown.png")
    confirmitem:registerScriptTapHandler(onBackClick)
    local menu  = cc.Menu:create(confirmitem)
    menu:setPosition(cc.p(size.width/2,size.height/2 - 300))
    layer:addChild(menu)
    return layer
end



return RankScene
