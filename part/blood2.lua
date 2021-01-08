--[[
module = {
	{
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1
	},
	{ system=particleSystem2, ... },
	...
}
]]
local LG        = love.graphics
local particles = {}

local image1 = LG.newImage("img/part/blood2.png")
image1:setFilter("nearest", "nearest")

local ps = LG.newParticleSystem(image1, 1000)
ps:setColors(1, 1, 1, 1, 0.8, 0.8, 0.8, 1, 0, 0, 0, 1)
ps:setDirection(0)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(0)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(-0.0095107769593596, 0.032802477478981)
ps:setOffset(2, 2)
ps:setParticleLifetime(0.4198716878891, 0.46971595287323)
ps:setRadialAcceleration(-7.8609485626221, 11.742897987366)
ps:setRelativeRotation(false)
ps:setRotation(-6.2713165283203, 0)
ps:setSizes(1, 1, 0, 0)
ps:setSizeVariation(0.25233644247055)
ps:setSpeed(18.652769088745, 77.037292480469)
ps:setSpin(-0.74197453260422, 0.98783594369888)
ps:setSpinVariation(0.35514017939568)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(-21.835968017578, 16.401237487793)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=5, blendMode="add", shader=nil, texturePath="water1.png", texturePreset="light", shaderPath="", shaderFilename=""})

return ps
