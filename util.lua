local NUM_MAGNITUDES = 30
local NUM_ANGLES = 8
local NUM_SWORD_STATES = 1
local NUM_STATES = NUM_MAGNITUDES * NUM_ANGLES * NUM_ANGLES

local ACT_MOVE = 9
local ACT_TURN = 3
local NUM_ACTIONS = ACT_MOVE * ACT_TURN

local pi = math.pi
local cos = math.cos
local sin = math.sin
local floor = math.floor
local max = math.max
local log = math.log
local rnd = math.random

local DIR = {
	[0] = Vector3.new()
}
for i = 1, ACT_MOVE - 1 do
	local theta = i * 2 * pi / (ACT_MOVE - 1)
	DIR[i] = Vector3.new(
		cos(theta),
		0,
		sin(theta)
	)
end

local util = {
	N_MAG = NUM_MAGNITUDES;
	N_ANG = NUM_ANGLES;
	DIR = DIR;
}

function util.saturateMag(mag)
	mag = floor(mag)
	if mag >= NUM_MAGNITUDES then
		mag = NUM_MAGNITUDES - 1
	elseif mag < 0 then
		mag = 0
	end
	return mag
end

function util.saturateAng(ang)
	ang = floor((ang / pi + 1)/2 * (NUM_ANGLES - 1) + 0.5)
	if ang < 0 then
		print('too small ang', ang)
	end
	if ang >= NUM_ANGLES then
		print('too big ang', ang)
	end
	return ang
end

function util.toTheta(ang)
	return (ang / NUM_ANGLES * 2 - 1) * pi
end

function util.paramsToState(mag, dir, ori)
--	print()
--	print('mag = ' .. mag)
--	print('dir = ' .. dir)
--	print('ori = ' .. ori)
	return mag + NUM_MAGNITUDES * (dir + NUM_ANGLES * ori)
end

function util.stateToParams(state)
	local mag = state % NUM_MAGNITUDES
	state = (state - mag) / NUM_MAGNITUDES
	local dir = state % NUM_ANGLES
	state = (state - dir) / NUM_ANGLES
	local ori = state
	return mag, dir, ori
end

function util.bestQ(q, x)
	x = x * NUM_ACTIONS
	local best_a = x + 1
	for a = x + 2, x + NUM_ACTIONS do
		if q[a] > q[best_a] then
			best_a = a
		end
	end
	return best_a
end

function util.qToAction(q)
	q = q - 1
	local a = q % NUM_ACTIONS
	local move = a % ACT_MOVE
	a = (a - move) / ACT_MOVE
	local turn = a
	return move, turn
end

function util.rndQ(q, x)
	return x * NUM_ACTIONS + rnd(1, NUM_ACTIONS)
end

function util.loadQ()
	local q_values = {}
	for i = 1, NUM_ACTIONS * NUM_STATES do
		q_values[i] = 0
	end
	return q_values
end

return util