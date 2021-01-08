--- Module File
local Creature = { }
--- Module variables
local CreatureImages = { }
local Creatures = { }
local CreatureTypes = { }
local ReferenceMap = false
local ReferenceStateGame = false
local CreatureCreatedIndex = 0

--- Load all module files
function Creature.loadAssets()
	print("Loading Creature Assets")
	local imagestoload = love.filesystem.getDirectoryItems("img/creature")
	for k,v in pairs(imagestoload) do 
		CreatureImages[string.sub(v, 1, string.len(v) - 4)] = love.graphics.newImage("img/creature/"..v)
	end
	local chunk = love.filesystem.load("dat/creatures.lua")
	CreatureTypes = chunk()
end

--- Called every frame to update Creatures
function Creature.update(dt)
	for i = # Creatures, 1, -1 do 
		if i > 1 and Creatures[i].y <= Creatures[i-1].y then 
			local temp = Creatures[i]
			Creatures[i] = Creatures[i-1]
			Creatures[i-1] = temp 
		end 
		if Creatures[i].dx ~= Creatures[i].x then 
			Creatures[i].dx = Creatures[i].dx + (Creatures[i].x - Creatures[i].dx) * dt * 15
		end
		if Creatures[i].dy ~= Creatures[i].y then 
			Creatures[i].dy = Creatures[i].dy + (Creatures[i].y - Creatures[i].dy) * dt * 15
		end
	end
end

--- Gets a reference to the other object controllers
function Creature.passHighLevelObjects(Map, StateGame)
	ReferenceMap = Map
	ReferenceStateGame = StateGame
end

--- Draw all creatures
function Creature.drawAllCreatures()
	local w, h = 0, 0
	for k,v in pairs(Creatures) do
		if ReferenceMap.isTileVisibleAt(v.x, v.y) then
			w = CreatureImages[v.img]:getWidth()
			h = CreatureImages[v.img]:getHeight()
			love.graphics.setColor(v.color[1], v.color[2], v.color[3])
			love.graphics.draw(CreatureImages[v.img], v.dx * 16 + 8, v.dy * 16 + 8, 0, 1, 1, w / 2, h / 2)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
end

--- Unequips an item in passed slot and returns it to the inventory
function Creature.removeItem(creature, slot)
	if creature.equipSlots and creature.equipSlots[slot] and creature.equipSlots[slot].equip then 
		local msg = ''
		local item = creature.equipSlots[slot].equip
		Creature.addItemToInventory(creature, item)
		creature.equipSlots[slot].equip = false 
		if creature == ReferenceStateGame.getPlayerCharacter() then 
			msg = 'You removed the ' .. ReferenceStateGame.getItem().getDisplayName(item) .. '.  '
		else 
			msg = Creature.getDisplayName(creature) .. ' removes the ' .. ReferenceStateGame.getItem().getDisplayName(item) .. '.  '
		end
		ReferenceStateGame.sendMessage({text = msg, color = {1, 1, 1}})
		Creature.waitTurn(creature)
	end
end

--- Takes a passed creature, item, and equip slot and attempts to equip
--- that item.  Checks if the creature has the appropriate equip slot,
--- if the slot is full then unequip the previous item and equip the new
--- item.  Returns true if item was equipped, false otherwise
function Creature.equipItem(creature, slot, item)
	if creature.equipSlots and creature.equipSlots[slot] then 
		local canEquipToSlot = false 
		if creature.equipSlots[slot].slot == 'mainhand' or creature.equipSlots[slot].slot == 'offhand' or creature.equipSlots[slot].slot == 'throwing' then 
			canEquipToSlot = true 
		elseif item.item.stats.equipSlot and creature.equipSlots[slot].slot == item.item.stats.equipSlot then 
			canEquipToSlot = true 
		end 
		if canEquipToSlot then 
			local removed = false 
			local msg = ''
			if creature.equipSlots[slot].equip then 
				removed = creature.equipSlots[slot].equip
				Creature.addItemToInventory(creature, creature.equipSlots[slot].equip)
			end 
			creature.equipSlots[slot].equip = item 
			Creature.removeItemFromInventory(creature, item)
			--- Message
			if creature == ReferenceStateGame.getPlayerCharacter() then 
				if removed then 
					msg = 'You removed the ' .. ReferenceStateGame.getItem().getDisplayName(removed) .. '.  '
				end
				msg = msg .. 'You equip the ' .. ReferenceStateGame.getItem().getDisplayName(item) ..'.'
			else 
				if removed then 
					msg = Creature.getDisplayName(creature) .. ' removes the ' .. ReferenceStateGame.getItem().getDisplayName(removed) .. '.  '
				end
				msg = msg .. Creature.getDisplayName(creature) .. ' equips the ' .. ReferenceStateGame.getItem().getDisplayName(item) .. '.'
			end
			ReferenceStateGame.sendMessage({text = msg, color = {1, 1, 1}})
			Creature.waitTurn(creature)
			return true
		end
	end
	return false
end

--- Load all creatuers
function Creature.loadAllCreatures(cx, cy, z)
	local fileName = 'creatures'
	local filePath = 'cdata/'.. cx ..'/' .. cy .. '/' .. z ..'/'
	local cdata = false
	local ic = false
	local itemData = false
	if love.filesystem.getInfo(filePath..fileName) then 
		cdata = ReferenceStateGame.getBitSer().loadLoveFile(filePath..fileName)
		if cdata then 
			for i = 1, # cdata do 
				ic = Creature.addNewCreature(cdata[i].type, cdata[i].x, cdata[i].y, cdata[i].z, cdata[i].cx, cdata[i].cy, true)
				ic.inventory = cdata[i].inventory
				ic.equipSlots = cdata[i].equipSlots
				ic.stats = cdata[i].stats 
				ic.moveCost = cdata[i].moveCost
				ic.currentHealth = cdata[i].currentHealth
				ic.color = cdata[i].color 
				ic.baseColor = cdata[i].baseColor
				ic.savedInventory = cdata[i].savedInventory
				ic.savedEquip = cdata[i].savedEquip
				if ic.savedInventory and # ic.savedInventory > 0 then 
					for k = 1, # ic.savedInventory do 
						itemData = ReferenceStateGame.getItem().createNewItem(ic.savedInventory[k].type)
						itemData.stats = ic.savedInventory[k].stats 
						itemData.mods = ic.savedInventory[k].mods
						if ic.savedInventory[k].container then 
							itemData.container = { }
							for j = 1, # ic.savedInventory[k].container do 
								local itemincont = ReferenceStateGame.getItem().createNewItem(ic.savedInventory[k].container[j].type)
								itemincont.stats = ic.savedInventory[k].container[j].stats 
								itemincont.mods = ic.savedInventory[k].container[j].mods 
								table.insert(itemData.container, {item = itemincont, x = 1, y = 1, stack = ic.savedInventory[k].container[j].stack})
							end
						end
						Creature.addItemToInventory(ic, {item = itemData, x = 1, y = 1, stack = ic.savedInventory[k].stack})
					end
					ic.savedInventory = false 
				end
				if ic.savedEquip and # ic.savedEquip > 0 then 
					for k = 1, # ic.savedEquip do 
						itemData = {item = ReferenceStateGame.getItem().createNewItem(ic.savedEquip[k].type), x = 1, y = 1, stack = ic.savedEquip[k].stack}
						itemData.stats = ic.savedEquip[k].stats
						itemData.mods = ic.savedEquip[k].mods
						Creature.equipItem(ic, ic.savedEquip[k].slot, itemData)
					end
					ic.savedEquip = false
				end
			end
		end
	end
end

--- Clear creatures
function Creature.clearAllCreatures()
	local player = ReferenceStateGame.getPlayerCharacter()
	Creatures = { }
	if player then 
		player.ReferenceStateGame = ReferenceStateGame
		table.insert(Creatures, player)
	end
end

--- Save Creatures to file coresponding to current world chunk info
function Creature.saveCreatures()
	local ctosave = { }
	local filePath = ''
	local fileName = ''
	local creature = { }
	local itemtosave = { }
	for i = 1, # Creatures do 
		Creatures[i].onHit = false
		Creatures[i].lastDamagedBy = false
		Creatures[i].curTarget = false
		Creatures[i].posTargets = { }
		Creatures[i].ReferenceStateGame = false
		if Creatures[i] ~= ReferenceStateGame.getPlayerCharacter() then 
			if # Creatures[i].inventory > 0 then 
				Creatures[i].savedInventory = { }
				for k = 1, # Creatures[i].inventory do 
					itemtosave = {type = Creatures[i].inventory[k].item.type, stats = Creatures[i].inventory[k].item.stats, mods = Creatures[i].inventory[k].item.mods, stack = Creatures[i].inventory[k].stack, x = 1, y = 1}
					if Creatures[i].inventory[k].item.container then 
						itemtosave.container = { }
						for j = 1, # Creatures[i].inventory[k].item.container do 
							local itemincont = { }
							itemincont.type = Creatures[i].inventory[k].item.type 
							itemincont.stats = Creatures[i].inventory[k].item.stats 
							itemincont.mods = Creatures[i].inventory[k].item.mods 
							itemincont.x = 1 
							itemincont.y = 1 
							itemincont.stack = Creatures[i].inventory[k].stack 
							table.insert(itemtosave.container, itemincont)
						end
					end
					table.insert(Creatures[i].savedInventory, itemtosave)
				end
				Creatures[i].inventory = { }
			end
			if Creatures[i].equipSlots and # Creatures[i].equipSlots > 0 then 
				Creatures[i].savedEquip = { }
				for k = 1, # Creatures[i].equipSlots do
					if Creatures[i].equipSlots[k].equip then 
						table.insert(Creatures[i].savedEquip, {type = Creatures[i].equipSlots[k].equip.item.type, slot = k, stats = Creatures[i].equipSlots[k].equip.item.stats, mods = Creatures[i].equipSlots[k].equip.item.mods, stack = Creatures[i].equipSlots[k].equip.stack, x = 1, y = 1})
						Creatures[i].equipSlots[k].equip = false
					end
				end 
			end
			table.insert(ctosave, Creatures[i])
		end 
	end 
	if # ctosave > 0 then 
		fileName = 'creatures'
		filePath = 'cdata/'.. ctosave[1].cx ..'/' .. ctosave[1].cy .. '/' .. ctosave[1].z ..'/'
		if not love.filesystem.getInfo(filePath) then
			love.filesystem.createDirectory(filePath)
		end
		ReferenceStateGame.getBitSer().dumpLoveFile(filePath .. fileName, ctosave)
	end
	Creature.clearAllCreatures()
end

--- Add new creature
function Creature.addNewCreature(creaturetype, x, y, z, cx, cy, override)
	local itemData = false
	local c = false
	if CreatureTypes[creaturetype] then 
		c = { }
		for k,v in pairs(CreatureTypes[creaturetype]) do 
			c[k] = v 
		end 
		c['x'] = x 
		c['y'] = y 
		c['z'] = z
		c['cx'] = cx 
		c['cy'] = cy
		c['dx'] = x 
		c['dy'] = y
		c['currentXP'] = 0
		c['attributePoints'] = 0
		c['currentMovementCost'] = c.moveCost or 100
		c['maxHealth'] = Creature.getMaxHealth(c)
		c['currentHealth'] = c.maxHealth
		c['maxStamina'] = Creature.getMaxStamina(c)
		c['currentStamina'] = c.maxStamina
		c['bodyTemp'] = 98
 		c['curTarget'] = false 
		c['posTargets'] = { }
		c['inventory'] = { }
		c['ReferenceStateGame'] = ReferenceStateGame
		if not override then 
			c['equipSlots'] = { 
				{slot = 'mainhand', equip = false, name = 'Main Hand'},
				{slot = 'offhand', equip = false, name = 'Off Hand'},
				{slot = 'ranged', equip = false, name = 'Ranged Weapon'},
				{slot = 'throwing', equip = false, name = 'Throwing Weapon'},
				{slot = 'head', equip = false, name = 'Helmet'},
				{slot = 'face', equip = false, name = 'Mask'},
				{slot = 'neck', equip = false, name = 'Neck'},
				{slot = 'back', equip = false, name = 'Back'},
				{slot = 'overshirt', equip = false, name = 'Chest Piece'},
				{slot = 'undershirt', equip = false, name = 'Undershirt'},
				{slot = 'gloves', equip = false, name = 'Gloves'},
				{slot = 'legs', equip = false, name = 'Leggings'},
				{slot = 'feet', equip = false, name = 'Shoes'},
			}
			if c.itemSpawn then 
				for i = 1, # c.itemSpawn do 
					if love.math.random(1, 100) <= c.itemSpawn[i].chance then 
						Creature.addItemToInventory(c, {item = ReferenceStateGame.getItem().createNewItem(c.itemSpawn[i].item), x = 1, y = 1, stack = love.math.random(c.itemSpawn[i].min, c.itemSpawn[i].max)})
					end
				end
			end
			if c.equipSpawn then 
				for i = 1, # c.equipSpawn do 
					if love.math.random(1, 100) <= c.equipSpawn[i].chance then
						itemData = {item = ReferenceStateGame.getItem().createNewItem(c.equipSpawn[i].item), x = 1, y = 1, stack = 1}
						local equipped = false
						for k = 1, # c.equipSlots do 
							if c.equipSlots[k].slot == c.equipSpawn[i].slot and not equipped then 
								--print(Creature.equipItem(c, k, itemData))
								c.equipSlots[k].equip = itemData
								equipped = true						
							end 
						end
					end
				end
			end
		end
		table.insert(Creatures, c)
	else 
		print('WARNING: Creature of type \''..creaturetype ..'\' doesn\'t exist')
	end
	return c 
end

--- Passed creature gains experience amount passed in and checks for levelup
function Creature.gainXP(creature, xp, xpLevel)
	xp = math.ceil(xp * 1 + Creature.getIntelligence(creature) / 100)
	if xpLevel < creature.stats.level - 5 then 
		xp = 0 
	elseif xpLevel <= creature.stats.level then 
		xp = math.floor(xp * (1 - (creature.stats.level - xpLevel) / 5))
	end 
	if xp <= 0 then 
		return 
	end
	creature.currentXP = creature.currentXP + xp 
	if ReferenceStateGame.getPlayerCharacter() == creature then
		ReferenceStateGame.sendMessage({text = 'You gain ' .. xp .. ' XP!', color = {0.85, 0.72, 0}})

	elseif ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 

	end
	if creature.currentXP >= Creature.getXPNeededToLevel(creature) then 
		creature.currentXP = math.max(0, creature.currentXP - Creature.getXPNeededToLevel(creature))
		creature.stats.level = creature.stats.level + 1 
		creature.attributePoints = creature.attributePoints + 1
		if ReferenceStateGame.getPlayerCharacter() == creature then 
			ReferenceStateGame.sendMessage({text = 'You gain a level!', color = {0.85, 0.72, 0}})
			ReferenceStateGame.emitParticlesAt('star1', creature.x, creature.y + 0.25, 35)
			ReferenceStateGame.emitParticlesAt('star2', creature.x, creature.y + 0.25, 35)
		elseif ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 
			ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' gains a level!', color = {0.85, 0.72, 0}})
			ReferenceStateGame.emitParticlesAt('star1', creature.x, creature.y + 0.25, 35)
			ReferenceStateGame.emitParticlesAt('star2', creature.x, creature.y + 0.25, 35)
		end
	end
end

--- Adds an item to the creatures inventory.  First check if the item can
--- stack with another, else add it direct to inventory.  Return true if the
--- item was added, false otherwise
function Creature.addItemToInventory(creature, item)
	local added = false
	if # creature.inventory == 0 then 
		added = true 
		table.insert(creature.inventory, item)
	else 
		if not item.item.stackable then 
			added = true 
			table.insert(creature.inventory, item)
		else 
			local stacked = false 
			for i = 1, # creature.inventory do 
				if ReferenceStateGame.tableContentCompare(creature.inventory[i].item.stats, item.item.stats) and creature.inventory[i].item.type == item.item.type then 
					creature.inventory[i].stack = creature.inventory[i].stack + item.stack 
					stacked = true 
					added = true 
					break 
				end
			end
			if not stacked then 
				added = true 
				table.insert(creature.inventory, item)
			end
		end
	end
	return added
end

--- Applies an item from the creatures inventory to another creature.  Does
--- not check for the items existance in the container beforehand.  
--- Returns the container.
function Creature.applyItemToCreature(creature, target, item)
	creature.inventory, item = ReferenceStateGame.getItem().applyItemFromContainer(item, creature.inventory, creature, target)
end

--- Applies an item from the creatures inventory to itself.  Does not check
--- for the items existance in the container beforehand.  Returns the container
function Creature.applyItemToSelf(creature, item)
	creature.inventory, item = ReferenceStateGame.getItem().applyItemFromContainer(item, creature.inventory, creature, creature)
end

--- Checks if creature has passed item in their inventory, and if so
--- removes it.  Returns true if removed, false otherwise
function Creature.removeItemFromInventory(creature, item)	
	local dropped = false 
	for i = 1, # creature.inventory do 
		if creature.inventory[i] == item then 
			dropped = true 
			table.remove(creature.inventory, i)
			break 
		end
	end
	return dropped
end

--- If the passed player character is capable of moving return false
--- Otherwise take one turn for every other creature
function Creature.takeTurn(playercreature)
	--- It's the player characters turn
	if playercreature.currentMovementCost <= 0 or not playercreature then 
		return false 
	--- Move all other creatures if they're off move cooldown
	else	
		ReferenceStateGame.getMap().incrementTime()
		for i = # Creatures, 1, -1 do 
			if Creatures[i].currentHealth <= 0 then 
				Creatures[i].currentHealth = 0
				Creature.killCreature(Creatures[i], Creatures[i].lastDamagedBy)
			end 
		end
		for k,v in pairs(Creatures) do 
			v.currentMovementCost = v.currentMovementCost - 1
			if v ~= playercreature and v.currentMovementCost <= 0 then 
				Creature.baseAI(v)
			end
		end
		--- Recursivly call this again if the player is unable to move
		--- otherwise the player would only be able to make inputs every
		--- few frames
		if playercreature.currentMovementCost > 0 and playercreature.currentHealth > 0 then 
			Creature.takeTurn(playercreature)
		end
	end
	ReferenceStateGame.getMap().redrawGameWorld()
end

--- Returns true if it is the passed player's creature turn to move
function Creature.isPlayersTurn(playercreature)
	if playercreature.currentMovementCost <= 0 then 
		return true 
	else 
		return false 
	end
end

--- Returns the sight radius of a creature based on time of day, location,
--- and any equipped light sources
function Creature.getSightRadius(creature)
	return 30
end

--- Ends a creatures turn and takes movement cost or action cost
function Creature.waitTurn(creature, actionCost)
	if not actionCost then 
		Creature.takeMoveCost(creature, creature.moveCost)
	else 
		Creature.takeMoveCost(creature, creature.actionCost) 
	end
end

--- Attempts to move a creature by passed dx, dy values
function Creature.moveBy(creature, dx, dy)
	if not creature then 
		return false 
	else 
		--- Check if creature is about to move offscreen or not
		local worldPos = ReferenceStateGame.getMap().getGameWorldPosition()
		if creature.x + dx < 2 or creature.x + dx > 80 or creature.y + dy < 2 or creature.y + dy > 40 then 
			if creature == ReferenceStateGame.getPlayerCharacter() then 
				local nwx = 0 
				local nwy = 0 
				if creature.x + dx < 2 then 
					nwx = -1 
				elseif creature.x + dx > 80 then 
					nwx = 1 
				end 
				if creature.y + dy < 2 then 
					nwy = -1 
				elseif creature.y + dy > 40 then 
					nwy = 1 
				end
				if ReferenceStateGame.getMap().switchGameWorldLoaded(worldPos[1] + nwx, worldPos[2] + nwy, worldPos[3]) then 
					if creature.x + dx < 2 then 
						creature.x = 80
					elseif creature.x + dx > 80 then 
						creature.x = 2
					end 
					if creature.y + dy < 2 then 
						creature.y = 40
					elseif creature.y+ dy > 40 then 
						creature.y = 2
					end
					creature.dx, creature.dy = creature.x, creature.y
					ReferenceStateGame.snapCameraToPlayerCharacter()
					return true
				else 
					ReferenceStateGame.sendMessage({text = "You would be lost heading that way.", color = {1, 1, 0.19}})
					return false
				end
			else 
				return false
			end
		end
		--- The destination tile is occupied by another creature
		local oc = Creature.isCreatureAt(creature.x + dx, creature.y + dy)
		if oc then 
			--- If the two creatures are of opposing faction then attack 
			--- the creature occupying the destination tile
			if Creature.getFactionRelationship(creature, oc) > 0 then 
				Creature.makeMeleeAttackAgainst(creature, oc)
				Creature.takeMoveCost(creature, creature.actionCost)
			--- Else check if the creature attempting to make the move is the
			--- player, in which case send a message to the log.
			else 
				Creature.checkForPlayerBumpMessage(creature, oc)
				Creature.takeMoveCost(creature, creature.moveCost)
			end
			return false 
		--- The destination tile is clear of creatures, next check the tile itself
		else 
			--- The tile blocks movement
			if ReferenceMap.doesTileBlockMovementAt(creature.x + dx, creature.y + dy) then 
				if ReferenceStateGame.getMap().interactWithDoor(creature.x + dx, creature.y + dy) then 
					Creature.takeMoveCost(creature, creature.actionCost)
				end
				return false 
			--- The tile doesnt block movement, move and add the movement cost
			else
				local nt = false
				creature.x = creature.x + dx 
				creature.y = creature.y + dy
				nt = ReferenceStateGame.getMap().getTileAt(creature.x, creature.y)
				if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) and nt.liquid and nt.liquid.amount > 2 then
					if nt.liquid.type == 'water' then 
						ReferenceStateGame.emitParticlesAt('water1', creature.x, creature.y, 25)
						ReferenceStateGame.emitParticlesAt('ripplewater1', creature.x, creature.y + 0.25, 1)
					elseif nt.liquid.type == 'blood' then 
						ReferenceStateGame.emitParticlesAt('blood2', creature.x, creature.y, 25)
						ReferenceStateGame.emitParticlesAt('rippleblood1', creature.x, creature.y + 0.25, 1)
					elseif nt.liquid.type == 'oil' then 
						ReferenceStateGame.emitParticlesAt('oil2', creature.x, creature.y, 25)
						ReferenceStateGame.emitParticlesAt('rippleoil1', creature.x, creature.y + 0.25, 1)
					elseif nt.liquid.type == 'waste' then 
						ReferenceStateGame.emitParticlesAt('waste1', creature.x, creature.y, 25)
						ReferenceStateGame.emitParticlesAt('ripplewaste1', creature.x, creature.y + 0.25, 1)
					end
				end
				Creature.takeMoveCost(creature, creature.moveCost)
			end
		end
	end
end

--- Heals the creature by a certain amount.
function Creature.addCurrentHealth(creature, amount)
	creature.currentHealth = math.min(creature.currentHealth + amount, Creature.getMaxHealth(creature))
	if creature == ReferenceStateGame.getPlayerCharacter() then 
		if creature.currentHealth > 0.9 * Creature.getMaxHealth(creature) then 
			Creature.setColor(creature, {1, 1, 1})
		elseif creature.currentHealth <= Creature.getMaxHealth(creature) * 0.25 then 
			Creature.setColor(creature, {1, 0.19, 0.19})
		elseif creature.currentHealth <= Creature.getMaxHealth(creature) * 0.5 then 
			Creature.setColor(creature, {1, 0.6, 0.19})
		elseif creature.currentHealth <= Creature.getMaxHealth(creature) * 0.75 then 
			Creature.setColor(creature, {1, 1, 0.19})
		end
	else 
		if creature.currentHealth > 0.35 * Creature.getMaxHealth(creature) then 
			Creature.setColor(creature, creature.baseColor)
		end
	end
end

--- Increments and manages the creatures cooldowns, regeneration...
function Creature.incrementTurnCooldowns(creature)
	if not creature.statCooldowns then 
		creature.statCooldowns = {healthRegen = 0, endRegen = 0}
	else 
		creature.statCooldowns.healthRegen = creature.statCooldowns.healthRegen - 1 
		if creature.statCooldowns.healthRegen <= 0 then 
			Creature.addCurrentHealth(creature, math.ceil(Creature.getVitality(creature) / 10))
			creature.statCooldowns.healthRegen = math.max(10, math.floor(25 - Creature.getVitality(creature) / 10))
		end
	end
end

--- Increases the cost until the creature can move again by passed amount cost
function Creature.takeMoveCost(creature, cost)
	creature.currentMovementCost = creature.currentMovementCost + cost 
	Creature.incrementTurnCooldowns(creature)
	if creature == ReferenceStateGame.getPlayerCharacter() then 
		ReferenceStateGame.incrementCurrentTurn()
	end
end

--- Check if the passed is the player, in which case send a message to the log
--- about the player bumping into the friendly pased oc
function Creature.checkForPlayerBumpMessage(creature, oc)
	if creature == ReferenceStateGame.getPlayerCharacter() then 
		ReferenceStateGame.sendMessage({text = 'You bump into ' .. Creature.getDisplayName(oc) ..'.', color = {0.78, 0.78, 0.78, 1}})
	end
end

--- Rolls passed dice function
function Creature.rollDice(dice)
	local result = 0 
	for i = 1, dice[1] do 
		result = result + love.math.random(1, dice[2]) + dice[3]
	end
	return result
end

--- Adds a target to creatures target list
function Creature.addTarget(creature, target)
	table.insert(creature.posTargets, target)
end

--- Forced melee attack against target tile and whatever occupies it
function Creature.forcedMeleeAttack(creature, x, y)
	local t = false 
	for k,v in pairs(Creatures) do 
		if v.x == x and v.y == y then 
			t = v
		end
	end
	if t then 
		Creature.makeMeleeAttackAgainst(creature, t)
		return true 
	else 
		return false
	end
end

--- Passed creature attempts to make a melee attempt at passed target
function Creature.makeMeleeAttackAgainst(creature, target, off)
	--- Damage!!!
	local damage = Creature.rollDice(Creature.getMeleeDamageDice(creature))
	if off then 
		local offchance = 25 
		if love.math.random(1, 100) > offchance then 
			return false 
		end
		damage = Creature.rollDice(Creature.getMeleeDamageDice(creature), true)
	end
	--- Animation
	creature.dx = creature.dx + (target.dx - creature.dx) / 1.5
	creature.dy = creature.dy + (target.dy - creature.dy) / 1.5
	--- Check if target creature dodges or not
	local roll = love.math.random(1, 20)
	if roll + Creature.getDexterity(creature) >= 12 + Creature.getDV(target) then 
		--- Attack hit the target, now check if the attack pierced targets armor
		roll = love.math.random(1, 20)
		if roll + Creature.getStrength(creature) >= 12 + Creature.getAV(target) then 
			--- Attack went through the targets armor, now check if the 
			--- target is wielding a shield or not
			local targetshield = Creature.getEquippedShield(target)
			local allowDamage = true 
			if targetshield then 
				--- Target managed to block the attack with their shield
				if love.math.random(1, 100) <= targetshield.item.stats.blockChance then 
					allowDamage = false 
					if creature == ReferenceStateGame.getPlayerCharacter() then 
						love.timer.sleep(0.02)
						ReferenceStateGame.screenShake(10)
						ReferenceStateGame.sendMessage({text = Creature.getDisplayName(target) .. ' blocks your attack!', color = {0.78, 0.78, 0.39, 1}})
						ReferenceStateGame.getEffect().addCombatText('*block*', target.x * 16 + 8, target.y * 16 - 8, {0.78, 0.78, 0.39, 1})
					elseif target == ReferenceStateGame.getPlayerCharacter() then 					
						ReferenceStateGame.sendMessage({text = 'You blocked the attack from ' .. Creature.getDisplayName(creature) .. '!', color = {0.68, 1, 0.68, 1}})
						ReferenceStateGame.getEffect().addCombatText('*block*', target.x * 16 + 8, target.y * 16 - 8, {0.68, 1, 0.68, 1})
					else 
						ReferenceStateGame.sendMessage({text = Creature.getDisplayName(target) .. ' blocks the attack from ' .. Creature.getDisplayName(creature) .. '!', color = {0.78, 0.78, 0.78}})
						ReferenceStateGame.getEffect().addCombatText('*block*', target.x * 16 + 8, target.y * 16 - 8, {0.78, 0.78, 0.78})
					end
				end
			end
			if allowDamage then 
				damage = Creature.takeDamage(target, damage, creature.stats.baseDamType or 'physical', creature)
				if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) or ReferenceStateGame.getMap().isTileVisibleAt(target.x, target.y) then 
					ReferenceStateGame.getEffect().addEffectSlash1(target.x, target.y, math.atan2((target.y - creature.y), (target.x - creature.x)))
					if creature == ReferenceStateGame.getPlayerCharacter() then 
						love.timer.sleep(0.02)
						ReferenceStateGame.screenShake(10)
						ReferenceStateGame.sendMessage({text = 'You hit ' .. Creature.getDisplayName(target) .. ' for ' .. damage .. ' damage!', color = {0.68, 0.68, 1, 1}})
						ReferenceStateGame.getEffect().addCombatText(tostring(damage), target.x * 16 + 8, target.y * 16 - 8, {0.19, 0.19, 1})
					elseif target == ReferenceStateGame.getPlayerCharacter() then 
						ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' hits you for ' .. damage .. ' damage!', color = {1, 0.68, 0.68, 1}})
						ReferenceStateGame.getEffect().addCombatText(tostring(damage), target.x * 16 + 8, target.y * 16 - 8, {1, 0.19, 0.19})
					else 
						ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' hits ' .. Creature.getDisplayName(target) .. ' for ' .. damage .. ' damage!', color = {255, 255, 255, 255}})
						ReferenceStateGame.getEffect().addCombatText(tostring(damage), target.x * 16 + 8, target.y * 16 - 8, {0.78, 0.78, 0.78})
					end
				end
				--- Dual wielding melee attacks 
				--- Roll for chance to strik with additional weapon
				if not off and target.currentHealth > 0 and creature.equipSlots and creature.equipSlots[2] and creature.equipSlots[2].equip then 
					--- If the creature is wielding a shield in the other hand
					--- then dont make an attack with that hand
					local shield = false 
					if creature.equipSlots[2].equip and creature.equipSlots[2].equip.stats and creature.equipSlots[2].equip.stats.shield then 
						shield = true 
					end 
					if not shield then 
						Creature.makeMeleeAttackAgainst(creature, target, true)
					end
				end
			end
		--- Attack was unable to pierce the targets armor
		else 
			if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) or ReferenceStateGame.getMap().isTileVisibleAt(target.x, target.y) then
				ReferenceStateGame.getEffect().addEffectSlash1(target.x, target.y, math.atan2((target.y - creature.y), (target.x - creature.x)))
				if creature == ReferenceStateGame.getPlayerCharacter() then 
					ReferenceStateGame.sendMessage({text = 'Your attack failed to pierce ' .. Creature.getDisplayName(target) .. '\'s armor!', color = {0.78, 0.78, 0.39, 1}})
					ReferenceStateGame.getEffect().addCombatText('*fail*', target.x * 16 + 8, target.y * 16 - 8, {1, 1, 0.19})
				elseif target == ReferenceStateGame.getPlayerCharacter() then 
					ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. '\'s attack failed to pierce your armor!', color = {0.68, 1, 0.68, 1}})
					ReferenceStateGame.getEffect().addCombatText('*fail*', target.x * 16 + 8, target.y * 16 - 8, {0.19, 1, 0.19})
				else 
					ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. '\'s attack failed to pierce ' .. Creature.getDisplayName(target) .. '\'s armor.', color = {1, 1, 1, 1}})
					ReferenceStateGame.getEffect().addCombatText('*fail*', target.x * 16 + 8, target.y * 16 - 8, {0.78, 0.78, 0.78})
				end
			end
		end
	--- Target creature succesfully dodged
	else 
		if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) or ReferenceStateGame.getMap().isTileVisibleAt(target.x, target.y) then
			if creature == ReferenceStateGame.getPlayerCharacter() then 
				ReferenceStateGame.sendMessage({text = 'You miss ' .. Creature.getDisplayName(target) .. '!', color = {0.78, 0.78, 0.19, 1}})
				ReferenceStateGame.getEffect().addCombatText('*dodge*', target.x * 16 + 8, target.y * 16 - 8, {1, 1, 0.19})
			elseif target == ReferenceStateGame.getPlayerCharacter() then 
				ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' misses you!', color = {0.68, 1, 0.68, 1}})
				ReferenceStateGame.getEffect().addCombatText('*dodge*', target.x * 16 + 8, target.y * 16 - 8, {0.19, 1, 0.19})
			else 
				ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' misses ' .. Creature.getDisplayName(target) .. '!', color = {1, 1, 1, 1}})
				ReferenceStateGame.getEffect().addCombatText('*dodge*', target.x * 16 + 8, target.y * 16 - 8, {0.78, 0.78, 0.78})
			end
		end
		target.dx = target.dx + (target.dx - creature.dx) / 1.5
		target.dy = target.dy + (target.dy - creature.dy) / 1.5
	end
	if not target.target then 
		table.insert(target.posTargets, creature)
	else 
		table.insert(target.posTargets, creature)
	end
end

--- Causes creature to take damage mitigated by armor.  Checks for death
function Creature.takeDamage(creature, damage, dtype, source)
	--- Damage reduction
	if dtype == 'physical' then 
		damage = math.max(1, damage - love.math.random(0, Creature.getAV(creature)))
	elseif dtype == 'electric' then 
		damage = math.max(1, damage - love.math.random(0, Creature.getElectricDefense(creature)))
	end
	--- Apply damage
	creature.currentHealth = creature.currentHealth - damage 
	creature.lastDamagedBy = source
	--- On hit affects
	if creature.onHit then 
		creature = creature.onHit(creature)
	end
	--- Blood/oil/etc liquid affects
	if not creature.stats.robotic then 
		ReferenceStateGame.getMap().dropLiquid('blood', 1, creature.x + love.math.random(-1,1), creature.y + love.math.random(-1,1))
		if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then
			ReferenceStateGame.emitParticlesAt('blood1', creature.x, creature.y, 35)
		end
	else 
		ReferenceStateGame.getMap().dropLiquid('oil', 1, creature.x + love.math.random(-1,1), creature.y + love.math.random(-1,1))
		if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then
			ReferenceStateGame.emitParticlesAt('oil1', creature.x, creature.y, 35)
		end
	end
	--- If the creatures tile is visible to the player then draw hit effects
	if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 
		--- Organic creatures = blood effect
		if not creature.stats.robotic then 
			ReferenceStateGame.getEffect().addEffectBlood1(creature.x, creature.y, love.math.random(314) / 100)
		--- Robotics creatures = oil effect
		else 
			ReferenceStateGame.getEffect().addEffectOil1(creature.x, creature.y, love.math.random(314) / 100)
		end
	end
	--- Change the color of creature based on its current health
	--- If creature is the player then health warning colors
	if creature == ReferenceStateGame.getPlayerCharacter() then 
		love.timer.sleep(0.02)
		ReferenceStateGame.screenShake(10)		
		if creature.currentHealth <= Creature.getMaxHealth(creature) * 0.25 then 
			Creature.setColor(creature, {1, 0.19, 0.19})
		elseif creature.currentHealth <= Creature.getMaxHealth(creature) * 0.5 then 
			Creature.setColor(creature, {1, 0.58, 0.19})
		elseif creature.currentHealth <= Creature.getMaxHealth(creature) * 0.75 then 
			Creature.setColor(creature, {1, 1, 0.19})
		end
	--- If creature is an organic NPC then color red when health is low
	else
		if not creature.stats.robotic and creature.currentHealth <= Creature.getMaxHealth(creature) * 0.35 then 
			Creature.setColor(creature, {1, 0.19, 0.19})
		end
	end
	--- Returns the amount of damage done after armor reductions
	return damage 
end

--- Removes the passed creature from the game
function Creature.killCreature(creature, source)
	local corpse = false
	if creature == ReferenceStateGame.getPlayerCharacter() then 
		ReferenceStateGame.sendMessage({text = 'You Died!', color = {1, 0.78, 0.78, 1}})
		ReferenceStateGame.playerDeathTriggered()
	else 
		if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 
			ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' dies!', color = {1, 1, 0.19, 1}})
		end
		if source then 
			Creature.gainXP(source, creature.xpWorth, creature.stats.level)
		end
	end
	if # creature.inventory > 0 then 
		for i = 1, # creature.inventory do 
			ReferenceStateGame.getItem().dropItemFromContainer(creature.inventory[i], creature.x, creature.y)
		end
	end
	if creature.equipSlots and # creature.equipSlots > 0 then 
		for i = 1, # creature.equipSlots do 
			if creature.equipSlots[i].equip then 
				ReferenceStateGame.getItem().dropItemFromContainer(creature.equipSlots[i].equip, creature.x, creature.y)
				creature.equipSlots[i].equip = false
			end
		end 
	end
	if not creature.stats.robotic then 
		corpse = ReferenceStateGame.getItem().createNewItem('corpse1')
		corpse.name = creature.name .. ' Corpse'
	else 
		corpse = ReferenceStateGame.getItem().createNewItem('scrap1')
		corpse.color = creature.color
		corpse.name = creature.name .. ' Scrap'
	end
	ReferenceStateGame.getItem().addItemToWorld(corpse, creature.x, creature.y, 1)
	for k,v in pairs(Creatures) do 
		if v == creature then 
			table.remove(Creatures, k)
			break 
		end
	end
end

--- Checks if passed position is occupied by any current creatures and returns
--- the creature if occupied
function Creature.isCreatureAt(x, y)
	for k,v in pairs(Creatures) do 
		if v.x == x and v.y == y then 
			return v
		end
	end
	return false
end

--- Sets a passed creatures color
function Creature.setColor(creature, color)
	creature.color = color
end

--- Checks the relationship status between 2 factions and returns the result
--- 0 = friendly
--- 1 = neutral
--- 2 = hostile
function Creature.getFactionRelationship(c1, c2)
	local relation = 1
	local fac1, fac2 = c1.faction, c2.faction
	local checker = {{fac1, fac2},{fac2, fac1}}
	for i = 1, 2 do
		--- Hostile to all
		if checker[i][1] == 'hostile' or checker[i][2] == 'hostile' then 
			relation = 2
		--- Punk relations 
		elseif checker[i][1] == 'punk' and (checker[i][2] == 'purgeunit' or
			checker[i][2] == 'robot' or checker[i][2] == 'corpo') then 
			relation = 2
		--- Insect relations
		elseif checker[i][1] == 'insect' and (checker[i][2] == 'player'
			or checker[i][2] == 'hunter' or checker[i][2] == 'laborer'
			or checker[i][2] == 'corpo') then 
			relation = 2
		--- Hunter relations
		elseif checker[i][1] == 'hunter' and checker[i][2] == 'herbivore' then 
			relation = 2
		--- corpo relations
		elseif checker[i][1] == 'corpo' and (checker[i][2] == 'punk' or
			checker[i][2] == 'insect' or checker[i][2] == 'hunter') then 
			relation = 2
		elseif checker[i][1] == 'corpo' and (checker[i][2] == 'laborer') then 
			relation = 0
		--- Robotic relations
		elseif checker[i][1] == 'robot' and (checker[i][2] == 'player' or 
			checker[i][2] == 'punk') then 
			relation = 2 
		elseif checker[i][1] == 'robot' and checker[i][2] == 'purgeunit' then 
			relation = 0
		--- Purge unit relations
		elseif checker[i][1] == 'purgeunit' and (checker[i][2] == 'player' or
			checker[i][2] == 'laborer' or checker[i][2] == 'hunter' or
			checker[i][2] == 'punk') then 
			relation = 2
		elseif checker[i][1] == 'purgeunit' and checker[i][2] == 'robot' then 
			relation = 0
		end
	end
	if fac1 == fac2 then 
		relation = 0
	end
	--- check if c1 or c2 are targets of each other
	for i = 1, 2 do 
		local c = c1
		local m = c2
		if i == 2 then 
			c = c2 
			m = c1
		end 
		if c.target == m then 
			relation = 2 
		end
		for j = 1, # c.posTargets do 
			if c.posTargets[j] == m then 
				relation = 2
				break 
			end 
		end 
	end
	return relation
end

---
--- AI
---

function Creature.baseAI(creature)
	local itemused = false
	if # creature.inventory > 0 then 
		for i = 1, # creature.inventory do 
			if creature.inventory[i].item.applicable and creature.inventory[i].item.aiCheck then 
				if creature.inventory[i].item.aiCheck(creature.inventory[i], creature, true) then 
					Creature.applyItemToSelf(creature, creature.inventory[i])
					Creature.waitTurn(creature, true)
					itemused = true 
					break
				elseif creature.inventory[i].item.aiCheck(creature.inventory[i], creature, false) then 
					Creature.applyItemToCreature(creature, creature.target, creature.inventory[i])
					Creature.waitTurn(creature, true)
					itemused = true 
					break
				end 
			end
		end
	end
	if not itemused then 
		if not creature.target then 
			if # creature.posTargets > 0 then 
				repeat
					creature.target = creature.posTargets[1] 
					table.remove(creature.posTargets, 1)
					if Creature.getCurrentHealth(creature.target) < 1 then 
						creature.target = false 
					end
				until creature.target or # creature.posTargets < 1
			else 
				Creature.scanForTargets(creature)
			end
			if love.math.random(1, 100) <= 25 then 
				Creature.moveBy(creature, love.math.random(-1, 1), love.math.random(-1, 1))
			else 
				Creature.waitTurn(creature, true)
			end
		else 
			local dx, dy = 0, 0 
			if Creature.getCurrentHealth(creature.target) <= 0 then 
				creature.target = false 
			end
			if creature.target then 
				--- Check for ranged weaponary 
				local wep = Creature.hasRangedWeaponEquipped(creature)
				local toMove = true
				if wep and wep.item and wep.item.stats and wep.item.stats.rangedWeapon then 
					if wep.item.stats.rangedWeapon.currentAmmo < 1 then 
						if Creature.reloadRangedWeapon(creature) then 
							Creature.waitTurn(creature, true)
							toMove = false 
						end 
					else 
						Creature.fireRangedWeapon(creature, creature.target.x, creature.target.y)
						toMove = false
					end
				end
				if toMove then 
					if creature.x < creature.target.x then 
						dx = 1 
					elseif creature.x > creature.target.x then 
						dx = -1 
					end 
					if creature.y < creature.target.y then 
						dy = 1
					elseif creature.y > creature.target.y then 
						dy = -1 
					end
					Creature.moveBy(creature, dx, dy)
				end
			else 
				Creature.waitTurn(creature, true)
			end
		end
	end
	if creature.currentMovementCost <= 0 then 
		Creature.waitTurn(creature) 
	end
end

function Creature.scanForTargets(creature)
	for i = 1, # Creatures do 
		if Creatures[i] ~= creature and Creature.getFactionRelationship(creature, Creatures[i]) > 1 then 
			if ReferenceStateGame.getMap().isLineOfSightClear(creature.x, creature.y, Creatures[i].x, Creatures[i].y) then 
				table.insert(creature.posTargets, Creatures[i])
			end
		end 
	end
end

function Creature.canSeePlayer(creature)
	if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 
		if ReferenceStateGame.getMap().isTileVisibleAt(ReferenceStateGame.getPlayerCharacter().x, ReferenceStateGame.getPlayerCharacter().y) then
			return true 
		end 
	end 
	return false
end

--- Takes passed stat key and checks through the creatures equipped items
--- returning the sum of the passed key.  Passed key value must be a number
function Creature.getEquippedStat(creature, stat)
	if not creature.equipSlots then 
		return 0
	end
	local sum = 0
	for i = 1, # creature.equipSlots do 
		if creature.equipSlots[i].slot ~= 'mainhand' and creature.equipSlots[i].slot ~= 'offhand' and creature.equipSlots[i].slot ~= 'ranged' and creature.equipSlots[i].slot ~= 'throwing' then 
			if creature.equipSlots[i].equip then 
				sum = sum + (creature.equipSlots[i].equip.item.stats[stat] or 0)
			end
		end
	end
	return sum
end

--- Fires a ranged weapon at creatureHit x,y possible.  Returns true if fired
--- false otherwise
function Creature.fireRangedWeapon(creature, creatureHitX, creatureHitY)
	local wep = Creature.hasRangedWeaponEquipped(creature)
	local bulletPath = false 
	local canHitcreatureHit = false 
	local creatureHit = false 
	local damage = false 
	local rot = math.atan2(creatureHitY - creature.y, creatureHitX - creature.x)
	local roll = 0
	--- If creature doesn't have a ranged weapon then cancel
	if not wep or not wep.item or not wep.item.stats or not wep.item.stats.rangedWeapon then 
		return false 
	end
	--- Calculate inaccuracy
	inaccuracy = wep.item.stats.rangedWeapon.inaccuracy * Creature.getRangedAccuracy(creature)
	rot = rot + love.math.random(inaccuracy * -100, inaccuracy * 100) / 100
	creatureHitX = creature.x + math.cos(rot) * 30
	creatureHitY = creature.y + math.sin(rot) * 30
	--- Fire the weapon
	if wep.item.stats.rangedWeapon and wep.item.stats.rangedWeapon.currentAmmo > 0 then 
		damage = Creature.rollDice(wep.item.stats.damage)
		bulletPath, canHitcreatureHit = ReferenceStateGame.getMap().bresenhamLine(creature.x, creature.y, creatureHitX, creatureHitY)
		wep.item.stats.rangedWeapon.currentAmmo = wep.item.stats.rangedWeapon.currentAmmo - 1	
		if ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 
			ReferenceStateGame.getEffect().addMuzzleFlash(creature.x + math.cos(rot) * 0.75, creature.y + math.sin(rot) * 0.75, rot)
		end
		--- Display a firing message if the player witnessed the event 
		if ReferenceStateGame.getPlayerCharacter() == creature then 
			ReferenceStateGame.screenShake(10)
			ReferenceStateGame.sendMessage({text = 'You fired the ' .. ReferenceStateGame.getItem().getDisplayName(wep) .. '!', color = {1, 1, 1, 1}})
		elseif ReferenceStateGame.getMap().isTileVisibleAt(creature.x, creature.y) then 
			ReferenceStateGame.sendMessage({text = Creature.getDisplayName(creature) .. ' fires the ' .. ReferenceStateGame.getItem().getDisplayName(wep) .. '!', color = {1, 1, 1, 1}})
		end
		if bulletPath then 
			--- Walk along the bulletpath checking for walls or creatures hit
			--- If collision with a creature then remove the rest of the bullets
			--- path.  Removing the path on a wall collision is not neccesary 
			for i = 1, # bulletPath do 
				if i > 1 then 
					--- Hit a wall
					if ReferenceStateGame.getMap().doesTileBlockMovementAt(bulletPath[i][1], bulletPath[i][2]) then 
						creatureHit = false 
						break 
					--- Creature in path of bullet, check if the 
					--- creature evades or not
					else 
						local ctocheck = Creature.isCreatureAt(bulletPath[i][1], bulletPath[i][2])
						if ctocheck then 
							roll = love.math.random(1, 20)
							--- creatureHit fails to evade
							if roll + 10 >= Creature.getDV(ctocheck) + 5 then 
								creatureHit = ctocheck
								for k = # bulletPath, i + 1, -1 do 
									table.remove(bulletPath, k)
								end
								break 
							--- creatureHit managed to evade the bullet
							else 
								if ReferenceStateGame.getPlayerCharacter() == ctocheck then 
									ReferenceStateGame.sendMessage({text = 'A bullet nearly grazes you!', color = {0.68, 1, 0.68, 1}})
									ReferenceStateGame.getEffect().addCombatText('*dodge*', creatureHit.x * 16 + 8, creatureHit.y * 16 - 8, {0.19, 1, 0.19})
								elseif ReferenceStateGame.getMap().isTileVisibleAt() then
									ReferenceStateGame.sendMessage({text = 'A bullet nearly grazes ' .. Creature.getDisplayName(ctocheck) .. '!', color = {0.78, 0.78, 0.39, 1}})
									ReferenceStateGame.getEffect().addCombatText('*dodge*', creatureHit.x * 16 + 8, creatureHit.y * 16 - 8, {1, 1, 0.19})
								end
							end
						end 
					end
				end
			end
			--- If a creature was found above then check if the shot
			--- is evaded, piereces armor, and how much damage it'll do
			if creatureHit then 
				--- Calculate creatureHit armor and attack penetration
				roll = love.math.random(1, 20)
				--- Attack hit the creatureHit, now check if the attack pierced creatureHits armor
				if roll + wep.item.stats.rangedWeapon.penetration >= 12 + Creature.getAV(creatureHit) then 
					damage = Creature.takeDamage(creatureHit, damage, 'physical', creature)
					--- Add the creature firing the weapon to the hit creatures creatureHits list
					--- and take damage
					if ReferenceStateGame.getPlayerCharacter() == creatureHit then 
						ReferenceStateGame.sendMessage({text = 'The bullet hits you for ' .. damage .. ' damage!', color = {1, 0.68, 0.68, 1}})
						ReferenceStateGame.getEffect().addCombatText(tostring(damage), creatureHit.x * 16 + 8, creatureHit.y * 16 - 8, {1, 0.19, 0.19})
					elseif ReferenceStateGame.getMap().isTileVisibleAt(creatureHit.x, creatureHit.y) then 
						love.timer.sleep(0.02)
						ReferenceStateGame.sendMessage({text = 'The bullet hits ' .. Creature.getDisplayName(creatureHit) .. ' for ' .. damage .. ' damage!', color = {0.68, 0.68, 1, 1}})
						ReferenceStateGame.getEffect().addCombatText(tostring(damage), creatureHit.x * 16 + 8, creatureHit.y * 16 - 8, {0.19, 0.19, 1})
					end
					table.insert(creatureHit.posTargets, creature)	
				--- Attack failed to pierce the creatureHits armor
				else
					if ReferenceStateGame.getPlayerCharacter() == creatureHit then 
						ReferenceStateGame.getEffect().addCombatText('*fail*', creatureHit.x * 16 + 8, creatureHit.y * 16 - 8, {0.19, 1, 0.19})
						ReferenceStateGame.sendMessage({text = 'The bullet fails to penetrate your armor!', color = {0.68, 1, 0.68, 1}})
					elseif ReferenceStateGame.getMap().isTileVisibleAt(creatureHit.x, creatureHit.y) then 
						ReferenceStateGame.sendMessage({text = 'The bullet fails to penetrate ' .. Creature.getDisplayName(creatureHit) .. "\'s armor!", color = {0.78, 0.78, 0.39, 1}})
						ReferenceStateGame.getEffect().addCombatText('*fail*', creatureHit.x * 16 + 8, creatureHit.y * 16 - 8, {1, 1, 0.19})
					end
				end 		
			end
		end
		--- Add visual effects and end the creatures turn
		--- Returning true since the creature fired
		ReferenceStateGame.getEffect().addProjectile('bullet1', bulletPath, rot, 150)
		Creature.waitTurn(creature)
		return true 
	end
	--- Creature didn't fire weapon for some reason
	--- Returning false
	return false 
end

--- If the passed creature has a ranged weapon equipped then 
--- attempt to reload it 
function Creature.reloadRangedWeapon(creature)
	local wep = Creature.hasRangedWeaponEquipped(creature)
	local ammoType = false 
	local reloaded = 0
	if not wep then 
		return false 
	end
	if wep.item.stats.rangedWeapon and wep.item.stats.rangedWeapon.ammoType then 
		ammoType = wep.item.stats.rangedWeapon.ammoType 
	end
	if # creature.inventory > 0 and wep.item.stats.rangedWeapon.currentAmmo < wep.item.stats.rangedWeapon.maxAmmo then 
		for i = # creature.inventory, 1, -1 do 
			if creature.inventory[i].item.type == ammoType then 
				repeat 
					reloaded = reloaded + 1
					wep.item.stats.rangedWeapon.currentAmmo = wep.item.stats.rangedWeapon.currentAmmo + 1
					creature.inventory[i].stack = creature.inventory[i].stack - 1 
				until creature.inventory[i].stack < 1 or wep.item.stats.rangedWeapon.currentAmmo >= wep.item.stats.rangedWeapon.maxAmmo
				if creature.inventory[i].stack <= 0 then 
					table.remove(creature.inventory, i)
				end
				if wep.item.stats.rangedWeapon.currentAmmo >= wep.item.stats.rangedWeapon.maxAmmo then 
					break 
				end
			end
		end 
	end
	if reloaded > 0 then 
		if ReferenceStateGame.getPlayerCharacter() == creature then 
			ReferenceStateGame.sendMessage({text = 'You reload your ' .. ReferenceStateGame.getItem().getDisplayName(wep), color = {1, 1, 1}})
		end
		Creature.waitTurn(creature)
	end
end

--- Checks if the creature has a ranged weapon equipped and if so
--- return the equipped item.  Else return false
function Creature.hasRangedWeaponEquipped(creature)
	if creature.equipSlots then 
		for i = 1, # creature.equipSlots do 
			if creature.equipSlots[i].slot == 'ranged' and creature.equipSlots[i].equip then 
				return creature.equipSlots[i].equip
			end 
		end 
	end 
	return false
end

---
--- Getters
---
function Creature.getCurrentBodyTemp(creature)
	return creature.bodyTemp 
end

function Creature.getDisplayName(creature)
	local n = creature.name 
	if not creature.hasProperNoun then 
		n = 'The ' .. n
	end
	return n
end

--- Checks if the creature has a shield equipped in an 
--- offhand slot and then returns the shield.  if no shield
--- is equipped then return false
function Creature.getEquippedShield(creature)
	if creature.equipSlots then 
		for i = 1, # creature.equipSlots do 
			if creature.equipSlots[i].slot == 'offhand' and creature.equipSlots[i].equip then 
				if creature.equipSlots[i].equip.item.stats and creature.equipSlots[i].equip.item.stats.shield then 
					return creature.equipSlots[i].equip
				end 
			end
		end
	end 
	return false
end

function Creature.getMeleeDamageDice(creature, offhand)
	if creature.equipSlots then 
		for  i = 1, # creature.equipSlots do 
			if not offhand and creature.equipSlots[i].slot == 'mainhand' and creature.equipSlots[i].equip then 
				if creature.equipSlots[i].equip.item.stats and creature.equipSlots[i].equip.item.stats.damage then 
					return creature.equipSlots[i].equip.item.stats.damage
				else
					return creature.stats.baseDam
				end
			elseif offhand and creature.equipSlots[i].slot == 'offhand' and creature.equipSlots[i].equip then 
				if creature.equipSlots[i].equip.item.stats and creature.equipSlots[i].equip.item.stats.damage then 
					return creature.equipSlots[i].equip.item.stats.damage
				else
					return creature.stats.baseDam
				end
			end 
		end 
	end
	return creature.stats.baseDam
end

function Creature.getXPNeededToLevel(creature)
	return 250 + 250 * creature.stats.level
end

function Creature.getRangedAccuracy(creature)
	return math.max(0.15, 1 - (Creature.getDexterity(creature) * 2) / 100)
end

function Creature.getAV(creature)
	return creature.stats.baseAV + Creature.getEquippedStat(creature, 'av')
end 

function Creature.getDV(creature)
	return creature.stats.baseDV + Creature.getEquippedStat(creature, 'dv')
end

function Creature.getVitality(creature)
	return creature.stats.vitality 
end

function Creature.getEndurance(creature)
	return creature.stats.endurance 
end

function Creature.getStrength(creature)
	return creature.stats.strength 
end 

function Creature.getDexterity(creature)
	return creature.stats.dexterity 
end

function Creature.getIntelligence(creature)
	return creature.stats.intelligence or 4
end

function Creature.getResolve(creature)
	return creature.stats.resolve 
end

function Creature.getMaxHealth(creature)
	return Creature.getVitality(creature) + math.ceil(Creature.getVitality(creature) / 4) * creature.stats.level
end

function Creature.getMaxStamina(creature)
	return Creature.getEndurance(creature) * 2
end

function Creature.getMoveCost(creature) 
	return creature.moveCost 
end 

function Creature.getActionCost(creature)
	return creature.actionCost 
end

function Creature.getElectricDefense(creature)
	return 0 
end

function Creature.getPosition(creature) return creature.x, creature.y end
function Creature.getDrawPosition(creature) return creature.dx, creature.dy end
function Creature.getX(creature) return creature.x  end
function Creature.getY(creature) return creature.y  end
function Creature.getCurrentHealth(creature) return creature.currentHealth end
function Creature.getCurrentStamina(creature) return creature.currentStamina end
function Creature.getInventory(creature) return creature.inventory end

---
---
---
return Creature