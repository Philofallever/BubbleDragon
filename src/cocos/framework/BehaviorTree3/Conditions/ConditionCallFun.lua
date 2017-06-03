--
-- Author: songtianming
-- Date: 2017-01-07 11:44:02
-- File: ConditionCallFun.lua
local ConditionCallFun = class("ConditionCallFun", b3.Condition)

function ConditionCallFun:onCreate(properties)
    local con = properties.condition --getHp()>0
    self.m_condiFun = assert(loadstring("local target = ...; return target:"..con))
end

function ConditionCallFun:onTick(tick)
    return self.m_condiFun(tick.target) and b3.Com.SUCCESS or b3.Com.FAILURE
end

return ConditionCallFun
