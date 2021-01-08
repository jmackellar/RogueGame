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

local image1 = LG.newImage("/img/part/ripple2.png")
image1:setFilter("nearest", "nearest")

local ps = LG.newParticleSystem(image1, 1000)
ps:setColors(1, 1, 1, 1, 1, 1, 1, 0.95, 1, 1, 1, 0)
ps:setDirection(0)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(1)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(8, 4.0677967071533)
ps:setParticleLifetime(0.4198716878891, 0.63601869344711)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0, 1, 1.15)
ps:setSizeVariation(0)
ps:setSpeed(0, 0)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=1, blendMode="add", shader=nil, texturePath="ripple1.png", texturePreset="light", shaderPath="", shaderFilename=""})

return ps
