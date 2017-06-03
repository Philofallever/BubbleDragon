require "cocos.init"
require "config"
local manager = require ("GameManager")
GameManager = manager:getInstance()
local writablepath = cc.FileUtils:getInstance():getWritablePath()
local rankfname = "rank.txt"

if cc.FileUtils:getInstance():isFileExist(writablepath ..  rankfname) then
    GameManager.rankinfo = dofile(writablepath ..  rankfname)
end

GameManager:setGameStats(1)

function cclog(debuglvl,fmt,...)
    if type(debuglvl) ~= "number" then
        print("function cclog debuglvl error~!")
    elseif DEBUG>=debuglvl then
        print(string.format(fmt, ...))
    end
end

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")

end

local function main()
    collectgarbage("setpause",100)
    collectgarbage("setstepmul",5000)

    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    AudioEngine.preloadMusic("sound/EmpressofFire.mp3")

    local director = cc.Director:getInstance()
    director:getOpenGLView():setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, 4) --3定高,4定宽
    director:setDisplayStats(DEBUG>0)
    cc.Director:getInstance():setAnimationInterval(1.0 / 60.0)

    local MainScene = require("MainScene").create()
    if not director:getRunningScene() then
        director:runWithScene(MainScene)
    else
        director:replaceWithScene(MainScene)
    end
end

local err,msg = xpcall(main,__G__TRACKBACK__)

if msg then
    cclog(-1,msg)
end
