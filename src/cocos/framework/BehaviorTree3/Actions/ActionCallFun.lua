--
-- Author: songtianming
-- Date: 2017-01-07 12:41:39
-- File: ActionCallFun.lua
-- beginFun() ->maybeWait->endFun()

local ActionCallFun = class("ActionCallFun", b3.Action)

function ActionCallFun:onCreate(properties)
    local fun = properties.beginFun
    self.m_beginFun = fun ~= "" and assert(loadstring("local target = ...; return target:"..fun)) or nil
    self.m_needWait = properties.needWait == "true"--持续多久
    local fun = properties.endFun
    self.m_endFun = fun ~= "" and assert(loadstring("local target = ...; return target:"..fun)) or nil
end

function ActionCallFun:onOpen(tick)
    if self.m_beginFun then
        local res = self.m_beginFun(tick.target)
        if self.m_needWait then
            assert(type(res)=="number", "needWait need the begin fun return a number")
            tick.blackboard:set("accTime",0, tick.tree.id, self.id)
            self.m_duration = res
        end
    end
end

function ActionCallFun:onClose(tick)
    if self.m_endFun then self.m_endFun(tick.target) end
end

function ActionCallFun:onTick(tick)
    if self.m_needWait then
        local accTime = tick.blackboard:get("accTime",tick.tree.id, self.id) + tick.dt*1000
        tick.blackboard:set("accTime", accTime, tick.tree.id, self.id)
        if accTime > self.m_duration then
            return b3.Com.SUCCESS
        end
        return b3.Com.RUNNING
    end
    return b3.Com.SUCCESS
end

return ActionCallFun






