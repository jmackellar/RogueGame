local items = { }

items.scrap1 = {
	type = 'scrap1',
	itemType = 'corpse',
	name = 'Scrap',
	img = 'scrap1',
	color = {0.85, 0.85, 0.85},
	stats = {weight = 55},
	stackable = true,
	desc = 'A pile of damaged scrap.'
}

items.corpse1 = {
	type = 'corpse1',
	itemType = 'corpse',
	name = 'Corpse',
	img = 'corpse1',
	color = {0.88, 0, 0},
	stats = {weight = 55},
	stackable = true,
	desc = 'A mangled corpse.',
}

items.chest1 = {
	type = 'chest1',
	itemType = 'container',
	name = 'Chest',
	img = 'chest1',
	color = {0.89, 0.87, 0.5},
	stats = {weight = 15, container = true},
	container = { },
	stackable = false,
	desc = 'A simple chest.',
}

items.woodenbuckler = {
	type = 'woodenbuckler',
	itemType = 'shield',
	name = 'Wooden Buckler',
	img = 'buckler1',
	color = {0.5, 0.3, 0.2},
	stats = {weight = 3, shield = true, blockChance = 10},
	stackable = false,
	desc = 'A small buckler carved from wood.  Common in the slums.\n\nBlock Chance: 10%\nWeight: 3',
	getDisplayName =	function (self)
							return ' [10%]'
						end
}

items.simpleshield = {
	type = 'simpleshield',
	itemType = 'shield',
	name = 'Simple Shield',
	img = 'shield1',
	color = {0.75, 0.75, 0.75},
	stats = {weight = 5, shield = true, blockChance = 15},
	stackable = false,
	desc = 'A simple shield constructed from scrap metal.\n\nBlock Chance: 15%\nWeight: 5',
	getDisplayName =	function (self)
							return ' [15%]'
						end,
}

items.bullet = {
	type = 'bullet',
	itemType = 'ammo',
	name = 'Depleted Uranium Round',
	img = 'bullet1',
	color = {0, 1, 0.25},
	stats = {weight = 0},
	stackable = true,
	desc = 'A 9mm depleted uranium round inteded for use in an old fashioned ballistics weapon.\n\nWeight: 1',
	getDisplayName =	function (self)
							return ''
						end,
}

items.ballisticrifle = {
	type = 'ballisticrifle',
	itemType = 'ranged',
	name = 'Ballistic Rifle',
	img = 'rifle2',
	color = {0.85, 0.85, 0.85},
	stats = {weight = 15, damage = {1,6,0}, equipSlot = 'ranged', rangedWeapon = {penetration = 11, inaccuracy = 0.16, maxAmmo = 15, currentAmmo = 0, ammoType = 'bullet'}},
	stackable = false, 
	desc = 'A standard ballistics rifle.  Fires depleted uranium bullets.\n\nDamage: 1d6+0\nWeight: 15',
	getDisplayName =	function (self)
							return ' [1d6+0] [' .. self.item.stats.rangedWeapon.currentAmmo .. ' / ' .. self.item.stats.rangedWeapon.maxAmmo ..']'
						end,
}

items.huntingrifle = {
	type = 'huntingrifle',
	itemType = 'ranged',
	name = 'Hunting Rifle',
	img = 'rifle1',
	color = {0.85, 0.85, 0.85},
	stats = {weight = 15, damage = {2,3,0}, equipSlot = 'ranged', rangedWeapon = {penetration = 13, inaccuracy = 0.12, maxAmmo = 1, currentAmmo = 0, ammoType = 'bullet'}},
	stackable = false, 
	desc = 'An old hunting rifle.  Fires depleted uranium bullets.\n\nDamage: 2d3+0\nWeight: 15',
	getDisplayName =	function (self)
							return ' [2d3+0] [' .. self.item.stats.rangedWeapon.currentAmmo .. ' / ' .. self.item.stats.rangedWeapon.maxAmmo ..']'
						end,
}

items.ballisticpistol = {
	type = 'ballisticpistol',
	itemType = 'ranged',
	name = 'Ballistics Pistol',
	img = 'pistol1',
	color = {0.85, 0.85, 0.85},
	stats = {weight = 5, damage = {1,3,1}, equipSlot = 'ranged', rangedWeapon = {penetration = 9, inaccuracy = 0.22, maxAmmo = 6, currentAmmo = 0, ammoType = 'bullet'}},
	stackable = false, 
	desc = 'An old ballistics pistol.  Fires depleted uranium bullets.\n\nDamage: 1d3+0\nWeight: 5',
	getDisplayName =	function (self)
							return ' [1d3+0] [' .. self.item.stats.rangedWeapon.currentAmmo .. ' / ' .. self.item.stats.rangedWeapon.maxAmmo ..']'
						end,
}

items.hoe = {
	type = 'hoe',
	itemType = 'weapon',
	name = 'Hoe',
	img = 'hoe1',
	color = {0.56, 0.62, 0.63},
	stats = {weight = 6, damage = {2,3,0}},
	stackable = false, 
	desc = 'A simple hoe used for farming.\n\nDamage: 2d3+0\nWeight: 6',
	getDisplayName =	function (self)
							return ' [2d3+0]'
						end,
}

items.plasteelsaber = {
	type = 'plasteelsaber',
	itemType = 'weapon',
	name = 'Plasteel Saber',
	img = 'longblade2',
	color = {0.56, 0.62, 0.63},
	stats = {weight = 3, damage = {2,5,0}},
	stackable = false, 
	desc = 'A molded plasteel blade modeled after a traditional saber.\n\nDamage: 2d5+0\nWeight: 3',
	getDisplayName =	function (self)
							return ' [2d5+0]'
						end,
}

items.longsword = {
	type = 'longsword',
	itemType = 'weapon',
	name = 'Longsword',
	img = 'longblade1',
	color = {0.71, 0.87, 1},
	stats = {weight = 3, damage = {1,8,0}},
	stackable = false, 
	desc = 'An older style longsword, fashioned by hand in the slums.\n\nDamage: 1d8+0\nWeight: 1',
	getDisplayName =	function (self)
							return ' [1d8+0]'
						end,
}

items.cryoblade = {
	type = 'cryoblade',
	itemType = 'weapon',
	name = 'Cryoblade',
	img = 'shortblade2',
	color = {0.25, 1, 1},
	stats = {weight = 1, damage = {3,2,0}, toHit = 2},
	mods = {'balanced'},
	stackable = false, 
	desc = 'A short cryo forged blade.\n\nDamage: 3d2+0\nTo Hit: +2\nWeight: 1',
	getDisplayName =	function (self)
							return ' [3d2+0]'
						end,
}

items.switchblade = {
	type = 'switchblade',
	itemType = 'weapon',
	name = 'Switchblade',
	img = 'shortblade1',
	color = {0.6, 0.67, 0.71},
	stats = {weight = 1, damage = {1,5,0}, toHit = 2},
	mods = {'balanced'},
	stackable = false, 
	desc = 'A simple switchblade.  Easy to use, and even easier to conceal.\n\nDamage: 1d5+0\nTo Hit: +2\nWeight: 1',
	getDisplayName =	function (self)
							return ' [1d5+0]'
						end,
}

items.cleatedboots = {
	type = 'cleatedboots',
	itemType = 'armor',
	name = 'Cleated Boots',
	img = 'shoe2',
	color = {0.5, 0.3, 0.2},
	stats = {weight = 1, av = 1, dv = -1, equipSlot = 'feet'},
	stackable = false,
	desc = 'A pair of cleated boots.  Offers great traction.\n\nAV: 1\nDV: -1\nWeight: 1',
	getDisplayName =	function (self)
							return ' [1AV -1DV]'
						end,
}

items.sneakers = {
	type = 'sneakers',
	itemType = 'armor',
	name = 'Sneakers',
	img = 'shoe1',
	color = {0.8, 0.8, 0.3},
	stats = {weight = 1, av = 0, dv = 1, equipSlot = 'feet'},
	stackable = false,
	desc = 'A pair of well fitting sneakers.\n\nAV: 0\nDV: 1\nWeight: 1',
	getDisplayName =	function (self)
							return ' [0AV 1DV]'
						end,
}

items.denimjeans = {
	type = 'denimjeans',
	itemType = 'armor',
	name = 'Denim Jeans',
	img = 'leggings1',
	color = {0.2, 0.4, 0.6},
	stats = {weight = 3, av = 0, dv = 1, equipSlot = 'legs'},
	stackable = false,
	desc = 'A pair of worn denim jeans.  Frayed near the ankles.\n\nAV: 0\nDV: 1\nWeight: 3',
	getDisplayName =	function (self)
							return ' [0AV 1DV]'
						end,
}

items.leathergloves = { 
	type = 'leathergloves',
	itemType = 'armor',
	name = 'Leather Gloves',
	img = 'gloves1',
	color = {0.79, 0.56, 0.39},
	stats = {weight = 1, av = 1, dv = 0, equipSlot = 'gloves'},
	stackable = false,
	desc = 'A pair of leather gloves made for hard labor.\n\nAV: 1\nnDV: 0\nWeight: 1',
	getDisplayName =	function (self)
							return ' [1AV 0DV]'
						end,
}

items.worncloak = { 
	type = 'worncloak',
	itemType = 'armor',
	name = 'Worn Cloak',
	img = 'cloak1',
	color = {0.89, 0.66, 0.49},
	stats = {weight = 1, av = 0, dv = 1, equipSlot = 'back'},
	stackable = false,
	desc = 'An old cloak that\'s been worn out and left to gather dust.\n\nAV: 0\nnDV: 1\nWeight: 1',
	getDisplayName =	function (self)
							return ' [0AV 1DV]'
						end,
}

items.leatherjacket = {
	type = 'leatherjacket',
	itemType = 'armor',
	name = 'Leather Jacket',
	img = 'leatherjacket1',
	color = {0.81, 0.58, 0.41},
	stats = {weight = 5, av = 1, dv = 0, equipSlot = 'overshirt'},
	stackable = false,
	desc = 'A battered leather jacket.  Popular among street punks and laborers.\n\nAV: 1\nDV: 0\nWeight: 5',
	getDisplayName =	function (self)
							return ' [1AV 0DV]'
						end,
}

items.kevlarvest = {
	type = 'kevlarvest',
	itemType = 'armor',
	name = 'Kevlar Vest',
	img = 'kevlar1',
	color = {0.46, 0.47, 0.61},
	stats = {weight = 15, av = 3, dv = -1, equipSlot = 'overshirt'},
	stackable = false,
	desc = 'A thick vest made from woven kevlar.  Offers significant protection.\n\nAV: 3\nDV: -1\nWeight: 15',
	getDisplayName =	function (self)
							return ' [3AV -1DV]'
						end,
}

items.polyestershirt = {
	type = 'polyestershirt',
	itemType = 'armor',
	name = 'Polyester Shirt',
	img = 'shirt1',
	color = {0.61, 0.46, 0.46},
	stats = {weight = 1, av = 0, dv = 1, equipSlot = 'undershirt'},
	stackable = false,
	desc = 'A mass produced polyester shirt sporting a logo near the collar.\n\nAV: 0\nDV: 1\nWeight: 1',
	getDisplayName =	function (self)
							return ' [0AV 1DV]'
						end,
}

items.clothshirt = {
	type = 'clothshirt',
	itemType = 'armor',
	name = 'Cloth Shirt',
	img = 'shirt1',
	color = {0.76, 0.68, 0.46},
	stats = {weight = 1, av = 0, dv = 2, equipSlot = 'undershirt'},
	stackable = false,
	desc = 'An authentic cloth shirt.  Comfortable, and conforming.\n\nAV: 0\nDV: 2\nWeight: 1',
	getDisplayName =	function (self)
							return ' [0AV 2DV]'
						end,
}

items.healthneedle = { 
	type = 'healthneedle',
	itemType = 'drug',
	name = 'Hypodermic Needle',
	img = 'needle1',
	color = {1, 0.19, 0.19},
	stats = {weight = 0, fluid = 'morphine'},
	stackable = true,          
	applicable = true,
	amountUsedPerApplication = 1,
	applicationMessage = {
		player = ' stuck the needle into ',
		other = ' sticks the needle into ',
	},
	effectMessage = {
		player = ' chest feels numb and the pain begins to fade.  ',
		other = ' begins to feel better.  '
	},
	desc = 'A clean hypodermic needle filled with Morphine.  Can be injected into the skin, the effects of which will take place immediately.\n\nExample Effect\nExample Effect\nExample Effect',           
	getDisplayName =	function (self)
							return ' [Morphine]'
						end,
	application =	function (self, appliedBy, target)
						target.ReferenceStateGame.getCreature().addCurrentHealth(target, 25)
					end,
	aiCheck =	function (self, creature, targetself)
					if targetself and creature.currentHealth <= creature.ReferenceStateGame.getCreature().getMaxHealth(creature) * 0.5 then 
						if love.math.random(1, 100) <= 25 then 
							return true 
						end
					end
					return false
				end
}

items.staminaneedle = { 
	type = 'staminaneedle',
	itemType = 'drug',
	name = 'Hypodermic Needle',
	img = 'needle1',
	color = {0.19, 1, 0.19},
	stats = {weight = 0, fluid = 'adrenaline'},
	stackable = true,   
	applicable = true,  
	amountUsedPerApplication = 1,
	applicationMessage = {
		player = ' stuck the needle into ',
		other = ' sticks the needle into ',
	},
	effectMessage = {
		player = ' chest heats up as your muscles fill with energy.  ',
		other = ' begins to frantically shake.  '
	},     
	desc = 'A clean hypodermic needle filled with Adrenaline.  Can be injected into the skin, the effects of which will take place immediately.\n\nExample Effect\nExample Effect\nExample Effect',           
	getDisplayName =	function (self)
							return ' [Adrenaline]'
						end,
	application =	function (self, appliedBy, target)

					end,
}

items.deathneedle = { 
	type = 'deathneedle',
	itemType = 'drug',
	name = 'Hypodermic Needle',
	img = 'needle1',
	color = {1, 1, 1},
	stats = {weight = 0, fluid = 'fentanyl'},
	stackable = true,   
	applicable = true,
	amountUsedPerApplication = 1,
	applicationMessage = {
		player = ' stuck the needle into ',
		other = ' sticks the needle into ',
	},
	effectMessage = {
		player = ' chest chills as your heart begins to ache.  ',
		other = ' begins to look sick.  '
	},       
	desc = 'A clean hypodermic needle filled with Fentanyl.  Can be injected into the skin, the effects of which will take place immediately.\n\nExample Effect\nExample Effect\nExample Effect',           
	getDisplayName =	function (self)
							return ' [Fentanyl]'
						end,
	application =	function (self, appliedBy, target)
						if appliedBy ~= target then 
							target.target = appliedBy
						end
						target.ReferenceStateGame.getCreature().takeDamage(target, 25, 'internal')
					end,
	aiCheck =	function (self, creature, targetself)
					if not targetself and creature.target then 
						local targets = {{-1,-1},{-1,0},{-1,1},{0,-1},{0,1},{1,-1},{1,0},{1,1}}
						for i = 1, # targets do 
							if creature.target.x == creature.x + targets[i][1] and creature.target.y == creature.y + targets[i][2] then 
								if love.math.random(1, 100) <= 20 then 
									return true 
								end 
							end 
						end
					end
					return false
				end
}

return items 