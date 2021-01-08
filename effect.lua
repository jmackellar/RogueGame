--- Module File
local Effect = { }
--- Effect Library
local anim8 = require("/lib/anim8")
--- Effect Variables
local ReferenceStateGame = false
local effects = { }
local effectImages = { }
local effectGrids = { }
local effectAnimations = { }
local combatText = { }
local projectiles = { }

--- Load all effect assets
function Effect.loadAssets()
	print("Loading Effect Assets")
	local imagestoload = love.filesystem.getDirectoryItems("img/effect")
	for k,v in pairs(imagestoload) do 
		effectImages[string.sub(v, 1, string.len(v) - 4)] = love.graphics.newImage("img/effect/"..v)
		effectGrids[string.sub(v, 1, string.len(v) - 4)] = anim8.newGrid(16, 16, effectImages[string.sub(v, 1, string.len(v) - 4)]:getWidth(), effectImages[string.sub(v, 1, string.len(v) - 4)]:getHeight())
	end
end

function Effect.passHighLevelObjects(stateGame)
	ReferenceStateGame = stateGame
end

--- Update all effects
function Effect.update(dt)
	for i = # effects, 1, -1 do 
		effects[i].anim:update(dt)
		if effects[i].anim:getCurrentFrame() == effects[i].endFrame then 
			table.remove(effects, i)
		end
	end
	Effect.updateProjectiles(dt)
	Effect.updateCombatText(dt)
end

--- Draw all effects
function Effect.draw()
	for i = 1, # effects do 
		effects[i].anim:draw(effects[i].img, effects[i].x * 16 + 8, effects[i].y * 16 + 8, effects[i].rot, 1, 1, 8, 8)
	end
	Effect.drawProjectiles()
	Effect.drawCombatText()
end

---
--- Projectiles
---
function Effect.drawProjectiles()
	for i = 1, # projectiles do 
		if ReferenceStateGame.getMap().isTileVisibleAt(projectiles[i].path[math.floor(projectiles[i].step)][1], projectiles[i].path[math.floor(projectiles[i].step)][2]) then
			love.graphics.draw(effectImages[projectiles[i].type], projectiles[i].path[math.floor(projectiles[i].step)][1] * 16 + 8, projectiles[i].path[math.floor(projectiles[i].step)][2] * 16 + 8, projectiles[i].rot, 1, 1, 8, 8)
		end
	end
end

function Effect.updateProjectiles(dt)
	for i = # projectiles, 1, -1 do 
		projectiles[i].step = projectiles[i].step + dt * projectiles[i].speed 
		if projectiles[i].path[math.floor(projectiles[i].step)] and 
			ReferenceStateGame.getMap().isTileVisibleAt(projectiles[i].path[math.floor(projectiles[i].step)][1], projectiles[i].path[math.floor(projectiles[i].step)][2]) then
			ReferenceStateGame.emitParticlesAt('smoke1', projectiles[i].path[math.floor(projectiles[i].step)][1], projectiles[i].path[math.floor(projectiles[i].step)][2], 5)
		end
		if (math.floor(projectiles[i].step) > # projectiles[i].path) then 
			table.remove(projectiles, i)
		end
	end
end

function Effect.addProjectile(proj, path, rot, speed)
	table.insert(projectiles, {type = proj, path = path, step = 1, rot = rot, speed = speed})
end

---
--- Combat Text
---

function Effect.addCombatText(text, x, y, color)
	table.insert(combatText, {text = text, x = x, y = y, timer = 1, color = color})
end

function Effect.drawCombatText()
	love.graphics.setFont(ReferenceStateGame.getFonts().slkscr8)
	for i = 1, # combatText do 
		love.graphics.setColor(combatText[i].color[1], combatText[i].color[2], combatText[i].color[3])
		love.graphics.printf(combatText[i].text, combatText[i].x - 150, combatText[i].y, 300, "center")
	end
	love.graphics.setColor(1, 1, 1, 1)
end 

function Effect.updateCombatText(dt)
	for i = # combatText, 1, -1 do 
		combatText[i].y = combatText[i].y - (10 + combatText[i].timer * 10) * dt 
		combatText[i].timer = combatText[i].timer - dt 
		if combatText[i].timer <= 0 then 
			table.remove(combatText, i)
		end
	end
end

---
--- Effects
---

function Effect.addMuzzleFlash(x, y, rot)
	local anim = anim8.newAnimation(effectGrids['muzzleflash1']('1-6',1), 0.065)
	table.insert(effects, {anim = anim, img = effectImages.muzzleflash1, endFrame = 5, x = x, y = y, rot = rot})
end

function Effect.addEffectOil1(x, y, rot)
	local anim = anim8.newAnimation(effectGrids['oil1']('1-5',1), 0.1)
	table.insert(effects, {anim = anim, img = effectImages.oil1, endFrame = 4, x = x, y = y, rot = rot})
end

function Effect.addEffectBlood1(x, y, rot)
	local anim = anim8.newAnimation(effectGrids['blood1']('1-5',1), 0.1)
	table.insert(effects, {anim = anim, img = effectImages.blood1, endFrame = 4, x = x, y = y, rot = rot})
end

function Effect.addEffectSlash1(x, y, rot)
	local anim = anim8.newAnimation(effectGrids['slash1']('1-5',1), 0.1)
	table.insert(effects, {anim = anim, img = effectImages.slash1, endFrame = 4, x = x, y = y, rot = rot})
end

---
--- Getters
---

function Effect.getAreEffectsPlaying() 
	if # effects > 0 or # projectiles > 0 then 
		return true 
	else 
		return false 
	end
end 

return Effect