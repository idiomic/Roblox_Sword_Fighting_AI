local util = require(script.Parent.util)

local Control = {}
Control.__index = Control

function Control.new(model, epsilon, alpha, gamma, q_values)
	local self = setmetatable({
		model = model;
		humanoid = model.Humanoid;
		epsilon = epsilon;
		alpha = alpha;
		gamma = gamma;
		q_values = q_values;
		q = nil;
		x = nil;
		hp = model.Humanoid.Health;
		t_hp = nil;
		reward = -1;
		dead = false;
		q_next = nil;
	}, Control)
	model.Humanoid.HealthChanged:Connect(function(hp)
		if hp == 0 then
			self.dead = true
			self.reward = -100
		else
			self.reward = self.reward - self.hp + hp
		end
		self.hp = hp
	end)
	return self
end

function Control:setTarget(target)
	self.target = target
	self.t_hp = target.model.Humanoid.Health
	target.model.Humanoid.HealthChanged:Connect(function(hp)
		if hp == 0 then
			self.reward = 100
		else
			self.reward = self.reward + self.t_hp - hp
		end
		self.t_hp = hp
	end)
end

function Control:update()
	local targ = self.target
	local selfCF = self.model:GetPrimaryPartCFrame()
	local targCF = targ.model:GetPrimaryPartCFrame()
	local q = selfCF:ToObjectSpace(targCF)
	self.x = util.paramsToState(
		util.saturateMag(math.sqrt(q.X^2 + q.Z^2)),
		util.saturateAng(math.atan2(q.X, q.Z)),
		util.saturateAng(math.atan2(q.LookVector.X, q.LookVector.Z))
	)
end

function Control:step()
	local method
	if math.random() < self.epsilon then
		-- Exploit current knowledge
		if self.q_next then
			self.q = self.q_next
			return
		end
		method = util.bestQ
	else
		-- Explore new methods
		method = util.rndQ
	end
	
	self.q = method(self.q_values, self.x)
end

function Control:process()
	local move, turn = util.qToAction(self.q)
	self.humanoid:Move(util.DIR[move], true)
	
	local cf = self.model:GetPrimaryPartCFrame()
	if turn == 1 then
		cf = cf * CFrame.Angles(0, math.pi/32, 0)
	elseif turn == 2 then
		cf = cf * CFrame.Angles(0, -math.pi/32, 0)
	end
	self.model:SetPrimaryPartCFrame(cf)
end

function Control:learn()
	local reward = self.reward
	local mag = (self.model.PrimaryPart.Position - self.target.model.PrimaryPart.Position).Magnitude
	
	if mag > 30 then
		reward = reward - 1000
	elseif mag > 15 then
		reward = reward - (mag - 15) ^ 2
	end

	self.q_next = util.bestQ(self.q_values, self.x)
	local v = self.q_values[self.q]
	local update = reward + self.gamma * self.q_values[self.q_next] - v
	self.q_values[self.q] = v + self.alpha * update
	
	self.reward = -1
	
	return mag
end

return Control