local GameScene = class("GameScene",function ()
    local scene = cc.Scene:createWithPhysics()
    scene:getPhysicsWorld():setGravity(cc.p(0,0))
    -- scene:getPhysicsWorld():setFixedUpdateRate(30)
    scene:getPhysicsWorld():setSubsteps(10)             -- 更好的物理体验,更多的cpu计算
    -- scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    return scene
end)
local Bubble = require("Bubble.lua")

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(scene:createLayer(),0,TAGGAMELAYER)
    return scene
end

function GameScene:ctor()
    local function onEvent(event)
        cclog(3,"GameScene event = %s",event)
        if event == "enter" then
            self:onEnter()
        elseif event ==  "exit" then
            self:onExit()
        elseif event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(onEvent)
end

local function onBackClick()
    local scene = require("MainScene").create()
    cc.Director:getInstance():replaceScene(scene)
end

local function isInStage(glpoint)
    --可点击区域大小是 stageSize *2
    local stageSize = GameManager:getStageSize()   --{top,bottom,left,right,width,height}
    if glpoint.x >stageSize[4] or glpoint.x < stageSize[3] then
        return false
    end
    if glpoint.y >stageSize[1] or glpoint.y < stageSize[2] then
        return false
    end
    return true
end

-- 点击的时候获得一个方向向量,超出舞台区域不会触发后续事件
local function onTouchBegin(touch,event)
    local target = event:getCurrentTarget()
    local shootbubb = target:getChildByTag(BUBBSHOOT)
    local location = touch:getLocationInView()
    local touchpoint =cc.Director:getInstance():convertToGL(location)
    if isInStage(touchpoint) then
        local shootpos = cc.p(shootbubb:getPosition())
        GameManager:setFlyDirection(cc.pNormalize(cc.pSub(touchpoint,shootpos)))
        cclog(2,cc.pToAngleSelf(GameManager:getFlyDirection()))
        return true
    else
        cclog(2,"不在舞台区域")
        return false
    end
end

-- 移动的时候更新方向向量
local function onTouchMove(touch,event)
    local target = event:getCurrentTarget()
    local shootbubb = target:getChildByTag(BUBBSHOOT)
    local location = touch:getLocationInView()
    local touchpoint =cc.Director:getInstance():convertToGL(location)
    if isInStage(touchpoint) then
        local shootpos = cc.p(shootbubb:getPosition())
        GameManager:setFlyDirection(cc.pNormalize(cc.pSub(touchpoint,shootpos)))
        cclog(2,cc.pToAngleSelf(GameManager:getFlyDirection()))
    else
        GameManager:setFlyDirection(nil)
    end
end
-- 释放的时候
local function onTouchEnd(touch,event)
    if GameManager:getFlyDirection() then
        cclog(2,"发射泡泡")
        local target = event:getCurrentTarget()
        local scene = target:getParent()
        scene.listener:setEnabled(false)
        scene:shoot()
    else
        cclog(2,"泡泡没有速度")
    end
end

-- 接触检测
local function onContactBegin(contact)
    local scene = cc.Director:getInstance():getRunningScene()
    local body_a = contact:getShapeA():getBody()
    local body_b = contact:getShapeB():getBody()
    local stageSize = GameManager:getStageSize()
    local shootbody = scene:getPhysicsWorld():getBody(BUBBFLY)
    if body_b:getTag() == WORLDBODY or body_a:getTag() == WORLDBODY then
        cclog(2,"碰墙了")
        if  shootbody:getPosition().y > stageSize[1] - BUBBSIZE then
            cclog(2,"碰到顶部了")
            if not scene.bodypos  then
                scene.bodypos = shootbody:getPosition()
            end
            return false
        end
        return true
    end
    cclog(2,"body_a tag = %s",body_a:getTag())
    cclog(2,"body_b tag = %s",body_b:getTag())
    -- 接触后存位置给函数处理，只有第一次有效
    if not scene.bodypos and shootbody then               --bugfixed:确认shootbody存在,避免2个物理步骤之间恰好进行了帧处理
        scene.bodypos = shootbody:getPosition()
    end
    return false
end

function GameScene:createLayer()
    cclog(3,"enter GameScene")
    local size = cc.Director:getInstance():getWinSize()
    local layer = cc.Layer:create()
    local gamebkg = cc.Sprite:create("gamebkg.png")
    gamebkg:setPosition(cc.p(size.width/2,size.height/2))
    layer:addChild(gamebkg,0,TAGGAMELAYER)
    self:createWidgets(layer)
    -- stage
    local stageSize = GameManager:getStageSize()   --{top,bottom,left,right,width,height}
    local stageWidth,stageHeight = stageSize[5],stageSize[6]

    -- 物理边界,边界会比舞台大一点
    local physicsSize = {width = stageWidth+40,height = 40+stageHeight + 4*BUBBSIZE }
    local worldbody = cc.PhysicsBody:createEdgeBox(physicsSize, cc.PhysicsMaterial(0.1,1,0), 20.0)
    worldbody:setCategoryBitmask(WORLDCATEMASK)
    worldbody:setContactTestBitmask(WORLDCONTMASK)
    worldbody:setTag(WORLDBODY)
    local physicsNode = cc.Node:create()
    physicsNode:setPhysicsBody(worldbody)
    physicsNode:setPosition(cc.p(size.width/2,stageSize[1]-physicsSize.height/2+20))
    layer:addChild(physicsNode)
    -- 只有一个泡泡贴图
    local bubblescache  = cc.Director:getInstance():getTextureCache()
    bubblescache:addImage("bubble.png")
    self:createStage(layer)
    self:createShootBubb(layer)
    self:createRandBubb(layer)

    -- 监听layer的触摸,最终设置速度
    self.listener = cc.EventListenerTouchOneByOne:create()
    self.listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:setSwallowTouches(true)
    self.listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCH_MOVED)
    self.listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,layer)
    -- 监听世界碰撞
    local clistener = cc.EventListenerPhysicsContact:create()
    clistener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(clistener,layer)

    return layer
end

-- 界面:分数和倒计时
function GameScene:createWidgets(layer)
    local size = cc.Director:getInstance():getWinSize()

    local tuoer = cc.Sprite:create("res/tuoer/img_1.png")
    layer:addChild(tuoer)
    tuoer:setPosition(cc.p(size.width/2 - 220,size.height/2-310))
    local animation = cc.Animation:create()
    for i =1,17 do
        animation:addSpriteFrameWithFile("res/tuoer/img_" .. i .. ".png")
    end
    animation:setDelayPerUnit(0.10)
    animation:setRestoreOriginalFrame(true)
    local action = cc.Animate:create(animation)
    tuoer:runAction(cc.RepeatForever:create(action))

    local grade = cc.Label:createWithSystemFont("分数:","Arial",24)
    local gradesize= grade:getContentSize()
    grade:setPosition(cc.p(size.width/2 - 1.5*gradesize.width,size.height/2 - 440))
    grade:setWidth(2*gradesize.width)
    grade:setColor(DEEPBLUE)
    grade:setString("分数:0")
    layer:addChild(grade,0,TAGGRADE)

    local clock = cc.Label:createWithSystemFont("倒计时:","Arial",24)
    local clocksize= clock:getContentSize()
    clock:setPosition(cc.p(size.width/2 + clocksize.width,size.height/2 - 440))
    clock:setWidth(2*clocksize.width)
    clock:setColor(ORANGERED)
    layer:addChild(clock,0,TAGTIMER)

    local function refreshClock(delta)
        local str = "倒计时:"
        local time = MAXGAMETIME
        MAXGAMETIME = MAXGAMETIME - delta
        -- 如果时间为负数,结束游戏
        if MAXGAMETIME < 0 then
            cclog(2,"你死了,因为不能+1s")
            GameManager.failreason  = 1
            local scene = require("OverScene")
            cc.Director:getInstance():replaceScene(scene.create())
            layer:unscheduleUpdate()
            return
        end
        -- 正常设置游戏时间
        if MAXGAMETIME <= math.floor(time) then
            clock:setString(str .. math.floor(time))
        end
    end
    layer:scheduleUpdateWithPriorityLua(refreshClock,0)
end

function GameScene:createStage(layer)
    local bubblescache  = cc.Director:getInstance():getTextureCache()
    local stageInfo = GameManager:getStageInfo()
    -- 泡泡推
    for i,v in ipairs(stageInfo) do
        for j,bubb in ipairs(v) do
            if bubb.color > 0 then
                layer:addChild(Bubble:createNormal(bubb))
            end
        end
    end
end

function GameScene:createShootBubb( layer )
    local stageInfo = GameManager:getStageInfo()
    local shootinfo = stageInfo.shootbubb
    layer:addChild(Bubble:createShoot(shootinfo))
end

function GameScene:createRandBubb(layer)
    local  prerand  = layer:getChildByTag(BUBBRANDOM)
    if prerand then
        layer:removeChild(prerand,true)
    end
    local bubblescache  = cc.Director:getInstance():getTextureCache()
    local stageInfo = GameManager:getStageInfo()
    local randinfo = stageInfo.randombubb
    layer:addChild(Bubble:createRandom(randinfo))
end

function GameScene:shoot()
    local layer = self:getChildByTag(TAGGAMELAYER)
    local shootbody = self:getPhysicsWorld():getBody(BUBBSHOOT)
    -- 在发射的时候将发射泡泡的精灵标签和身体标签都设置成BUBBFLY 777
    shootbody:getNode():setTag( BUBBFLY)
    shootbody:setTag(BUBBFLY)

    local direction = GameManager:getFlyDirection()
    GameManager.shoottimes = GameManager.shoottimes +1
    cclog(2,"当前发射次数" ..    GameManager.shoottimes )
    -- 发射次数超过6下移
    if GameManager.shoottimes % BUBBMOVENEED == 0 then
        self:moveDown()
    end
    local stageInfo = GameManager:getStageInfo()
    stageInfo.preshootclr = stageInfo.shootbubb.color

    GameManager:setFlyDirection(nil)
    shootbody:setVelocity(cc.pMul(direction,BUBBSPEED))             --这儿应该分解下速度，无关紧要。
    GameManager:refreshShootBubb()
    self:createShootBubb(layer)
    GameManager:spawnRandomBubb()
    self:createRandBubb(layer)
end


function GameScene:contactAtPos()
    if not self.bodypos then
        return
    end
    cclog(2,"碰撞处理开始,self.bodypos = %s %s",self.bodypos.x ,self.bodypos.y)
    local layer = self:getChildByTag(TAGGAMELAYER)
    layer:removeChildByTag(BUBBFLY,true)
    local stageInfo = GameManager:getStageInfo()
    local emptybubb = GameManager:getCloseBubb(self.bodypos)
    if not emptybubb then
        cclog(2,"没有最近的泡泡,你死了")
        GameManager.failreason  = 2
        local scene = require("OverScene")
        cc.Director:getInstance():replaceScene(scene.create())
        return
    end

    emptybubb.color  = stageInfo.preshootclr
    GameManager:setBubbleParent(emptybubb)
    layer:addChild(Bubble:createNormal(emptybubb))
    local parentTable = GameManager:getParentTable()
    if #parentTable[emptybubb.parent]> 2 then
        cclog(2, "儿子数目".. #parentTable[emptybubb.parent] .. ",进行消除")
        self:wipeConlision(emptybubb)
    local function enableTouch()
        self.listener:setEnabled(true)
    end
    local action = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(enableTouch))
    self:runAction(action)
    else
        cclog(2, "儿子数目".. #parentTable[emptybubb.parent])
        self.listener:setEnabled(true)
    end
    self.bodypos = nil
    cclog(2,"碰撞处理完毕,self.bodypos = %s",self.bodypos)
end

function GameScene:wipeConlision(emptybubb)
    local parentTable = GameManager:getParentTable()
    local wipebubbtags = parentTable[emptybubb.parent]
    local layer = self:getChildByTag(TAGGAMELAYER)
    for _,tag in ipairs(wipebubbtags) do
        local action = cc.FadeOut:create(0.4)
        local callfunc = cc.CallFunc:create(function ()
            layer:removeChildByTag(tag,true)
        end)
        local seq = cc.Sequence:create(action,callfunc)
        layer:getChildByTag(tag):runAction(seq)
    end
    GameManager:refreshStageInfoOnWipe(wipebubbtags)
    
    local dropbubbtags = GameManager:getUnlinkedBubbs()
    for _,tag in ipairs(dropbubbtags) do
        local action = cc.MoveBy:create(0.4,cc.p(0,-200))
        local callfunc = cc.CallFunc:create(function ()
            layer:removeChildByTag(tag,true)
        end)
        local seq = cc.Sequence:create(action,callfunc)
        layer:getChildByTag(tag):runAction(seq)
    end
    GameManager:refreshStageInfoOnDrop(dropbubbtags)
    GameManager.grade  = GameManager.grade+(#wipebubbtags +#dropbubbtags) * GRADEREWARD
    local clock = layer:getChildByTag(TAGGRADE)
    clock:setString("分数:" .. GameManager.grade)
end

function GameScene:moveDown()
    local layer = self:getChildByTag(TAGGAMELAYER)
    local stageInfo = GameManager:getStageInfo()
    for i,bubbinfo in ipairs(stageInfo[12]) do
        if bubbinfo.color > 0 then
            cclog(2,"你死了原来泡泡已经有12行了不能下移")
            GameManager.failreason  = 3
            local scene = require("OverScene")
            cc.Director:getInstance():replaceScene(scene.create())
            return
        end
    end
    for i,rowdata in ipairs(stageInfo) do
        for j, bubbinfo in ipairs(rowdata) do
            if bubbinfo.color > 0 then
                layer:removeChildByTag(bubbinfo.tag,true)
            end
        end
    end
    GameManager:refreshStageInfoOnMoveDown()
    self:createStage(layer)
end

function  GameScene:onEnter()
    GameManager:setGameTime(MAXGAMETIME)
    local function func(...)
        return self.contactAtPos(self,...)
    end
    self:scheduleUpdateWithPriorityLua(func,0)
end

function GameScene:onExit()
    self:unscheduleUpdate()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("bubble.png")
end

function GameScene:onCleanup()

end

return GameScene



