--- Module File
local Item = { }
--- Item Variables
local ReferenceStateGame = false
local worldItems = { }
local itemImages = { }
local itemTypes = { }

--- Load all item assets and data files
function Item.loadAssets()
	print("Loading Item Assets")
	local imagestoload = love.filesystem.getDirectoryItems("img/item")
	for k,v in pairs(imagestoload) do 
		itemImages[string.sub(v, 1, string.len(v) - 4)] = love.graphics.newImage("img/item/"..v)
	end
	local chunk = love.filesystem.load("dat/item.lua")
	itemTypes = chunk()
end

function Item.passHighLevelObjects(stateGame)
	ReferenceStateGame = stateGame
end

--- Draw item on the world if the item's tile is visible to the player character
function Item.drawWorldItems()
	for i = 1, # worldItems do 
		if ReferenceStateGame.getMap().isTileVisibleAt(worldItems[i].x, worldItems[i].y) then
			if not worldItems[i].item.color then 
				worldItems[i].item.color = {1, 1, 1}
			end
			love.graphics.setColor(worldItems[i].item.color[1], worldItems[i].item.color[2], worldItems[i].item.color[3])
			love.graphics.draw(itemImages[worldItems[i].item.img], worldItems[i].x * 16, worldItems[i].y * 16)
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

--- Creates a new item object, but doesn't bind it to a world item table.
--- Returns the base item object
function Item.createNewItem(itemtype)
	local i = { } 
	local s = { }
	local r = { }
	if itemTypes[itemtype] then 
		for k,v in pairs(itemTypes[itemtype]) do 
			i[k] = v 
		end
	end
	if i.stats then 
		for k,v in pairs(i.stats) do 
			s[k] = v 
		end 
		i.stats = s 
	end 
	if i.stats and i.stats.rangedWeapon then 
		for k,v in pairs(i.stats.rangedWeapon) do 
			r[k] = v 
		end
		i.stats.rangedWeapon = r
	end 
	if i.container then 
		i.container = false 
		i.container = { } 
	end
	return i
end

--- Removes an item from the world.  If the item hasn't been transfered to
--- a container beforehand then the item is lost to the gargabe collector 
function Item.removeFromWorld(item)
	for i = # worldItems, 1, -1 do 
		if worldItems[i] == item then 
			table.remove(worldItems, i)
			return true 
		end
	end
	return false
end

--- Duplicates and returns a passed item
function Item.duplicateItem(item)
	local new = {item = { }, x = item.x, y = item.y, stack = item.stack}
	for k,v in pairs(item.item) do 
		new.item[k] = v 
	end 
	return new
end

--- Combines stacks in containers.  Usefull before sorting 
function Item.combineStacks(container)
	for i = # container, 1, -1 do 
		if # container > 1 then 
			for k = i - 1, 1, -1 do 
				if container[i].item.stackable and container[k].item.stackable and 
					container[i].item.type == container[k].item.type and 
					ReferenceStateGame.tableContentCompare(container[i].item.stats, container[k].item.stats) and 
					ReferenceStateGame.tableContentCompare(container[i].item.mods, container[k].item.mods) then 
					container[k].stack = container[k].stack + container[i].stack 
					table.remove(container, i)
					break
				end
			end
		end
	end
	return container
end

--- Sorts a container of items first by item types, then by alphabetical order
--- Returns the sorted container
function Item.sortContainer(container, ignoreContainers)
	container = Item.combineStacks(container)
	local sorted = { }
	local sortOrder = {
		{'ammo', 'Ammo'},
		{'weapon', 'Melee Weapons'},
		{'ranged', 'Ranged Weapons'},
		{'throwing', 'Throwing Weapons'},
		{'shield', 'Shields'},
		{'armor', 'Armor'},
		{'drug', 'Pharmaceuticals'},
		{'container', 'Containers'},
		{'corpse', 'Remains'},
		{'misc', 'Miscellaneous'},
		{'unsorted', 'Sorting Error :)'},
	}
	for i = 1, # container do 
		container[i].sorted = false
	end
	for i = 1, # sortOrder do 
		for j = 1, # container do 
			if not container[j].sorted and (container[j].item.itemType == sortOrder[i][1] or sortOrder[i][1] == 'unsorted') then 
				if container[j].item.itemType ~= 'container' or (container[j].item.itemType == 'container' and not ignoreContainers) then 
					container[j].sorted = sortOrder[i][1]
					container[j].sortTitle = sortOrder[i][2]
					table.insert(sorted, # sorted + 1, container[j])
				end
			end
		end
	end
	return sorted
end

function Item.clearWorldItems()
	worldItems = { }
end

function Item.saveWorldItems()
	local tosave = { }
	local worldPos = ReferenceStateGame.getMap().getGameWorldPosition()
	local fileName = 'items'
	local filePath = 'cdata/'.. worldPos[1] ..'/' .. worldPos[2] .. '/' .. ReferenceStateGame.getMap().getGameWorldZ() ..'/'
	local tosave = { }
	local itemtosave = { }
	for i = 1, # worldItems do 
		itemtosave = {type = worldItems[i].item.type, stats = worldItems[i].item.stats, mods = worldItems[i].item.mods, stack = worldItems[i].stack, x = worldItems[i].x, y = worldItems[i].y}
		itemtosave.name = worldItems[i].item.name 
		itemtosave.color = worldItems[i].item.color
		if worldItems[i].item.container then 
			itemtosave.container = { }
			for k = 1, # worldItems[i].item.container do 
				local itemincont = {type = worldItems[i].item.container[k].item.type, stats = worldItems[i].item.container[k].item.stats, mods = worldItems[i].item.container[k].item.mods, stack = worldItems[i].item.container[k].stack, x = 1, y = 1}
				itemincont.name = worldItems[i].item.container[k].item.name 
				itemincont.color = worldItems[i].item.container[k].item.color
				table.insert(itemtosave.container, itemincont)
			end 
		end
		table.insert(tosave, itemtosave)
	end
	if not love.filesystem.getInfo(filePath) then 
		love.filesystem.createDirectory(filePath)
	end
	ReferenceStateGame.getBitSer().dumpLoveFile(filePath .. fileName, tosave)
end

function Item.loadWorldItems(wx, wy, wz)
	local fileName = 'items'
	local filePath = 'cdata/'.. wx ..'/' .. wy .. '/' .. wz ..'/'
	if love.filesystem.getInfo(filePath..fileName) then 
		local cdata = ReferenceStateGame.getBitSer().loadLoveFile(filePath..fileName)
		local ic = false
		local icc = false
		if cdata then 
			for i = 1, # cdata do 
				ic = {item = Item.createNewItem(cdata[i].type), x = cdata[i].x, y = cdata[i].y, stack = cdata[i].stack}
				ic.item.stats = cdata[i].stats 
				ic.item.mods = cdata[i].mods 
				ic.item.name = cdata[i].name 
				ic.item.color = cdata[i].color
				if cdata[i].container then 
					ic.item.container = { }
					for k = 1, # cdata[i].container do 
						icc = Item.createNewItem(cdata[i].container[k].type)
						icc.stats = cdata[i].container[k].stats 
						icc.mods = cdata[i].container[k].mods
						icc.name = cdata[i].container[k].name 
						icc.color = cdata[i].container[k].color
						table.insert(ic.item.container, {item = icc, x = 1, y = 1, stack = cdata[i].container[k].stack})
					end
				end
				table.insert(worldItems, ic)
			end
		end
	end
end

--- Takes an item object (from create new item) and binds it to a world item 
--- table containing x, y, and stack variables.
function Item.addItemToWorld(item, x, y, stack)
	table.insert(worldItems, {item = item, x = x, y = y, stack = stack})
end

function Item.dropItemFromContainer(item, x, y)
	if item.item.stackable then 
		for i = 1, # worldItems do 
			if worldItems[i].item.name == item.item.name and ReferenceStateGame.tableContentCompare(worldItems[i].item.stats, item.item.stats) and x == worldItems[i].x and y == worldItems[i].y then 
				worldItems[i].stack = worldItems[i].stack + item.stack 
				return true 
			end 
		end 
	end
	item.x = x 
	item.y = y
	table.insert(worldItems, item)
	return true
end

--- Returns a list of items occupying space x,y
function Item.getItemsAt(x, y)
	local ret = { }
	for i = 1, # worldItems do 
		if worldItems[i].x == x and worldItems[i].y == y then 
			table.insert(ret, worldItems[i])
		end
	end
	return ret
end

--- Apply an item and removes it from the passed container if
--- used up.  Returns the container and the item.
function Item.applyItemFromContainer(item, container, appliedBy, target)
	local msg = ''
	local tense = 'other'
	local nouns = {
		ReferenceStateGame.getCreature().getDisplayName(appliedBy),
		ReferenceStateGame.getCreature().getDisplayName(target),
		ReferenceStateGame.getCreature().getDisplayName(target),
		ReferenceStateGame.getCreature().getDisplayName(target),
	}
	--- Send message to log
	if ReferenceStateGame.getMap().isTileVisibleAt(appliedBy.x, appliedBy.y) or ReferenceStateGame.getMap().isTileVisibleAt(target.x, target.y) then 
		if appliedBy == ReferenceStateGame.getPlayerCharacter() then 
			nouns[1] = 'You'
			tense = 'player'
		end
		if target == ReferenceStateGame.getPlayerCharacter() then 
			nouns[2], nouns[3] = 'You', 'Your'
		end 
		if appliedBy == target then 
			if appliedBy == ReferenceStateGame.getPlayerCharacter() then 
				nouns[2] = 'Yourself' 
			else 
				nouns[2] = 'itself'
			end
		end
		msg = nouns[1] .. item.item.applicationMessage[tense] .. nouns[2] .. '.  '
		if target ~= ReferenceStateGame.getPlayerCharacter() then 
			tense = 'other'
		else 
			tense = 'player'
		end
		msg = msg .. nouns[3] .. item.item.effectMessage[tense]
		ReferenceStateGame.sendMessage({text = msg, color = {0.94, 0.6, 1}})
	end
	--- Use item and remove from container if applicable
	if item.item.applicable and item.item.application then 
		imsg = item.item.application(item, appliedBy, target)
		if item.item.amountUsedPerApplication then 
			for i = 1, # container do 
				if container[i] == item then
					if container[i].stack <= item.item.amountUsedPerApplication then 
						table.remove(container, i)
						break 
					else 
						container[i].stack = container[i].stack - item.item.amountUsedPerApplication
						break 
					end
				end 
			end 
		end
	end
	return container, item
end

--- Gets the display name of an world item object
function Item.getDisplayName(item, noStackText)
	local n = item.item.name
	if item.item.getDisplayName then 
		n = n .. item.item.getDisplayName(item)
	end
	if item.item.mods then 
		for i = 1, # item.item.mods do 
			n = n .. ' [' .. item.item.mods[i] ..']'
		end
	end
	if item.item.container then 
		if # item.item.container == 1 then 
			n = n .. ' [' .. # item.item.container .. ' item]'
		elseif # item.item.container == 0 then 
			n = n .. ' [empty]'
		else 
			n = n .. ' [' .. # item.item.container .. ' items]'
		end
	
	end
	if item.stack > 1 and not noStackText then 
		n = n .. ' x' .. item.stack 
	end
	return n
end

---
--- Getters
---

function Item.getItemImages()
	return itemImages
end

return Item