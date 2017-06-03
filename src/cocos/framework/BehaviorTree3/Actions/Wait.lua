--
-- Author: zen.zhao88@gmail.com
-- Date: 2015-12-03 17:01:32
--
local Wait = class("Wait",b3.Action)

function Wait:onCreate(properties)
	self.m_duration = properties.milliseconds or 0--为常量, 可共享
end

function Wait:onOpen(tick)
	tick.blackboard:set("accTime",0, tick.tree.id, self.id)
end

function Wait:onTick(tick)
	local accTime = tick.blackboard:get("accTime",tick.tree.id, self.id) + tick.dt*1000
    tick.blackboard:set("accTime", accTime, tick.tree.id, self.id)
	if accTime > self.m_duration then
		return b3.Com.SUCCESS
	end
	return b3.Com.RUNNING
end

return Wait
