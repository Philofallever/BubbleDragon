--
-- Author: songtianming
-- Date: 2017-01-09 09:56:03
-- File: DecoratorSuccess.lua

local DecoratorSuccess = class("DecoratorSuccess",b3.Decorator)

function DecoratorSuccess:onTick(tick)
    local status = self.child:execute(tick)
    if status == b3.Com.RUNNING then
        return status
    else
       return b3.Com.SUCCESS
    end
end

return DecoratorSuccess
