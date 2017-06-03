--
-- Author: zen.zhao88@gmail.com
-- Date: 2015-12-02 15:34:00
--
local BehaviorTree = class("BehaviorTree")
local cjson = require("cjson")
function BehaviorTree:ctor(jsonFile,customNodeList)
	self.title       = 'The behavior tree'
    self.description = 'Default description'
    self.properties  = {}
    self.root        = nil
    self.debug       = nil
    local defCustomBtNodes = require("cocos.framework.BehaviorTree3.customBtNodes")
    self:load(jsonFile,customNodeList or defCustomBtNodes)
end
-- 通过json配置表构建行为树
function BehaviorTree:load(jsonFile,nodeList)
    local data = cjson.decode(cc.FileUtils:getInstance():getStringFromFile(jsonFile))
	nodeList = nodeList or {}

	self.id = data.id or b3.Com.createUUID()
	self.title = data.title or self.title
	self.description = data.description or self.description

	local nodes = {}
	local node
	for id,nodeData in pairs(data.nodes) do
		local Cls = nodeList[nodeData.name] or b3[nodeData.name]
		assert(Cls,string.format("unknown node name:%s",nodeData.name))
		node = Cls.new(nodeData)
		nodes[id] = node
	end
	--Connect the nodes
	for id,nodeData in pairs(data.nodes) do
		node = nodes[id]
		if node.category == b3.Com.COMPOSITE and nodeData.children  then
			for i=1,#nodeData.children do
				local cid = nodeData.children[i]
				table.insert(node.children, nodes[cid])
			end
		elseif node.category == b3.Com.DECORATOR and nodeData.child then
			node.child = nodes[nodeData.child]
            assert(node.child,"not have a child")
		end
	end
	self.root = nodes[data.root]
end


--This method dump the current BT into a data structure.

--Note: This method does not record the current node parameters. Thus,
--it may not be compatible with load for now.

--@method dump
--@return {Object} A data object representing this tree.

function BehaviorTree:dump()
	local data = {}
	local customNames = {}

	data.title        = self.title
    data.description  = self.description
    data.properties   = self.properties
    data.nodes        = {}
    data.custom_nodes = {}
    if self.root then
    	data.root     = self.root.id
    else
    	return data
    end

    local stack = {self.root}
    while #stack > 0 do
    	local node = table.remove(stack,#stack)
    	local nodeData = {}
    	nodeData.id = node.id;
        nodeData.name = node.name;
        nodeData.title = node.title;
        nodeData.description = node.description;
        nodeData.properties = node.properties;
        nodeData.parameters = node.parameters;

        --verify custom node
        local proto
        if node.constructor then
			proto = node.constructor.prototype
        end
        local nodeName = (proto and proto.name) or node.name
        if not b3[nodeName] and not customNames[nodeName] then
        	local subdata = {}
        	subdata.name = nodeName
        	subdata.title =  (proto and proto.title) or node.title
        	subdata.category = node.category
        	customNames[nodeName] = true
        	table.insert(data.custom_nodes,subdata)
        end

        --store children/child
        local category = node.category
        if category == b3.Com.COMPOSITE and node.children then
        	local children = {}
        	for i=1,#node.children do
        		table.insert(children, node.children[i].id)
        		table.insert(stack,node.children[i])
        	end
        	nodeData.children = children
        elseif category == b3.DECORATOR and node.child then
        	table.insert(stack,node.child)
        	nodeData.child = node.child.id
        end
        data.nodes[node.id] = nodeData
    end
    return data
end
--不同的target, 不同的blackboard;这样同一棵树可共享
function BehaviorTree:tick(target, blackboard, dt)
    -- printx("--------")
	assert(blackboard, 'tick object is important for tick method')
	--Add object to a tick object
    local tick = b3.Tick.new()
    tick.dt = dt
    tick.debug = self.debug
    tick.target = target
    tick.blackboard = blackboard
    tick.tree = self
    --TICK NODE
    local state = self.root:execute(tick)
    --close nodes from last tick, if needed
    local lastOpenNodes = blackboard:get("openNodes", self.id)
    local currOpenNodes = tick.openNodes
    -- for i,node in ipairs(currOpenNodes) do
    --     printx(node.title)
    -- end
    -- printx(#currOpenNodes)
    --does not close if it is still open in this tick
    local start = 1
    local lastOpenNodesNum = #lastOpenNodes
    for i=1,math.min(lastOpenNodesNum,#currOpenNodes) do
        if lastOpenNodes[i] == currOpenNodes[i] then
            start = i+1
        else
            break
        end
    end
    --close the nodes
    if lastOpenNodesNum > 0 then
        for i=lastOpenNodesNum,start,-1 do
            -- printx("ccccc", lastOpenNodes[i].title)
            lastOpenNodes[i]:close(tick)
        end
    end
    --populate blackboard
    blackboard:set("openNodes",currOpenNodes, self.id)
    blackboard:set("nodeCount",tick.nodeCount,self.id)

    return state
end

return BehaviorTree
