local Bubble = class("Bubble")
-- bubble是layer的child
function Bubble:createSPByInfo(info)
    if not self.bubblescache then 
        self.bubblescache = cc.Director:getInstance():getTextureCache()
    end
    self.info = info 
    self.sp = cc.Sprite:createWithTexture(self.bubblescache:getTextureForKey("bubble.png"))
    self.sp:setColor(BUBBCLR[self.info.color])
    self.sp:setTag(self.info.tag)
    self.sp:setPosition(cc.p(self.info.posx,self.info.posy))
end

function Bubble:_setBody(bodytype)
    if not self.sp  then 
       cclog(2,"no sprite")
        return 
    end
    local body = cc.PhysicsBody:createCircle(BUBBSIZE/2-2,cc.PhysicsMaterial(0.1,1,0))
    if bodytype == 1 then 
        body:setCategoryBitmask(NORBBCATEMASK)
        body:setContactTestBitmask(NORBBCONTMASK)
        body:setCollisionBitmask(NORBBCOLLMASK)
        body:setTag(self.info.tag)
        self.sp:setPhysicsBody(body)
    elseif bodytype == 2 then
        body:setCategoryBitmask(SPEBBCATEMASK)
        body:setContactTestBitmask(SPEBBCONTMASK)
        body:setCollisionBitmask(SPEBBCOLLMASK)
        body:setTag(self.info.tag)
        self.sp:setPhysicsBody(body)
    else
        cclog(2,"unknow boty type")
    end
end

function Bubble:createNormal(info)
    self:createSPByInfo(info)
    self:_setBody(1)
    return self.sp
end

function Bubble:createShoot(info)
    self:createSPByInfo(info)
    self:_setBody(2)
    return self.sp
end

function Bubble:createRandom(info)
    self:createSPByInfo(info)
    return self.sp
end

function  Bubble:removeSelf()
    -- self.sp:removeFromParentAndCleanup(true)
end



return Bubble