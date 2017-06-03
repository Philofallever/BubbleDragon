local GameManager = class("GameManager")
local shareInstance = nil
local gameStats = 2                   -- 特殊值 | 当前关卡
local stageInfo = nil
local parentTable = {}                -- 连通图 parent记录入口表 parentTable = { father_id1 = {sontag1,sontag2 ...} , father_id2 , ... }
local flyDirection = nil
local stageType = 2                   -- 需要生成的舞台类型,newStage使用,其他不要使用.1是首行是12的泡泡 2是首行是11的泡泡



function GameManager:ctor()
    self.shoottimes = 0
    self.grade = 0
    self.failreason = 0               -- 1 - 没有时间了 2 - 碰撞位置周围没有泡泡 3 - 因为12行有泡泡不能下移
    self.rankinfo = {}
end

function GameManager:delete()
    shareInstance = nil
end

function GameManager:getInstance()
    if not shareInstance then
        shareInstance = GameManager:new()
    end
    return shareInstance
end

function GameManager:destroyInstance()
    if shareInstance then
        shareInstance:delete()
    end
end

function GameManager:getGameStats()
    return gameStats
end

function GameManager:setGameStats(stats)
    gameStats = stats
end

function GameManager:setFlyDirection(dir)
    flyDirection = dir
end

function GameManager:getFlyDirection()
    return flyDirection
end

function GameManager:setGameTime(num)
    MAXGAMETIME = num
end

function GameManager:getParentTable()
    return parentTable
end

-- 返回边界信息，舞台的大小为 12*12
function GameManager:getStageSize()
    if not stageSize then
        local winsize =  cc.Director:getInstance():getWinSize()
        local bubbwidth = BUBBSIZE
        local bubbheight = math.ceil(BUBBSIZE* math.cos(math.pi/6))
        local top = CONFIG_SCREEN_HEIGHT
        local bottom = CONFIG_SCREEN_HEIGHT - MAXROW * bubbheight
        local left = winsize.width/2 - MAXODD/2*bubbwidth
        local right = winsize.width/2 + MAXODD/2*bubbwidth
        local width = right-left
        local height = top -bottom
        stageSize = {top,bottom,left,right,width,height}
    end
    return stageSize
end

-- 这个函数返回一个舞台数据表,记录了舞台的行列,泡泡放置点.
-- 只用在重新生成舞台数据的时候使用,不要在其他时候调用,有副作用!
function GameManager:newStage()
    local stageData = {}
    -- 按舞台类型,交换奇数行和偶数行最大泡泡数,并重新设置下一个生成的舞台类型
    if stageType ==1 then
        MAXODD,MAXEVEN = math.max(MAXODD,MAXEVEN),math.min(MAXODD,MAXEVEN)     -- 12 ,11
        stageType = 2
    elseif stageType ==2 then
        MAXODD,MAXEVEN  = math.min(MAXODD,MAXEVEN),math.max(MAXODD,MAXEVEN)    -- 11 , 12
        stageType = 1
    else
        cclog(1,"stage type error in function new stage")
    end
    local stageSize = self:getStageSize()
    local top,_,left = unpack(stageSize)
    local tag = 0
    local bubbwidth = BUBBSIZE
    local bubbheight = math.floor(BUBBSIZE* math.cos(math.pi/6))
    top0 = top + bubbheight - BUBBSIZE/2
    for i = 1,MAXROW do
        stageData[i] = {}
        colnum = (i%2==1) and MAXODD or MAXEVEN
        top0 = top0 - bubbheight
        local left0 = left
        if colnum == math.max(MAXODD,MAXEVEN) then
            left0 = left0 - bubbwidth/2
        end
        for j = 1,colnum do
            left0 = left0 + bubbwidth
            tag = tag + 1
            local temp = {}
            temp.tag = tag
            temp.posx = left0
            temp.posy = top0
            stageData[i][j] = temp
        end
    end
    stageData.maxtag = tag
    return stageData
end

--  舞台初始
function GameManager:initStageInfo()
    stageInfo = self:newStage()
    local bubbs = LEVEL[gameStats]
    self:refreshStageInfoByBubbs(bubbs)
    self:spawnRandomBubb()
    self:spawnShootBubb()
end

-- 按照给定的bubbs颜色配置表,刷新舞台数据,设置每个点的颜色,设置父子都是自己
function GameManager:refreshStageInfoByBubbs(bubbs)
    for row,rowdata in ipairs(stageInfo) do
        for col,bubbinfo in ipairs(rowdata) do
            bubbinfo.color =  bubbs[row] and bubbs[row][col] or 0
            bubbinfo.parent = bubbinfo.tag
            parentTable[bubbinfo.parent] = {bubbinfo.tag}
            self:setBubbleParent(bubbinfo)
        end
    end
    --dump(parentTable)
end

function GameManager:getStageInfo( )
    if not stageInfo then
        self:initStageInfo()
    end
    return stageInfo
end

function GameManager:deleteStageInfo()
    stageInfo = nil
end

-- 返回指定行所有泡泡或nil(当超出舞台)
function GameManager:getBubblesByRow(rowid)
    return stageInfo[rowid]
end

-- 返回指定行指定列的泡泡或nil(当超出舞台)
function GameManager:getBubbleByRowCol(rowid,colid)
    return stageInfo[rowid] and stageInfo[rowid][colid]
end

-- 返回指定标签的row , col
function GameManager:tagToRowCol(tag)
    local doublerow = MAXODD+MAXEVEN
    local tem1 = math.floor(tag / doublerow)
    local tem2 = tag - doublerow*tem1
    local real_row,real_col
    real_row  = tem1*2
    if tem2 == 0 then
        real_row = real_row
        real_col = MAXEVEN
    else
        if tem2 <= MAXODD then
            real_row = real_row+1
            real_col = tem2
        else
            real_row = real_row+2
            real_col  = tem2 - MAXODD
        end
    end
    return  real_row,real_col
end

-- 返回指定标签的泡泡信息(888,999返回特殊的)
function GameManager:getBubbleByTag(tag)
    if tag == BUBBSHOOT then
        return stageInfo.shootbubb
    elseif tag == BUBBRANDOM then
        return stageInfo.randombubb
    end
    local real_row,real_col = self:tagToRowCol(tag)
    return self:getBubbleByRowCol(real_row,real_col)
end

-- 返回某个泡泡周围所有存在的泡泡(包括颜色是0)
function GameManager:getAroundBubbs(targetbubble)
    local around = {}
    local row,col = self:tagToRowCol(targetbubble.tag)
    local ismax = (#self:getBubblesByRow(row) == math.max(MAXODD,MAXEVEN))

    around.left = self:getBubbleByRowCol(row,col-1)
    around.right = self:getBubbleByRowCol(row,col+1)
    around.upleft = self:getBubbleByRowCol(row-1,ismax and col -1 or col)
    around.upright = self:getBubbleByRowCol(row-1,ismax and col or col + 1)
    around.downleft = self:getBubbleByRowCol(row+1,ismax and col -1 or col)
    around.downright = self:getBubbleByRowCol(row+1,ismax and col or col + 1)
    return around
end

-- 合并父子
function GameManager:combineParent(father_id1,father_id2)
    for i,sontag in ipairs(parentTable[father_id2]) do
        local bubble = self:getBubbleByTag(sontag)
        bubble.parent = father_id1
        if not parentTable[father_id1] then
            cclog(2,"father_id1 = %s , father_id2 = %s ",father_id1,father_id2)
            dump(parentTable)
        end
        table.insert(parentTable[father_id1],sontag)
    end
    parentTable[father_id2] = nil
end

-- 给某个泡泡设定father,并合并更新parentTable
function GameManager:setBubbleParent(sonbubble)
    if sonbubble.color ==0 then                 -- 不处理无色泡泡
        return
    end
    local around = self:getAroundBubbs(sonbubble)
    -- if sonbubble.tag ==64 then
    --     dump(around)
    -- end
    --先找他爸爸们
    local fathers = {}
    for k,bubble in pairs(around) do
        if bubble.color == sonbubble.color then
            fathers[bubble.parent] = true
        end
    end
    local tem = {}
    for k,v in pairs(fathers) do
        table.insert(tem,k)
    end

    if #tem == 0 then
        return
    elseif #tem ==1  then
        -- 有一个爸爸当儿子
        local father_id = tem[1]
        self:combineParent(father_id,sonbubble.parent)
    else
        local father_id = tem[1]
        self:combineParent(father_id,sonbubble.parent)
        for i = 2,#tem do
            self:combineParent(father_id,tem[2])
        end
    end
end

function GameManager:spawnRandomBubb()
    if not stageInfo.randombubb then
        local bubbinfo = {}
        local winsize = cc.Director:getInstance():getWinSize()
        local stageSize = self:getStageSize()
        bubbinfo.parent = nil
        bubbinfo.tag = BUBBRANDOM
        bubbinfo.color = math.random(#BUBBCLR)
        bubbinfo.posx = winsize.width/2 -  2*BUBBSIZE
        bubbinfo.posy = stageSize[2]-BUBBPOSY
        stageInfo.randombubb = bubbinfo
    else
        stageInfo.randombubb.color = math.random(#BUBBCLR)
    end
end

function GameManager:spawnShootBubb()
    local bubbinfo = {}
    local winsize = cc.Director:getInstance():getWinSize()
    local stageSize = self:getStageSize()
    bubbinfo.parent = nil
    bubbinfo.tag = BUBBSHOOT
    bubbinfo.color = math.random(#BUBBCLR)
    bubbinfo.posx = winsize.width/2
    bubbinfo.posy = stageSize[2]-BUBBPOSY
    stageInfo.shootbubb = bubbinfo
end

function GameManager:refreshShootBubb()
    stageInfo.shootbubb.color = stageInfo.randombubb.color

end

function GameManager:getCloseBubb(glpos)
    local stageSize = self:getStageSize()
    local emptybubb  = nil
    local mindistance = nil  
    for i  = 1, stageInfo.maxtag do
        local bubbinfo = self:getBubbleByTag(i)
        if bubbinfo.color == 0 then
            local distance = cc.pGetDistance(glpos,cc.p(bubbinfo.posx,bubbinfo.posy))
            if  distance <= BUBBSIZE-1 then
                if glpos.y > stageSize[1] - BUBBSIZE then 
                    emptybubb = bubbinfo
                    return emptybubb     
                else 
                    local arounds  = self:getAroundBubbs(bubbinfo)
                    for _,sidebubb in pairs(arounds) do 
                        if sidebubb.color > 0 then 
                            if not mindistance or distance< mindistance then
                                emptybubb = bubbinfo
                                mindistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return emptybubb
end

function GameManager:refreshStageInfoOnWipe(wipedbubbs)
    for _,tag in ipairs(wipedbubbs) do
        local bubbinfo = self:getBubbleByTag(tag)
        -- 改变这些泡泡的颜色
        bubbinfo.color = 0
        -- 将泡泡的parent重设为自己
        bubbinfo.parent = tag
        -- 将parent表的子节点重设为自己
        parentTable[tag] = {tag}
    end
end

function GameManager:refreshStageInfoOnDrop(unlinkedbubbs)
    for _,tag in ipairs(unlinkedbubbs) do
        local bubbinfo = self:getBubbleByTag(tag)
        -- 改变这些泡泡的颜色
        bubbinfo.color = 0
        -- 将泡泡的parent重设为自己
        bubbinfo.parent = tag
        -- 将parent表的子节点重设为自己
        parentTable[tag] = {tag}
    end
end


-- 一个泡泡是否能连接到顶泡泡
function GameManager:isLinkedOnTop(bubbinfo,tags)
    local tags = tags or { }
    if not tags[bubbinfo.tag] then
        tags[bubbinfo.tag] = true
    else
        return false
    end
    if bubbinfo.tag <= #self:getBubblesByRow(1) then              --最顶一排
        return true
    end
    local arounds = self:getAroundBubbs(bubbinfo)
    for k,sidebubb in pairs(arounds) do
        if sidebubb.color > 0 then
            local res = self:isLinkedOnTop(sidebubb,tags)
            if res then return res end
        end
    end
    return false
end

-- 找到所有没连接的泡泡,返回tag表
function GameManager:getUnlinkedBubbs()
    local unlinkedbubbs = {}
    for i  = 1, stageInfo.maxtag do
        local bubbinfo = self:getBubbleByTag(i)
        if bubbinfo.color >0 then
            local islinked = self:isLinkedOnTop(bubbinfo)
            if not islinked then
                table.insert(unlinkedbubbs,i)
            end
        end
    end
    return unlinkedbubbs
end

-- return table bubbsclr 从stageInfo中得到所有泡泡颜色
function GameManager:getBubbsColor()
    local stageInfo = self:getStageInfo()
    local bubbsclr = {}
    for i,rowdata in ipairs(stageInfo) do
        bubbsclr[i] = {}
        for j,bubbinfo in ipairs(rowdata) do
            bubbsclr[i][j] = bubbinfo.color
        end
    end
    return bubbsclr
end

--生成新舞台,将所有泡泡填进去
function GameManager:refreshStageInfoOnMoveDown()
    local prebubbsclr = self:getBubbsColor()
    local newStage= self:newStage()
    newStage.shootbubb = stageInfo.shootbubb
    newStage.randombubb  = stageInfo.randombubb
    stageInfo = newStage
    local newrow = {}
    -- 更好的随机泡泡生成
    local grop = math.random(2,6)
    local clrindex = math.random(#BUBBCLR)
    for i = 1, MAXODD do
        if i % grop ==0 then 
            clrindex = math.random(#BUBBCLR)
        end 
        table.insert(newrow,clrindex)
    end

    table.insert(prebubbsclr,1,newrow)
    self:refreshStageInfoByBubbs(prebubbsclr)
end


return GameManager
