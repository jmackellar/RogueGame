local worldTiles = { }

worldTiles.surface = { }

worldTiles.surface.complex = {
	tileImg = 'overworldComplex',
	tileName = 'Military Complex',
	generator =	function(t, cX, cY, Map)
					return Map.generateComplex(t, cX, cY, 4, {0.35, 0.35}, 0.55)
				end,
	popAmount = {min = 15, max = 25},
	popTable = {
		{type = 'soldier', chance = 55},
		{type = 'knight', chance = 25},
		{type = 'manager', chance = 10},
		{type = 'giantbeast', chance = 15},
		{type = 'heavypunk', chance = 10},
	},
	outOfDepthPopTable = {
		{type = 'teslabot', chance = 100},
	},
	itemAmount = {min = 6, max = 12},
	itemTable = {
		{type = 'bullet', chance = 25, min = 7, max = 17},

		{type = 'polyestershirt', chance = 10, min = 1, max = 1},
		{type = 'clothshirt', chance = 5, min = 1, max = 1},
		{type = 'denimjeans', chance = 10, min = 1, max = 1},
		{type = 'leatherjacket', chance = 7, min = 1, max = 1},
		{type = 'cleatedboots', chance = 5, min = 1, max = 1},
		{type = 'kevlarvest', chance = 2, min = 1, max = 1},
		{type = 'worncloak', chance = 6, min = 1, max = 1},
		{type = 'sneakers', chance = 2, min = 1, max = 1},

		{type = 'healthneedle', chance = 6, min = 1, max = 1},
		{type = 'staminaneedle', chance = 4, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},
	
		{type = 'switchblade', chance = 7, min = 1, max = 1},
		{type = 'longsword', chance = 9, min = 1, max = 1},
		{type = 'plasteelsaber', chance = 2, min = 1, max = 1},
		{type = 'cryoblade', chance = 3, min = 1, max = 1},
		{type = 'hoe', chance = 10, min = 1, max = 1},
		{type = 'ballisticrifle', chance = 2, min = 1, max = 1},
		{type = 'ballisticpistol', chance = 5, min = 1, max = 1},
	},
}

worldTiles.surface.warehouse = {
	tileImg = 'overworldWarehouse',
	tileName = 'Warehouse',
	generator =	function(t, cX, cY, Map)
					return Map.generateWarehouse(t, cX, cY, 2, {0.49, 0.49}, 0.95)
				end,
	popAmount = {min = 15, max = 25},
	popTable = {
		{type = 'laborer', chance = 75},
		{type = 'foreman', chance = 25},
		{type = 'manager', chance = 5},
		{type = 'scoutbot', chance = 5},
		{type = 'punk', chance = 10},
		{type = 'heavypunk', chance = 5},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 3, max = 7},
	itemTable = {
		{type = 'bullet', chance = 5, min = 1, max = 7},

		{type = 'polyestershirt', chance = 10, min = 1, max = 1},
		{type = 'clothshirt', chance = 5, min = 1, max = 1},
		{type = 'denimjeans', chance = 10, min = 1, max = 1},
		{type = 'leatherjacket', chance = 7, min = 1, max = 1},
		{type = 'cleatedboots', chance = 5, min = 1, max = 1},
		{type = 'kevlarvest', chance = 2, min = 1, max = 1},
		{type = 'worncloak', chance = 6, min = 1, max = 1},
		{type = 'sneakers', chance = 2, min = 1, max = 1},

		{type = 'healthneedle', chance = 6, min = 1, max = 1},
		{type = 'staminaneedle', chance = 4, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},
	
		{type = 'switchblade', chance = 7, min = 1, max = 1},
		{type = 'longsword', chance = 9, min = 1, max = 1},
		{type = 'plasteelsaber', chance = 1, min = 1, max = 1},
		{type = 'cryoblade', chance = 1, min = 1, max = 1},
		{type = 'hoe', chance = 10, min = 1, max = 1},
		{type = 'ballisticrifle', chance = 2, min = 1, max = 1},
		{type = 'ballisticpistol', chance = 5, min = 1, max = 1},
	},
}

worldTiles.surface.slums = {
	tileImg = 'overworldRuins',
	tileName = 'Abandoned Town',
	generator =	function(t, cX, cY, Map)
					return Map.generatePoorResidential(t, cX, cY, love.math.random(10, 20), 65)
				end,
	popAmount = {min = 15, max = 25},
	popTable = {
		{type = 'laborer', chance = 15},
		{type = 'scoutbot', chance = 7},
		{type = 'punk', chance = 55},
		{type = 'heavypunk', chance = 15},
		{type = 'hunter', chance = 5},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 3, max = 7},
	itemTable = {
		{type = 'bullet', chance = 25, min = 1, max = 7},

		{type = 'polyestershirt', chance = 10, min = 1, max = 1},
		{type = 'denimjeans', chance = 7, min = 1, max = 1},
		{type = 'leatherjacket', chance = 4, min = 1, max = 1},
		{type = 'cleatedboots', chance = 2, min = 1, max = 1},
		{type = 'worncloak', chance = 1, min = 1, max = 1},

		{type = 'healthneedle', chance = 8, min = 1, max = 1},
		{type = 'staminaneedle', chance = 6, min = 1, max = 1},
		{type = 'deathneedle', chance = 2, min = 1, max = 1},
	
		{type = 'switchblade', chance = 12, min = 1, max = 1},
		{type = 'longsword', chance = 6, min = 1, max = 1},
		{type = 'plasteelsaber', chance = 1, min = 1, max = 1},
		{type = 'cryoblade', chance = 1, min = 1, max = 1},
		{type = 'ballisticpistol', chance = 8, min = 1, max = 1},
		{type = 'huntingrifle', chance = 4, min = 1, max = 1},
	},
}

worldTiles.surface.residential = {
	tileImg = 'overworldResidential',
	tileName = 'Labor Town',
	generator =	function(t, cX, cY, Map)
					return Map.generatePoorResidential(t, cX, cY, love.math.random(10, 20), 100)
				end,
	popAmount = {min = 15, max = 25},
	popTable = {
		{type = 'laborer', chance = 80},
		{type = 'foreman', chance = 15},
		{type = 'scoutbot', chance = 5},
		{type = 'punk', chance = 30},
		{type = 'heavypunk', chance = 10},
		{type = 'hunter', chance = 15},
		{type = 'survivalist', chance = 5},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 3, max = 7},
	itemTable = {
		{type = 'bullet', chance = 10, min = 1, max = 7},

		{type = 'polyestershirt', chance = 15, min = 1, max = 1},
		{type = 'clothshirt', chance = 1, min = 1, max = 1},
		{type = 'denimjeans', chance = 10, min = 1, max = 1},
		{type = 'leatherjacket', chance = 7, min = 1, max = 1},
		{type = 'cleatedboots', chance = 5, min = 1, max = 1},
		{type = 'kevlarvest', chance = 1, min = 1, max = 1},
		{type = 'worncloak', chance = 4, min = 1, max = 1},
		{type = 'sneakers', chance = 1, min = 1, max = 1},

		{type = 'healthneedle', chance = 4, min = 1, max = 1},
		{type = 'staminaneedle', chance = 3, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},
	
		{type = 'switchblade', chance = 7, min = 1, max = 1},
	},
}

worldTiles.surface.pond = {
	tileImg = 'overworldPond',
	tileName = 'Waste Ponds',
	generator = function(t, cX, cY, Map)
					return Map.generatePond(t, cX, cY, 7, 14, 6)
				end,
	popAmount = {min = 10, max = 15},
	popTable = {
		{type = 'moth', chance = 15},
		{type = 'deer', chance = 15},
		{type = 'turtle', chance= 15},
		{type = 'hunter', chance = 15},
		{type = 'survivalist', chance = 5},
		{type = 'scoutbot', chance = 10},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 3, max = 7},
	itemTable = {
		{type = 'bullet', chance = 15, min = 1, max = 7},

		{type = 'clothshirt', chance = 1, min = 1, max = 1},
		{type = 'cleatedboots', chance = 3, min = 1, max = 1},
		{type = 'kevlarvest', chance = 1, min = 1, max = 1},

		{type = 'healthneedle', chance = 4, min = 1, max = 1},
		{type = 'staminaneedle', chance = 3, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},

		{type = 'ballisticpistol', chance = 2, min = 1, max = 1},
		{type = 'huntingrifle', chance = 1, min = 1, max = 1},
		{type = 'longsword', chance = 3, min = 1, max = 1},
		{type = 'switchblade', chance = 4, min = 1, max = 1},
	},
}

worldTiles.surface.barrenplains = {
	tileImg = 'overworldPlains',
	tileName = 'Waste Plains',
	generator = function(t, cX, cY, Map)
					return Map.generatePlains(t, cX, cY, 7, 14, 6)
				end,
	popAmount = {min = 3, max = 7},
	popTable = {
		{type = 'moth', chance = 10},
		{type = 'deer', chance = 15},
		{type = 'turtle', chance= 15},
		{type = 'hunter', chance = 5},
		{type = 'scoutbot', chance = 1},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 1, max = 4},
	itemTable = {
		{type = 'bullet', chance = 15, min = 1, max = 7},

		{type = 'clothshirt', chance = 1, min = 1, max = 1},
		{type = 'cleatedboots', chance = 3, min = 1, max = 1},
		{type = 'kevlarvest', chance = 1, min = 1, max = 1},

		{type = 'healthneedle', chance = 4, min = 1, max = 1},
		{type = 'staminaneedle', chance = 3, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},

		{type = 'ballisticpistol', chance = 2, min = 1, max = 1},
		{type = 'huntingrifle', chance = 1, min = 1, max = 1},
		{type = 'longsword', chance = 3, min = 1, max = 1},
		{type = 'switchblade', chance = 4, min = 1, max = 1},
	},
}

worldTiles.surface.plains = {
	tileImg = 'overworldPlains',
	tileName = 'Waste Plains',
	generator = function(t, cX, cY, Map)
					return Map.generatePlains(t, cX, cY, 7, 11, 100)
				end,
	popAmount = {min = 10, max = 15},
	popTable = {
		{type = 'moth', chance = 15},
		{type = 'deer', chance = 15},
		{type = 'turtle', chance= 15},
		{type = 'hunter', chance = 15},
		{type = 'survivalist', chance = 5},
		{type = 'scoutbot', chance = 10},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 3, max = 7},
	itemTable = {
		{type = 'bullet', chance = 15, min = 1, max = 7},

		{type = 'clothshirt', chance = 1, min = 1, max = 1},
		{type = 'cleatedboots', chance = 3, min = 1, max = 1},
		{type = 'kevlarvest', chance = 1, min = 1, max = 1},

		{type = 'healthneedle', chance = 4, min = 1, max = 1},
		{type = 'staminaneedle', chance = 3, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},

		{type = 'ballisticpistol', chance = 2, min = 1, max = 1},
		{type = 'huntingrifle', chance = 1, min = 1, max = 1},
		{type = 'longsword', chance = 3, min = 1, max = 1},
		{type = 'switchblade', chance = 4, min = 1, max = 1},
	},
}

worldTiles.surface.mountain = {
	tileImg = 'overworldMountain',
	tileName = 'Surface Caverns',
	generator = function(t, cX, cY, Map)
					return Map.generateCaves(t, cX, cY, 55, 2, 5)
				end,
	popAmount = {min = 15, max = 25},
	popTable = {
		{type = 'moth', chance = 30},
		{type = 'worm', chance = 10},
		{type = 'survivalist', chance = 5},
		{type = 'scoutbot', chance = 7},
		{type = 'giantbeast', chance = 10},
		{type = 'soldier', chance = 10},
	},
	outOfDepthPopTable = {
		{type = 'knight', chance = 100},
		{type = 'teslabot', chance = 25},
	},
	itemAmount = {min = 6, max = 12},
	itemTable = {
		{type = 'bullet', chance = 15, min = 7, max = 15},

		{type = 'clothshirt', chance = 5, min = 1, max = 1},
		{type = 'cleatedboots', chance = 8, min = 1, max = 1},
		{type = 'kevlarvest', chance = 4, min = 1, max = 1},

		{type = 'healthneedle', chance = 4, min = 1, max = 1},
		{type = 'staminaneedle', chance = 3, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},

		{type = 'ballisticpistol', chance = 5, min = 1, max = 1},
		{type = 'ballisticrifle', chance = 3, min = 1, max = 1},
		{type = 'huntingrifle', chance = 4, min = 1, max = 1},
		{type = 'longsword', chance = 3, min = 1, max = 1},
		{type = 'plasteelsaber', chance = 2, min = 1, max = 1},
		{type = 'cryoblade', chance = 3, min = 1, max = 1},
		{type = 'switchblade', chance = 4, min = 1, max = 1},
	},
}

worldTiles.surface.caverns = {
	tileImg = 'overworldCavern',
	tileName = 'Steep Hills',
	generator = function(t, cX, cY, Map)
					return Map.generateCaves(t, cX, cY, 47, 4, 5)
				end,
	popAmount = {min = 10, max = 15},
	popTable = {
		{type = 'moth', chance = 30},
		{type = 'worm', chance = 10},
		{type = 'deer', chance = 5},
		{type = 'turtle', chance= 5},
		{type = 'hunter', chance = 4},
		{type = 'survivalist', chance = 1},
		{type = 'scoutbot', chance = 3},
	},
	outOfDepthPopTable = {
		{type = 'enforcerdroid', chance = 100},
		{type = 'giantbeast', chance = 100},
	},
	itemAmount = {min = 3, max = 7},
	itemTable = {
		{type = 'bullet', chance = 15, min = 1, max = 7},

		{type = 'clothshirt', chance = 1, min = 1, max = 1},
		{type = 'cleatedboots', chance = 3, min = 1, max = 1},
		{type = 'kevlarvest', chance = 1, min = 1, max = 1},

		{type = 'healthneedle', chance = 4, min = 1, max = 1},
		{type = 'staminaneedle', chance = 3, min = 1, max = 1},
		{type = 'deathneedle', chance = 1, min = 1, max = 1},

		{type = 'ballisticpistol', chance = 2, min = 1, max = 1},
		{type = 'huntingrifle', chance = 1, min = 1, max = 1},
		{type = 'longsword', chance = 3, min = 1, max = 1},
		{type = 'switchblade', chance = 4, min = 1, max = 1},
	},
}

return worldTiles