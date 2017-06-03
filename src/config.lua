-- DEBUG
DEBUG = 0                   -- 0-none debug 1-less debug 2-more 3-all
--[[目前已知问题:
1、不适配IPAD分辨率,界面上下显示不全
2、游戏界面要根据适配重弄下
]]

-- 颜色
LIGHTBLUE = cc.c3b(0,128,255)
DEEPBLUE = cc.c3b(0,0,128)
SKYBLUE = cc.c3b(102,204,255)
GRAPEPURPLE = cc.c3b(128,0,255)
LIGHTGREY = cc.c3b(179,179,179)
GRASSGREEN = cc.c3b(64,128,0)
RICEYELLOW = cc.c3b(247,238,214)
LIGHTPURPLE = cc.c3b(204,102,255)
ORANGERED = cc.c3b(255,102,102)
PINK = cc.c3b(255,111,207)
-- 泡泡相关
BUBBCLR = {LIGHTBLUE,DEEPBLUE,LIGHTGREY,GRASSGREEN,LIGHTPURPLE,ORANGERED}
BUBBSIZE = 50
BUBBSPEED = 2000            -- 泡泡飞行速度
WORLDBODY = 666             -- 世界body tag
BUBBSHOOT = 999             -- 要发射的泡泡精灵/body tag
BUBBRANDOM = 888            -- 随机出的泡泡精灵/body tag
BUBBFLY   = 777             -- 飞行中的泡泡精灵/body tag
BUBBPOSY = 100              -- 发射和随机泡泡距离舞台底部的距离
TAGGAMELAYER = 555
TAGGRADE = 554
TAGTIMER = 553


-- 游戏设置
BUBBMOVENEED = 6                -- 所有泡泡向下移动一次需要的次数
BUBBWIPENEED  = 3               -- 泡泡消除
MAXGAMETIME = 180               -- 游戏倒计时3min
GRADEREWARD = 10                -- 消除1个泡泡得10分
MAXROW = 12                     -- 最多行数
MAXODD = 12                     -- 奇数行泡泡数/最大列数
MAXEVEN = 11                    -- 偶数行泡泡数
MAXLEVEL = 2                    -- 最大关卡数
WORLDCATEMASK = 0x0F            -- 世界类别掩码        0001
WORLDCONTMASK = 0x05            -- 世界接触检测掩码
-- WORLDCOLLMASK = 0x0             -- 世界碰撞检测掩码
NORBBCATEMASK = 0x06            -- 普通泡泡类别掩码    0110
NORBBCONTMASK = 0x01            -- 普通泡泡接触检测掩码 0001
NORBBCOLLMASK = 0x0             -- 普通泡泡碰撞检测掩码
SPEBBCATEMASK = 0x03            -- 特殊泡泡类别掩码     0011
SPEBBCONTMASK = 0x04            -- 特殊泡泡接触检测掩码 0100
SPEBBCOLLMASK = 0x08            -- 特殊泡泡碰撞检测掩码 1000


-- design resolution
MUSICON = true
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 960
-- gamestats

-- game fail reason
FAILREASON = {"对于龙来说时间也有尽头?","没位置了!?好想毁灭这一切啊!!","诶?!不能往下移动了!!"}

-- 关卡配置表最多8行12列,初始化 8 行 6 列的内容,配置泡泡的类型,0表示没有泡泡,
-- 如果某个位置没填也会被当成0,别配成会掉下来的,没做数据检查 = =
LEVEL =
{
    -- 偶数行比奇数行少个
    [1] =
    {
        {1,2,3,4,5,6,6,2,3,4,5,6},
        -- {1,2,3,4,5,6,6,2,3,4,5},
        -- {1,2,3,4,0,0,6,0,3,4,5,6},
        -- {0,0,0,0,5,6,1,0,0,0,0},
        -- {1,2,3,0,5,6,1,0,3,4,5,6},
        -- {1,2,3,4,5,6,2,3,4,5,6},
        -- {1,2,3,4,5,6,1,2,3,4,5,6},
        -- {1,2,3,4,5,6,1,3,4,5,6},
    },
    [2] =
    {
        {1,2,3,4,5,6,1,2,3,4,5,6},
        {1,2,3,4,5,6,1,2,3,4,5},
        {1,2,3,4,5,6,1,2,3,4,5,6},
        {1,2,3,4,5,6,1,2,3,4,5},
        {1,2,3,4,5,6,1,2,3,4,5,6},
        {1,2,3,4,5,6,2,3,4,5,6},
        {1,2,3,4,5,6,1,2,3,4,5,6},
        {1,2,3,4,5,6,1,3,4,5,6},
    }
}

