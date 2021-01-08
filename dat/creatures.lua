local creatures = { }

creatures.player = { 
	type = 'player',
	name = 'Player',
	img = 'player',
	color = {1, 1, 1},
	baseColor = {1, 1, 1},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 1, 
		vitality = 15, 
		endurance = 10, 
		strength = 10, 
		dexterity = 10, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 0, 
		baseDV = 0, 
		baseDam = {1,2,0}
	},
	faction = 'player',
	xpWorth = 100,
}

creatures.knight = {
	type = 'knight',
	name = 'knight',
	img = 'knight1',
	color = {1, 0.64, 0.58},
	baseColor = {1, 0.64, 0.58},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 10,
		vitality = 12,
		endurance = 14,
		strength = 15,
		dexterity = 10,
		intelligence = 7,
		resolve = 9,
		baseAV = 0,
		baseDV = 0,
		baseDam = {1,3,0},
	},
	faction = 'military',
	xpWorth = 250,
	itemSpawn = {
		{item = 'healthneedle', min = 1, max = 2, chance = 15},
	},
	equipSpawn = {
		{item = 'longsword', slot = 'mainhand', chance = 100},
		{item = 'plasteelsaber', slot = 'mainhand', chance = 25},
		{item = 'longsword', slot = 'mainhand', chance = 25},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'kevlarvest', slot = 'overshirt', chance = 100},
		{item = 'worncloak', slot = 'back', chance = 100},
		{item = 'leathergloves', slot = 'gloves', chance = 100},
		{item = 'denimjeans', slot = 'legs', chance = 100},
	},
}

creatures.soldier = {
	type = 'soldier',
	name = 'soldier',
	img = 'soldier1',
	color = {0.73, 0.65, 0.88},
	baseColor = {0.73, 0.65, 0.88},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 8,
		vitality = 10,
		endurance = 12,
		strength = 11,
		dexterity = 14,
		intelligence = 8,
		resolve = 7,
		baseAV = 0,
		baseDV = 0,
		baseDam = {1,3,0},
	},
	faction = 'military',
	xpWorth = 250,
	itemSpawn = {
		{item = 'bullet', min = 24, max = 34, chance = 100},
		{item = 'healthneedle', min = 1, max = 2, chance = 5},
	},
	equipSpawn = {
		{item = 'longsword', slot = 'mainhand', chance = 100},
		{item = 'switchblade', slot = 'offhand', chance = 25},
		{item = 'ballisticpistol', slot = 'ranged', chance = 100},
		{item = 'ballisticrifle', slot = 'ranged', chance = 15},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'worncloak', slot = 'back', chance = 100},
		{item = 'leathergloves', slot = 'gloves', chance = 100},
		{item = 'denimjeans', slot = 'legs', chance = 100},
	},
}

creatures.giantbeast = {
	type = 'giantbeast',
	name = 'giant beast',
	img = 'giant1',
	color = {0.85, 0.85, 0.85},
	baseColor = {0.85, 0.85, 0.85},
	moveCost = 75,
	actionCost = 125,
	stats = {
		level = 10,
		vitality = 14,
		endurance = 12,
		strength = 15,
		dexterity = 9,
		intelligence = 5,
		resolve = 8,
		baseAV = 5,
		baseDV = -3,
		baseDam = {2,4,0},
	},
	faction = 'visitor',
	xpWorth = 400,
}

creatures.enforcerdroid = {
	type = 'enforcerdroid',
	name = 'enforcer droid',
	img = 'mobileturret',
	color = {0.64, 0.91, 0.87},
	baseColor = {0.64, 0.91, 0.87},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 10,
		vitality = 10,
		endurance = 10,
		strength = 10,
		dexterity = 15,
		intelligence = 10,
		resolve = 10,
		baseAV = 4,
		baseDV = 0,
		baseDam = {2,3,0},
		baseDamType = 'electric',
		robotic = true,
	},
	faction = 'purgeunit',
	xpWorth = 350,
	itemSpawn = {
		{item = 'bullet', min = 35, max = 55, chance = 100},
	},
	equipSpawn = {
		{item = 'ballisticrifle', slot = 'ranged', chance = 100},
	},
}

creatures.teslabot = {
	type = 'teslabot',
	name = 'teslabot',
	img = 'bigbot',
	color = {0.65, 0.85, 0.15},
	baseColor = {0.65, 0.85, 0.15},
	moveCost = 65,
	actionCost = 100,
	stats = {
		level = 16, 
		vitality = 14, 
		endurance = 15, 
		strength = 16, 
		dexterity = 12, 
		intelligence = 13, 
		resolve = 10,
		baseAV = 6, 
		baseDV = 4, 
		baseDam = {3,3,0}, 
		robotic = true, 
		baseDamType = 'electric',
	},
	faction = 'robot',
	xpWorth = 500,
}

creatures.scoutbot = {
	type = 'scoutbot',
	name = 'scoutbot',
	img = 'scoutbot',
	color = {0.25, 0.35, 0.85},
	baseColor = {0.25, 0.35, 0.85},
	moveCost = 65,
	actionCost = 100,
	stats = {
		level = 1, 
		vitality = 7, 
		endurance = 15, 
		strength = 7, 
		dexterity = 12, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 2, 
		baseDV = 3, 
		baseDam = {1,5,0}, 
		robotic = true, 
		baseDamType = 'electric',
	},
	faction = 'robot',
	xpWorth = 150,
}

creatures.heavypunk = {
	type = 'heavypunk',
	name = 'heavy punk',
	img = 'punk1',
	color = {0.54, 0.84, 0.29},
	baseColor = {0.54, 0.84, 0.29},
	moveCost = 100,
	actionCost = 50,
	stats = {
		level = 6, 
		vitality = 9, 
		endurance = 12, 
		strength = 9, 
		dexterity = 13, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 0, 
		baseDV = -0, 
		baseDam = {1,2,0}
	},
	faction = 'punk',
	itemSpawn = {
		{item = 'healthneedle', min = 1, max = 2, chance = 55},
		{item = 'deathneedle', min = 1, max = 1, chance = 5},
		{item = 'staminaneedle', min = 1, max = 1, chance = 25},
	},
	equipSpawn = {
		{item = 'switchblade', slot = 'mainhand', chance = 100},
		{item = 'switchblade', slot = 'offhand', chance = 100},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'leatherjacket', slot = 'overshirt', chance = 100},
		{item = 'leathergloves', slot = 'gloves', chance = 100},
		{item = 'worncloak', slot = 'back', chance = 100},
		{item = 'cleatedboots', slot = 'feet', chance = 100},
	},
	xpWorth = 250,
}

creatures.punk = {
	type = 'punk',
	name = 'punk',
	img = 'punk1',
	color = {0.84, 0.54, 0.29},
	baseColor = {0.84, 0.54, 0.29},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 1, 
		vitality = 6, 
		endurance = 10, 
		strength = 8, 
		dexterity = 8, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 0, 
		baseDV = -0, 
		baseDam = {1,2,0}
	},
	faction = 'punk',
	itemSpawn = {
		{item = 'healthneedle', min = 1, max = 2, chance = 35},
		{item = 'deathneedle', min = 1, max = 1, chance = 5},
		{item = 'staminaneedle', min = 1, max = 1, chance = 20},
	},
	equipSpawn = {
		{item = 'switchblade', slot = 'mainhand', chance = 100},
		{item = 'switchblade', slot = 'offhand', chance = 50},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'leatherjacket', slot = 'overshirt', chance = 80},
		{item = 'cleatedboots', slot = 'feet', chance = 100},
	},
	xpWorth = 100,
}

creatures.manager = {
	type = 'manager',
	name = 'manager',
	img = 'corpo1',
	color = {0.64, 0.69, 0.95},
	baseColor = {0.64, 0.69, 0.95},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 10, 
		vitality = 12, 
		endurance = 12, 
		strength = 15, 
		dexterity = 13,
		intelligence = 9, 
		resolve = 7,
		baseAV = 0, 
		baseDV = 0, 
		baseDam = {1,3,0}
	},
	itemSpawn = {
		{item = 'bullet', min = 12, max = 24, chance = 100},
		{item = 'healthneedle', min = 1, max = 2, chance = 15},
	},
	equipSpawn = {
		{item = 'longsword', slot = 'mainhand', chance = 100},
		{item = 'ballisticpistol', slot = 'ranged', chance = 100},
		{item = 'clothshirt', slot = 'undershirt', chance = 100},
		{item = 'worncloak', slot = 'back', chance = 100},
		{item = 'leathergloves', slot = 'gloves', chance = 100},
		{item = 'denimjeans', slot = 'legs', chance = 100},
	},
	faction = 'corpo',
	xpWorth = 150,
}

creatures.foreman = {
	type = 'foreman',
	name = 'foreman',
	img = 'poor1',
	color = {0.64, 0.89, 0.25},
	baseColor = {0.64, 0.89, 0.25},
	moveCost = 100,
	actionCost = 75,
	stats = {
		level = 6, 
		vitality = 10, 
		endurance = 12, 
		strength = 15, 
		dexterity = 11,
		intelligence = 7, 
		resolve = 6,
		baseAV = 0, 
		baseDV = 0, 
		baseDam = {1,3,0}
	},
	equipSpawn = {
		{item = 'hoe', slot = 'mainhand', chance = 100},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'worncloak', slot = 'back', chance = 100},
		{item = 'leathergloves', slot = 'gloves', chance = 100},
		{item = 'denimjeans', slot = 'legs', chance = 100},
	},
	faction = 'laborer',
	xpWorth = 150,
}

creatures.laborer = {
	type = 'laborer',
	name = 'laborer',
	img = 'poor1',
	color = {0.44, 0.69, 0.55},
	baseColor = {0.44, 0.69, 0.55},
	moveCost = 100,
	actionCost = 75,
	stats = {
		level = 1, 
		vitality = 6, 
		endurance = 8, 
		strength = 11, 
		dexterity = 11,
		intelligence = 8, 
		resolve = 5,
		baseAV = 0, 
		baseDV = 0, 
		baseDam = {1,3,0}
	},
	equipSpawn = {
		{item = 'switchblade', slot = 'mainhand', chance = 25},
		{item = 'woodenbuckler', slot = 'offhand', chance = 25},
		{item = 'polyestershirt', slot = 'undershirt', chance = 80},
		{item = 'denimjeans', slot = 'legs', chance = 80},
	},
	faction = 'laborer',
	xpWorth = 50,
}

creatures.survivalist = {
	type = 'survivalist',
	name = 'survivalist',
	img = 'human',
	color = {0.78, 0.28, 0.79},
	baseColor = {0.78, 0.28, 0.79},
	moveCost = 80,
	actionCost = 75,
	stats = {
		level = 8, 
		vitality = 11, 
		endurance = 12, 
		strength = 12, 
		dexterity = 16,
		intelligence = 10, 
		resolve = 10,
		baseAV = 2, 
		baseDV = 2, 
		baseDam = {1,2,0}
	},
	faction = 'hunter',
	itemSpawn = {
		{item = 'bullet', min = 32, max = 52, chance = 100},
		{item = 'healthneedle', min = 1, max = 2, chance = 35},
		{item = 'staminaneedle', min = 1, max = 2, chance = 10},
	},
	equipSpawn = {
		{item = 'longsword', slot = 'mainhand', chance = 100},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'leatherjacket', slot = 'overshirt', chance = 100},
		{item = 'denimjeans', slot = 'legs', chance = 100},
		{item = 'leathergloves', slot = 'gloves', chance = 100},
		{item = 'huntingrifle', slot = 'ranged', chance = 100},
	},
	xpWorth = 250,
}

creatures.hunter = {
	type = 'hunter',
	name = 'hunter',
	img = 'human',
	color = {0.78, 0.78, 0.39},
	baseColor = {0.78, 0.78, 0.39},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 1, 
		vitality = 11, 
		endurance = 8, 
		strength = 9, 
		dexterity = 9,
		intelligence = 10, 
		resolve = 10,
		baseAV = 2, 
		baseDV = 2, 
		baseDam = {1,2,0}
	},
	faction = 'hunter',
	itemSpawn = {
		{item = 'bullet', min = 8, max = 16, chance = 100},
	},
	equipSpawn = {
		{item = 'longsword', slot = 'mainhand', chance = 100},
		{item = 'polyestershirt', slot = 'undershirt', chance = 100},
		{item = 'leatherjacket', slot = 'overshirt', chance = 100},
		{item = 'huntingrifle', slot = 'ranged', chance = 100},
	},
	xpWorth = 100,
}

creatures.worm = {
	type = 'worm',
	name = 'Enlarged Worm',
	img = 'worm1',
	color = {0.85, 0.45, 0.45},
	baseColor = {0.85, 0.45, 0.45},
	moveCost = 100,
	actionCost = 125,
	stats = {
		level = 5,
		vitality = 14,
		endurance = 8,
		strength = 10,
		dexterity = 7,
		intelligence = 4,
		resolve = 4,
		baseAV = 3,
		baseDV = -2,
		baseDam = {1,5,0},
	},
	faction = 'insect',
	xpWorth = 50,
	onHit =	function (self)
				if self.currentHealth > 1 then 				
					local placed = false
					local tries = 0
					local radius = 0	
					repeat 
						radius = radius + 1
						for x = self.x - radius, self.x + radius do 
							for y = self.y - radius, self.y + radius do 
								tries = tries + 1
								if x > 0 and x < 81 and y > 0 and y < 41 and not placed and
									not self.ReferenceStateGame.getMap().doesTileBlockMovementAt(x, y) and 
									not self.ReferenceStateGame.getCreature().isCreatureAt(x, y) then 
									local wpos = self.ReferenceStateGame.getMap().getGameWorldPosition()
									local div = self.ReferenceStateGame.getCreature().addNewCreature("worm", x, y, self.z, wpos[1], wpos[2])
									placed = true 
									div.currentHealth = self.currentHealth
									div.currentHealth = math.max(1, math.floor(div.currentHealth / 2))
									self.currentHealth = math.max(1, math.floor(self.currentHealth / 2))
									div.xpWorth = math.max(1, math.floor(div.xpWorth / 2))
									self.xpWorth = math.max(1, math.floor(self.xpWorth / 2))
									break
								end 
							end 
							if tries > 50 then 
								break 
							end
						end
					until placed
					if self.ReferenceStateGame.getMap().isTileVisibleAt(self.x, self.y) then 
						self.ReferenceStateGame.sendMessage({text = 'The worm divides!', color = {1, 1, 1}})
					end
				end
				return self
			end,
}

creatures.moth = {
	type = 'moth',
	name = 'Large Moth',
	img = 'moth1',
	color = {0.78, 0.78, 0.1},
	baseColor = {0.78, 0.78, 0.1},
	moveCost = 100,
	actionCost = 100,
	stats = {
		level = 1, 
		vitality = 4,
		endurance = 10, 
		strength = 7, 
		dexterity = 8, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 0, 
		baseDV = 2, 
		baseDam = {1,3,0}
	},
	faction = 'insect',
	xpWorth = 25,
}

creatures.turtle = {
	type = 'turtle',
	name = 'Turtle',
	img = 'turtle',
	color = {0.6, 0.81, 0.35},
	baseColor = {0.6, 0.81, 0.35},
	moveCost = 200,
	actionCost = 200,
	stats = {
		level = 1,
		vitality = 11, 
		endurance = 10, 
		strength = 15, 
		dexterity = 5, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 5, 
		baseDV = 0, 
		baseDam = {2,3,0}
	},
	faction = 'herbivore',
	xpWorth = 75,
}

creatures.deer = {
	type = 'deer',
	name = 'Deer',
	img = 'deer',
	color = {0.87, 0.62, 0.4},
	baseColor = {0.87, 0.62, 0.4},
	moveCost = 75,
	actionCost = 100,
	stats = {
		level = 1, 
		vitality = 6, 
		endurance = 10, 
		strength = 8, 
		dexterity = 12, 
		intelligence = 10, 
		resolve = 10,
		baseAV = 0, 
		baseDV = 5, 
		baseDam = {1,2,0}
	},
	faction = 'herbivore',
	xpWorth = 50,
}

return creatures 