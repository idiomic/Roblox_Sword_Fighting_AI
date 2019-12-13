local Control = require(script.Control)
local util = require(script.util)

local storage = game:GetService('ServerStorage')
local ai = storage.AI:Clone()

local epsilon = 1
local alpha = 0.1
local gamma = 0.9

local function makeBot(pos)
	local bot = ai:Clone()
	bot.Parent = workspace
	bot:MoveTo(pos)
	bot.PrimaryPart = bot.HumanoidRootPart
	return bot
end

local q_values = util.loadQ()
local bots = {}

local function makePair(i)
	local x_o = i % 10 * 150 - 750
	local y_o = (i - i % 10) * 15 - 750
	local r1 = Control.new(
		makeBot(Vector3.new(x_o, 0, y_o + 10)),
		epsilon, alpha, gamma,
		q_values
	)
	
	local r2 = Control.new(
		makeBot(Vector3.new(x_o + 10, 0, y_o)),
		epsilon, alpha, gamma,
		q_values
	)
	
	r1:setTarget(r2)
	r2:setTarget(r1)
	return {r1, r2}
end

local function movePair(p, i)
	local x_o = i % 10 * 150 - 750
	local y_o = (i - i % 10) * 15 - 750
	p[1].model:SetPrimaryPartCFrame(CFrame.new(x_o, 0, y_o + 10))
	p[2].model:SetPrimaryPartCFrame(CFrame.new(x_o + 10, 0, y_o))
end

local function makeWallX(x)
	local wall = Instance.new 'Part'
	wall.Position = Vector3.new(x, -5, 0)
	wall.Size = Vector3.new(1, 10, 2048)
	wall.Transparency = 0.5
	wall.Anchored = true
	wall.Parent = workspace
end

local function makeWallY(y)
	local wall = Instance.new 'Part'
	wall.Position = Vector3.new(0, -5, y)
	wall.Size = Vector3.new(2048, 10, 1)
	wall.Transparency = 0.5
	wall.Anchored = true
	wall.Parent = workspace
end

for i = -1024 + 75, 1024, 150 do
	makeWallX(i)
	makeWallY(i)
end

for i = 1, 100 do
	bots[i] = makePair(i)
end

for i, pair in ipairs(bots) do
	pair[1]:update()
	pair[2]:update()
end

local showDebugUI = true
local screen = Instance.new('ScreenGui')
local radius = 20
local l = math.sin(math.pi / util.N_ANG) * 2
local gui = {}
if showDebugUI then
	for d = 0, util.N_ANG - 1 do
		gui[d] = {}
		local theta = util.toTheta(d) + math.pi/2
		local sine = math.sin(theta)
		local cosine = math.cos(theta)
		for m = 0, util.N_MAG - 1 do
			local f = Instance.new('TextLabel')
			f.Size = UDim2.new(0, radius * m * l, 0, 20)
			f.Rotation = math.deg(theta) + 90
			f.Position = UDim2.new(0.5, radius * m * cosine, 0.5, radius * m * sine)
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Parent = screen
			gui[d][m] = f
		end
	end
	screen.Parent = game.StarterGui
end

game['Run Service'].Heartbeat:Connect(function()

	if showDebugUI then
		for m = 0, util.N_MAG - 1 do
			for d = 0, util.N_ANG - 1 do
				local mv = -math.huge
				local mx = 0
				for o = 0, util.N_ANG - 1 do
					local x = util.paramsToState(m, d, o)
					local v = q_values[util.bestQ(q_values, x)]
					if v > mv then
						mv = v
						mx = x
					end
				end
				gui[d][m].Text = tostring(math.floor(mv + 0.5))
			end
		end
	end

	for i, pair in ipairs(bots) do
		pair[1]:step()
		pair[2]:step()
	end
	for i, pair in ipairs(bots) do
		pair[1]:process()
		pair[2]:process()
	end
	for i, pair in ipairs(bots) do
		pair[1]:update()
		pair[2]:update()
	end
	local m = 0
	local d = 0
	local y = 0
	for i, pair in ipairs(bots) do
		local n = pair[1]:learn()
		m = m + n
		pair[2]:learn()
		if pair[1].dead or pair[2].dead then
			d = d + 1
			pair[1].model:Destroy()
			pair[2].model:Destroy()
			pair = makePair(i)
			pair[1]:update()
			pair[2]:update()
			bots[i] = pair
		elseif n > 30 then
			y = y + 1
			movePair(pair, i)
		end
	end
	print(d, y, m / #bots)
end)