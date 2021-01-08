---
--- Rogue Game
---

--- State File
local StateGame = { }
--- Libraries
local LibCamera = require("lib/camera")
local LibMoonshine = require ("lib/moonshine")
local LibBitSer = require("lib/bitser")
--- Game Files
local Map = require("map")
local Creature = require("creature")
local Message = require("message")
local Effect = require("effect")
local Item = require("item")
--- Game Variables
local gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
local gameCanvasEffect = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
local gameCamera = false
local gameScanLines = false
local gameFonts = { }
local gameParticles = { }
local gameCurrentTurn = 0
local inputKeys = false
local PlayerCharacter = false
local controlFocus = false
local controlFocusTypes = { }
local screenShakeVal = 0

---
--- Love2D Callbacks
---

function StateGame.load()
	print("Loading Game State")
	--- Delete previous save
	--- remove this later
	StateGame.deleteSavedGame()
	--- Load Assets
	Map.loadAssets()
	Creature.loadAssets()
	Item.loadAssets()
	Message.loadAssets()
	Effect.loadAssets()
	Creature.passHighLevelObjects(Map, StateGame)
	Effect.passHighLevelObjects(StateGame)
	Item.passHighLevelObjects(StateGame)
	Map.passHighLevelObjects(StateGame)
	--- Load Map
	Map.genTestMap()
	Map.switchGameWorldLoaded(500,500,1)
	--- Create Player Character
  	PlayerCharacter = Creature.addNewCreature('player', math.floor(Map.getGameWorldWidth() / 2), math.floor(Map.getGameWorldHeight() / 2), 0)
  	PlayerCharacter.equipSlots[1].equip = {item = Item.createNewItem('longsword'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[2].equip = {item = Item.createNewItem('simpleshield'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[3].equip = {item = Item.createNewItem('ballisticpistol'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[8].equip = {item = Item.createNewItem('worncloak'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[9].equip = {item = Item.createNewItem('kevlarvest'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[10].equip = {item = Item.createNewItem('clothshirt'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[11].equip = {item = Item.createNewItem('leathergloves'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[12].equip = {item = Item.createNewItem('denimjeans'), x = 1, y = 1, stack = 1}
  	PlayerCharacter.equipSlots[13].equip = {item = Item.createNewItem('sneakers'), x = 1, y = 1, stack = 1}
  	table.insert(PlayerCharacter.inventory, {item = Item.createNewItem('bullet'), x = 1, y = 1, stack = 150})
  	table.insert(PlayerCharacter.inventory, {item = Item.createNewItem('chest1'), x = 1, y = 1, stack = 1})
  	table.insert(PlayerCharacter.inventory[2].item.container, {item = Item.createNewItem('bullet'), x = 1, y = 1, stack = 300})
  	table.insert(PlayerCharacter.inventory[2].item.container, {item = Item.createNewItem('longsword'), x = 1, y = 1, stack = 1})
  	table.insert(PlayerCharacter.inventory[2].item.container, {item = Item.createNewItem('healthneedle'), x = 1, y = 1, stack = 100})
  	table.insert(PlayerCharacter.inventory[2].item.container, {item = Item.createNewItem('deathneedle'), x = 1, y = 1, stack = 100})
  	Map.calculateFOV(Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter), Creature.getSightRadius(PlayerCharacter))
	--- Load Camera
	gameCamera = LibCamera(24 + PlayerCharacter.x * 16, 24 + PlayerCharacter.y * 16)
	gameCamera:zoom(2)
	--- Load Particles
	local parts = love.filesystem.getDirectoryItems("/part/") or { }
	local p = false
	for i = 1, # parts do 
		p = love.filesystem.load("/part/"..parts[i])()
		p:start()
		gameParticles[string.sub(parts[i], 1, string.len(parts[i]) - 4)] = p
	end
	--- Load Keymapping
	inputKeys = {
		moveWest = {'h','h'},
		moveEast = {'l','l'},
		moveSouth = {'j','j'},
		moveNorth = {'k','k'},
		moveNorthWest = {'y','y'},
		moveNorthEast = {'u','u'},
		moveSouthWest = {'b','b'},
		moveSouthEast = {'n','n'},
		waitTurn = {'.','.'},
		forcedAttack = {'lctrl','lctrl'},
		interact = {'space','space'},
		pickupItem = {'g','g'},
		inventory = {'i','i'},
		equipment = {'e','e'},
		character = {'c','c'},
		fire = {'f','f'},
		reload = {'r', 'r'},
	}
	--- Load Fonts
	gameFonts.pixelu20 = love.graphics.newFont("/img/font/pixelu.ttf", 20)
	gameFonts.pixelu24 = love.graphics.newFont("/img/font/pixelu.ttf", 24)
	gameFonts.pixelu32 = love.graphics.newFont("/img/font/pixelu.ttf", 32)
	gameFonts.slkscr30 = love.graphics.newFont("/img/font/slkscr.ttf", 30)
	gameFonts.slkscr24 = love.graphics.newFont("/img/font/slkscr.ttf", 24)
	gameFonts.slkscr20 = love.graphics.newFont("/img/font/slkscr.ttf", 20)
	gameFonts.slkscr18 = love.graphics.newFont("/img/font/slkscr.ttf", 18)
	gameFonts.slkscr14 = love.graphics.newFont("/img/font/slkscr.ttf", 14)
	gameFonts.slkscr8 = love.graphics.newFont("/img/font/slkscr.ttf", 8)
	--- Scanline Shader
	gameScanLines = LibMoonshine(LibMoonshine.effects.scanlines)                 
  	gameScanLines.scanlines.width = 2
  	gameScanLines.scanlines.opacity = 0.45
  	--- Setup control focus
  	controlFocusTypes.container = {draw = StateGame.controlFocusContainerDraw, update = StateGame.controlFocusContainerUpdate, keypressed = StateGame.controlFocusContainerKeypressed}  	--- Succes
  	controlFocusTypes.target = {draw = StateGame.controlFocusTargetDraw, update = StateGame.controlFocusTargetUpdate, keypressed = StateGame.controlFocusTargetKeypressed}
  	controlFocusTypes.character = {draw = StateGame.controlFocusCharacterDraw, update = StateGame.controlFocusCharacterUpdate, keypressed = StateGame.controlFocusCharacterKeypressed}
  	print("Game Succesfully Loaded")
  	Message.receiveMessage({text = 'Welcome to the Dark World of Something Something Soon to Be!', color = {1, 1, 1, 1}})
end

function StateGame.update(dt)
	if Creature.getCurrentHealth(PlayerCharacter) > 0 then 
		if not Effect.getAreEffectsPlaying() then 
			Creature.takeTurn(PlayerCharacter)
		end
		Creature.update(dt)
		StateGame.cameraLookAtPlayerCharacter(dt)
		if controlFocus and controlFocusTypes[controlFocus.type].update then 
	    	controlFocusTypes[controlFocus.type].update(dt)
	    end
	    if Creature.getCurrentHealth(PlayerCharacter) <= 0 then 
	    	Creature.killCreature(PlayerCharacter)
	    	controlFocus = false 
	    end
	end
	Effect.update(dt)
	for k,v in pairs(gameParticles) do 
		v:update(dt)
	end
end

function StateGame.draw()
	local map = Map.drawGameWorld(
		PlayerCharacter.x - math.floor((love.graphics.getWidth() / 2) / 16), 
		PlayerCharacter.y - math.floor((love.graphics.getHeight() / 2) / 16), 
		PlayerCharacter.x + math.floor((love.graphics.getWidth() / 2) / 16), 
		PlayerCharacter.y + math.floor((love.graphics.getHeight() / 2) / 16)
		)
	gameCamera:attach()
	love.graphics.setCanvas(gameCanvas)
	love.graphics.clear()
	love.graphics.draw(map, 0, 0)
	Item.drawWorldItems()
	love.graphics.setCanvas()
	love.graphics.setCanvas(gameCanvasEffect)
	love.graphics.clear()
	Creature.drawAllCreatures()
	Effect.draw()
	for k,v in pairs(gameParticles) do 
		love.graphics.draw(v)
	end
	love.graphics.setCanvas()
	--- Unattach the camera and the canvas
	gameCamera:detach()
	--- Apply scanelines to canvas
	gameScanLines(function()
    	love.graphics.draw(gameCanvas, 0, 0)
    	love.graphics.draw(gameCanvasEffect, 0, 0)
    end)
    StateGame.drawHUD()
    Message.draw(gameFonts)
    if controlFocus and Creature.getCurrentHealth(PlayerCharacter) > 0 and controlFocusTypes[controlFocus.type].draw then 
    	if not controlFocus.directionalSelection then 
    		controlFocusTypes[controlFocus.type].draw()
    	else 
    		StateGame.controlFocusDirectionalSelectionDraw(key, isrepeat)
    	end
    end
end

function StateGame.keypressed(key, isrepeat)
	--- Allow input when it is the players turn
	if PlayerCharacter and Creature.isPlayersTurn(PlayerCharacter) then 
		--- No controlFocus
		--- Direct character control, movement, attacking, interacting...
		if not controlFocus then 
			StateGame.inputNoControlFocus(key, isrepeat)
		end
	end
	if controlFocus and Creature.getCurrentHealth(PlayerCharacter) > 0 and controlFocusTypes[controlFocus.type].keypressed then 
		if not controlFocus.directionalSelection then
    		controlFocusTypes[controlFocus.type].keypressed(key, isrepeat)
    	else 
    		StateGame.controlFocusDirectionalSelectionKeypressed(key, isrepeat)
    	end
    end
    --- DEBUG
    if key == 'f3' and StateGame.DEBUG then 
    	Map.revealMap()
    elseif key == 'f4' and StateGame.DEBUG then 
    	Map.revealMap(true)
    elseif key == 'f5' and StateGame.DEBUG then 
    	Creature.gainXP(PlayerCharacter, Creature.getXPNeededToLevel(PlayerCharacter), PlayerCharacter.stats.level + 1)
    end
end

---
--- Control Focus Directional Selection
---

function StateGame.controlFocusDirectionalSelectionDraw()
	--- Directional Help, top left corner of screen
	love.graphics.setFont(gameFonts.slkscr20)
	love.graphics.print(controlFocus.directionalSelection.helpText .. '  Directional Keys pick target.  ESC to go back.', 10, 10)
end

function StateGame.controlFocusDirectionalSelectionKeypressed(key, isrepeat)
	if key == 'escape' then 
		controlFocus.directionalSelection = false 
	else 
		local dx, dy = StateGame.inputMovementKeyPressed(key, isrepeat)
		if dx and dy then 
			controlFocus.directionalSelection.dx = dx 
			controlFocus.directionalSelection.dy = dy 
			if controlFocus.directionalSelection.confirmfunc() then
				controlFocus.directionalSelection = false 
			end
		end
	end
end

---
--- Control Focus Character Screen
---

function StateGame.controlFocusCharacterDraw()
	local startx = math.floor(love.graphics.getWidth() / 2) - 450
	local starty = math.floor(love.graphics.getHeight() / 2)
	local itemsy = 15
	local width = 900
	local height = 555
	local items = {
		{'Name', controlFocus.focus.name, {0.44,0.44,0.49}},
		{'', '', {1,1,1}},
		{'Level', controlFocus.focus.stats.level, {0.44,0.44,0.49}},
		{'XP', controlFocus.focus.currentXP .. ' / ' .. Creature.getXPNeededToLevel(controlFocus.focus), {0.44,0.44,0.49}},
		{'', '', {1,1,1}},
		{'Vitality', Creature.getVitality(controlFocus.focus), {1,0.4,0.4}},
		{'Endurance', Creature.getEndurance(controlFocus.focus), {0.4,1,0.4}},
		{'Strength', Creature.getStrength(controlFocus.focus), {1,0.53,0.29}},
		{'Dexterity', Creature.getDexterity(controlFocus.focus), {0.3,0.85,1}},
		{'Intelligence', Creature.getIntelligence(controlFocus.focus), {0.86,0.36,1}},
		{'Resolve', Creature.getResolve(controlFocus.focus), {1,1,0.36}},
		{'Free Points', controlFocus.focus.attributePoints, {0.44,0.44,0.49}},
		{'', '', {1,1,1}},
		{'Armor Value', Creature.getAV(controlFocus.focus), {0.44,0.44,0.49}},
		{'Dodge Value', Creature.getDV(controlFocus.focus), {0.44,0.44,0.49}},
		{'Electric Defense', Creature.getElectricDefense(controlFocus.focus), {0.44,0.44,0.49}},
		{'', '', {1,1,1}},
		{'Move Cost', Creature.getMoveCost(controlFocus.focus), {0.44,0.44,0.49}},
		{'Action Cost', Creature.getActionCost(controlFocus.focus), {0.44,0.44,0.49}},
	}
	starty = starty - height / 2
	--- Directional Help, top left corner of screen
	love.graphics.setFont(gameFonts.slkscr20)
	love.graphics.print('Character Screen.  Directional Keys interact.  Spacebar to select.  Escape to quit.', 10, 10)
	--- Container label
	love.graphics.setFont(gameFonts.pixelu24)
	love.graphics.printf('CHARACTER', startx, starty - 32, width, "center")
	--- Container frame
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle('fill', startx, starty, width, height)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle('line', startx, starty, width, height)
	love.graphics.setLineWidth(1)
	--- Draw Character attributes
	for i = 1, # items do 
		if (controlFocus.selection + 5) == i and controlFocus.focus.attributePoints > 0 then 
			love.graphics.setColor(1, 1, 1, 0.39)
			love.graphics.rectangle('fill', startx + 40, starty + itemsy + i * 22, 280, 20)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print('>', startx + 45, starty + itemsy + i * 22)
			love.graphics.print('<', startx + 300, starty + itemsy + i * 22)
			love.graphics.setColor(items[i][3])
		else 
			love.graphics.setColor({0.44,0.44,0.49})
		end
		love.graphics.setFont(gameFonts.slkscr20)
		love.graphics.printf(items[i][1], startx + 15, starty + itemsy + i * 22, 210, "right")
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(items[i][2], startx + 240, starty + itemsy + i * 22)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function StateGame.controlFocusCharacterUpdate(dt)

end

function StateGame.controlFocusCharacterKeypressed(key, isrepeat)
	if key == 'escape' then 
		controlFocus = false 
	else 
		if key == inputKeys.moveNorth[1] or key == inputKeys.moveNorth[2] then 
			controlFocus.selection = controlFocus.selection - 1 
			if controlFocus.selection < 1 then 
				controlFocus.selection = 6
			end
		elseif key == inputKeys.moveSouth[1] or key == inputKeys.moveSouth[2] then 
			controlFocus.selection = controlFocus.selection + 1 
			if controlFocus.selection > 6 then 
				controlFocus.selection = 1
			end
		elseif key == inputKeys.interact[1] or key == inputKeys.interact[2] then 
			if controlFocus.focus.attributePoints > 0 then 
				local stat = {'vitality', 'endurance', 'strength', 'dexterity', 'intelligence', 'resolve'}
				controlFocus.focus.stats[stat[controlFocus.selection]] = controlFocus.focus.stats[stat[controlFocus.selection]] + 1
				controlFocus.focus.attributePoints = controlFocus.focus.attributePoints - 1
			end
		end
	end
end

---
--- Control Focus Target
---

function StateGame.controlFocusTargetDraw()
	love.graphics.setFont(gameFonts.slkscr20)
	love.graphics.print('Fire at what?  Directional Keys choose target.  Spacebar to fire weapon.  ESC to quit.', 10, 10)
	gameCamera:attach()
	if controlFocus.targetX ~= controlFocus.startX or controlFocus.targetY ~= controlFocus.startY and controlFocus.line then 
		for i = 1, # controlFocus.line do 
			love.graphics.setColor(0.75, 0.75, 0.75, 1)
			love.graphics.rectangle('line', controlFocus.line[i][1] * 16, controlFocus.line[i][2] * 16, 16, 16)
		end
	end 
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('line', controlFocus.startX * 16, controlFocus.startY * 16, 16, 16)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle('line', controlFocus.targetX * 16, controlFocus.targetY * 16, 16, 16)
	love.graphics.setColor(1, 1, 1, 1)
	gameCamera:detach()
end

function StateGame.controlFocusTargetUpdate(dt)

end

function StateGame.controlFocusTargetKeypressed(key, isrepeat)
	local dx, dy = StateGame.inputMovementKeyPressed(key, isrepeat)
	local bool = false
	if key == 'escape' then 
		controlFocus = false 
	elseif key == inputKeys.interact[1] or key == inputKeys.interact[2] then 
		Creature.fireRangedWeapon(PlayerCharacter, controlFocus.targetX, controlFocus.targetY)
		controlFocus = false 
	else 
		if dx and dy then 
			controlFocus.targetX = controlFocus.targetX + dx 
			controlFocus.targetY = controlFocus.targetY + dy 
			controlFocus.line, bool = Map.bresenhamLine(controlFocus.startX, controlFocus.startY, controlFocus.targetX, controlFocus.targetY)
		end 
	end
end

---
--- Control Focus Container
---

function StateGame.controlFocusContainerDraw()
	if not controlFocus.focus.itemFocus then 
		local startx = math.floor(love.graphics.getWidth() / 2) - 450
		local starty = math.floor(love.graphics.getHeight() / 2)
		local width = 900
		local height = # controlFocus.focus.items * 20 + 60
		local sortTab = 'start'
		for i = 1, # controlFocus.focus.items do 
			if sortTab ~= controlFocus.focus.items[i].sorted then 
				sortTab = controlFocus.focus.items[i].sorted 
				height = height + 20 
			end
		end
		starty = starty - height / 2
		if controlFocus.focus.containerType == 'equipment' then 
			height = # PlayerCharacter.equipSlots * 20 + 60
			starty = starty - height / 2
		end
		--- Directional Help, top left corner of screen
		love.graphics.setFont(gameFonts.slkscr20)
		if controlFocus.focus.containerType == 'world' or controlFocus.focus.container.itemType then 
			love.graphics.print('Take which items?  Directional Keys choose item.  Spacebar to pickup item.  ESC to quit.', 10, 10)
		elseif controlFocus.focus.containerType == 'inventory' and controlFocus.focus.container == PlayerCharacter then 
			love.graphics.print('Inventory.  Directional Keys choose item.  Spacebar to interact with item.  ESC to quit.', 10, 10)
		elseif controlFocus.focus.containerType == 'equipment' and controlFocus.focus.container == PlayerCharacter then 
			love.graphics.print('Equipment.  Directional Keys choose item.  Spacebar to interact with item.  ESC to quit.', 10, 10)
		end
		--- Container frame
		love.graphics.setColor(0, 0, 0, 0.75)
		love.graphics.rectangle('fill', startx, starty, width, height)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setLineWidth(3)
		love.graphics.rectangle('line', startx, starty, width, height)
		love.graphics.setLineWidth(1)
		--- Container Label
		love.graphics.setFont(gameFonts.pixelu24)
		if controlFocus.focus.containerType == 'world' then 
			love.graphics.printf('ITEMS ON GROUND', startx, starty - 32, width, "center")
		elseif controlFocus.focus.containerType == 'inventory' and controlFocus.focus.container == PlayerCharacter then 
			love.graphics.printf('INVENTORY', startx, starty - 32, width, "center")
		elseif controlFocus.focus.containerType == 'equipment' and controlFocus.focus.container == PlayerCharacter then 
			love.graphics.printf('EQUIPMENT', startx, starty - 32, width, "center")
		elseif controlFocus.focus.containerType == 'inventory' and controlFocus.focus.container.itemType then 
			love.graphics.printf(string.upper(controlFocus.focus.container.name), startx, starty - 32, width, "center")
		end
		--- Print Item names
		love.graphics.setFont(gameFonts.slkscr20)
		if controlFocus.focus.containerType == 'equipment' then 
			for i = 1, # PlayerCharacter.equipSlots do 
				if controlFocus.focus.selection == i then 
					love.graphics.setColor(1, 1, 1, 0.39)
					love.graphics.rectangle('fill', startx + 20, starty + 10 + i * 20, 860, 20)
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.print('>', startx + 25, starty + 10 + i * 20)
					love.graphics.print('<', startx + 860 - 1, starty + 10 + i * 20)
				else 
					love.graphics.setColor({0.44,0.44,0.49})
				end
				love.graphics.printf(PlayerCharacter.equipSlots[i].name .. ':', startx + 20, starty + 10 + i * 20, 230, "right")
				if PlayerCharacter.equipSlots[i].equip then 
					love.graphics.setColor(PlayerCharacter.equipSlots[i].equip.item.color[1], PlayerCharacter.equipSlots[i].equip.item.color[2], PlayerCharacter.equipSlots[i].equip.item.color[3], 255)
					love.graphics.draw(Item.getItemImages()[PlayerCharacter.equipSlots[i].equip.item.img], startx + 260, starty - 3 + i * 20, 0, 3, 3)
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.print(Item.getDisplayName(PlayerCharacter.equipSlots[i].equip), startx + 310, starty + 10 + i * 20)
				end
			end
		else
			if # controlFocus.focus.items < 1 then 
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				love.graphics.printf('---Empty---', startx, starty + 18, width, "center")
				love.graphics.setColor(1, 1, 1, 1)
			else
				local ydraw = 1
				sortTab = 'start'
				for i = 1, # controlFocus.focus.items do 
					--- Draw selection bar if applicable
					if sortTab ~= controlFocus.focus.items[i].sorted then 
						sortTab = controlFocus.focus.items[i].sorted
						love.graphics.setColor({0.44,0.44,0.49})
						love.graphics.print(controlFocus.focus.items[i].sortTitle, startx + 40, starty + 10 + ydraw * 20)
						love.graphics.setColor(1, 1, 1, 1)
						ydraw = ydraw + 1 
					end
					if controlFocus.focus.selection == i then 
						love.graphics.setColor(1, 1, 1, 0.4)
						love.graphics.rectangle('fill', startx + 20, starty + 10 + ydraw * 20, 860, 20)
						love.graphics.setColor(1, 1, 1, 0.4)
						love.graphics.print('>', startx + 25, starty + 10 + ydraw * 20)
						love.graphics.print('<', startx + 859, starty + 10 + ydraw * 20)
					end
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.print(Item.getDisplayName(controlFocus.focus.items[i]), startx + 100, starty + 10 + ydraw * 20)
					love.graphics.setColor(controlFocus.focus.items[i].item.color[1], controlFocus.focus.items[i].item.color[2], controlFocus.focus.items[i].item.color[3])
					love.graphics.draw(Item.getItemImages()[controlFocus.focus.items[i].item.img], startx + 50, starty - 3 + ydraw * 20, 0, 3, 3)
					love.graphics.setColor(1, 1, 1)
					ydraw = ydraw + 1
				end
			end
		end
	elseif controlFocus.focus.itemFocus then 
		StateGame.controlFocusContainerDrawItemFocus()
	end
end

function StateGame.controlFocusContainerDrawItemFocus()
	local startx = math.floor(love.graphics.getWidth() / 2) - 350
	local starty = math.floor(love.graphics.getHeight() / 2)
	local width = 700
	local height = 400
	local printdesc = true
	local selectionwidth = 175
	starty = starty - height / 2
	if controlFocus.focus.options and controlFocus.focus.options[1].option == 'equipitem' then
		width = 900
		printdesc = false
		selectionwidth = 860
		startx = math.floor(love.graphics.getWidth() / 2) - 450
	end
	--- Directional Help, top left corner of screen
	love.graphics.setFont(gameFonts.slkscr20)
	love.graphics.print('Interact with item?  Directional Keys choose option.  Spacebar to confirm.  ESC to go back.', 10, 10)
	--- Container frame
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle('fill', startx, starty, width, height)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle('line', startx, starty, width, height)
	love.graphics.setLineWidth(1)
	--- Item Name 
	love.graphics.print(Item.getDisplayName(controlFocus.focus.itemFocus), startx + 80, starty + 35)
	love.graphics.setColor(controlFocus.focus.itemFocus.item.color[1], controlFocus.focus.itemFocus.item.color[2], controlFocus.focus.itemFocus.item.color[3])
	love.graphics.draw(Item.getItemImages()[controlFocus.focus.itemFocus.item.img], startx + 30, starty + 22, 0, 3, 3)
	love.graphics.setColor(1, 1, 1, 1)
	--- Item desc 
	if printdesc then 
		love.graphics.printf(controlFocus.focus.itemFocus.item.desc, startx + 230, starty + 80, 450, "left")
	end
	--- Print Options
	for i = 1, # controlFocus.focus.options do 
		--- Draw selection bar if applicable
		if controlFocus.focus.selection == i then 
			love.graphics.setColor(1, 1, 1, 0.4)
			love.graphics.rectangle('fill', startx + 20, starty + 100 + i * 20, selectionwidth, 20)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print('>', startx + 25, starty + 100 + i * 20)
			love.graphics.print('<', startx + selectionwidth - 1, starty + 100 + i * 20)
		end
		--- Hard coded menu function! Woooo!
		if controlFocus.focus.options[i].amountSelection then 
			local printAmount = tonumber(controlFocus.amountSelection) or 0
			love.graphics.print(controlFocus.amountSelectionHelp, startx + 20, starty + 100 + (# controlFocus.focus.options + 2) * 20)
			love.graphics.setColor({0.44,0.44,0.49})
			if controlFocus.focus.selection == i then 
				love.graphics.setColor(1, 1, 1, 1)
			end
			love.graphics.print(controlFocus.focus.options[i].name .. tostring(printAmount), startx + 40, starty + 100 + i * 20)
			love.graphics.setColor(1, 1, 1, 1)
		else 
			if controlFocus.focus.options and controlFocus.focus.options[i].option == 'equipitem' then 
				love.graphics.setColor({0.44,0.44,0.49})
				if controlFocus.focus.selection == i then 
					love.graphics.setColor(1, 1, 1, 1)
				end
				love.graphics.printf(controlFocus.focus.options[i].name, startx + 20, starty + 100 + i * 20, 230, "right")
				love.graphics.setColor(1, 1, 1, 1)
				if PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot] then 
					if PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot].equip then 
						love.graphics.setColor(PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot].equip.item.color[1], PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot].equip.item.color[2], PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot].equip.item.color[3], 255)
						love.graphics.draw(Item.getItemImages()[PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot].equip.item.img], startx + 260, starty + 87 + i * 20, 0, 3, 3)
						love.graphics.setColor(1, 1, 1, 1)
						love.graphics.print(Item.getDisplayName(PlayerCharacter.equipSlots[controlFocus.focus.options[i].slot].equip), startx + 310, starty + 100 + i * 20)
					end
				end
			else 
				love.graphics.setColor({0.44,0.44,0.49})
				if controlFocus.focus.selection == i then 
					love.graphics.setColor(1, 1, 1, 1)
				end
				love.graphics.print(controlFocus.focus.options[i].name, startx + 40, starty + 100 + i * 20)
				love.graphics.setColor(1, 1, 1, 1)
			end
		end
	end
	--- Container Label
	love.graphics.setFont(gameFonts.pixelu24)
	love.graphics.printf('ITEM', startx, starty - 32, width, "center")
end

function StateGame.controlFocusContainerUpdate(dt)
end

function StateGame.controlFocusContainerKeypressed(key, isrepeat)
	--- Amount Selection Control
	if controlFocus and controlFocus.focus and controlFocus.focus.itemFocus and controlFocus.allowAmountSelection then 
		if key == 'backspace' and controlFocus.amountSelection and string.len(controlFocus.amountSelection) > 0 then 
			controlFocus.amountSelection = string.sub(controlFocus.amountSelection, 1, string.len(controlFocus.amountSelection) - 1)
		elseif tonumber(key) then 
			if not controlFocus.amountSelection then 
				controlFocus.amountSelection = key
			else
				controlFocus.amountSelection = controlFocus.amountSelection .. key 
			end
		end
		if (tonumber(controlFocus.amountSelection) or 0) > controlFocus.focus.itemFocus.stack then 
			controlFocus.amountSelection = tostring(controlFocus.focus.itemFocus.stack)
		end
	end
	--- Menu Control
	if key == 'escape' then 
		if not controlFocus.focus.itemFocus then 
			controlFocus = false
		else 
			controlFocus.focus.itemFocus = false 
			controlFocus.focus.selection = controlFocus.focus.prevSelection
		end 
	elseif key == inputKeys.moveSouth[1] or key == inputKeys.moveSouth[2] then 
		local comp = # controlFocus.focus.items 
		controlFocus.focus.selection = controlFocus.focus.selection + 1 
		if controlFocus.focus.containerType == 'equipment' then 
			comp = # PlayerCharacter.equipSlots 
		end
		if controlFocus.focus.itemFocus then 
			comp = # controlFocus.focus.options
		end
		if controlFocus.focus.selection > comp then 
			controlFocus.focus.selection = 1 
		end 
	elseif key == inputKeys.moveNorth[1] or key == inputKeys.moveNorth[2] then 
		local comp = # controlFocus.focus.items 
		controlFocus.focus.selection = controlFocus.focus.selection - 1 
		if controlFocus.focus.containerType == 'equipment' then 
			comp = # PlayerCharacter.equipSlots 
		end
		if controlFocus.focus.itemFocus then 
			comp = # controlFocus.focus.options
		end
		if controlFocus.focus.selection < 1 then 
			controlFocus.focus.selection = comp
		end 
	elseif key == inputKeys.interact[1] or key == inputKeys.interact[2] then 
		if not controlFocus.focus.itemFocus then 
			if controlFocus.focus.containerType == 'equipment' then 
				if PlayerCharacter.equipSlots[controlFocus.focus.selection].equip then 
					controlFocus.focus.itemFocus = PlayerCharacter.equipSlots[controlFocus.focus.selection].equip
					controlFocus.focus.options = {{option = 'remove', name = 'Remove', slot = controlFocus.focus.selection},{option = 'back', name = 'Back...'}}
					controlFocus.focus.prevSelection = controlFocus.focus.selection 
					controlFocus.focus.selection = 1 
				end
			else 
				controlFocus.focus.itemFocus = controlFocus.focus.items[controlFocus.focus.selection]
				controlFocus.focus.prevSelection = controlFocus.focus.selection
				controlFocus.focus.selection = 1
				if controlFocus.focus.containerType == 'world' then 
					if controlFocus.focus.itemFocus.item.container then 
						controlFocus.focus.options = {{option = 'pickup', name = 'Pick Up'}, {option = 'open', name = 'Open'}, {option = 'back', name = 'Back...'}}
					else
						if controlFocus.focus.itemFocus.stack > 1 then 
							controlFocus.focus.options = {{option = 'pickup', name = 'Pick Up All'},{option = 'pickupx', name = 'Pick Up X'},{option = 'back', name = 'Back...'}}
						else 
							controlFocus.focus.options = {{option = 'pickup', name = 'Pick Up'},{option = 'back', name = 'Back...'}}
						end
					end
				elseif controlFocus.focus.container == PlayerCharacter then 
					controlFocus.focus.options = { }
					if not controlFocus.addToOtherContainer then 
						if controlFocus.focus.itemFocus.item.applicable then 
							table.insert(controlFocus.focus.options, {option = 'apply', name = 'Apply'})
							table.insert(controlFocus.focus.options, {option = 'applyto', name = 'Apply To'})
						end
						if controlFocus.focus.itemFocus.item.container then 
							table.insert(controlFocus.focus.options, {option = 'open', name = 'Open'})
						end
						table.insert(controlFocus.focus.options, {option = 'equip', name = 'Equip'})
						table.insert(controlFocus.focus.options, {option = 'drop', name = 'Drop'})
					else 
						if controlFocus.focus.itemFocus.stack > 1 then 
							controlFocus.focus.options = {{option = 'addto', name = 'Add All'},{option = 'addtox', name = 'Add X'}}
						else 
							controlFocus.focus.options = {{option = 'addto', name = 'Add'}}
						end
					end
					table.insert(controlFocus.focus.options, {option = 'back', name = 'Back...'})
				elseif controlFocus.focus.container.itemType then 
					if controlFocus.focus.itemFocus.item.container then 
						controlFocus.focus.options = {{option = 'pickup', name = 'Take'}, {option = 'open', name = 'Open'}, {option = 'back', name = 'Back...'}}
					else
						if controlFocus.focus.itemFocus.stack > 1 then 
							controlFocus.focus.options = {{option = 'pickup', name = 'Take All'},{option = 'pickupx', name = 'Take X'},{option = 'back', name = 'Back...'}}
						else 
							controlFocus.focus.options = {{option = 'pickup', name = 'Take'},{option = 'back', name = 'Back...'}}
						end
					end
				end
			end
		else 
			if controlFocus.focus.options[controlFocus.focus.selection].option == 'pickup' then 
				local suc = Creature.addItemToInventory(PlayerCharacter, controlFocus.focus.itemFocus)
				if suc then 
					local word = Message.aOrAn(Item.getDisplayName(controlFocus.focus.items[controlFocus.focus.selection]))		
					if controlFocus.focus.container and controlFocus.focus.container.itemType then
						for i = # controlFocus.focus.container.container, 1, -1 do 
							if controlFocus.focus.container.container[i] == controlFocus.focus.itemFocus then 
								table.remove(controlFocus.focus.container.container, i)
								break 
							end
						end
					else 
						Item.removeFromWorld(controlFocus.focus.itemFocus)
					end
					StateGame.sendMessage({text = 'You picked up ' .. word .. ' ' .. Item.getDisplayName(controlFocus.focus.items[controlFocus.focus.selection]) , color = {1, 1, 1}})
					Creature.waitTurn(PlayerCharacter, true)
					controlFocus.focus.itemFocus = false
					controlFocus.focus.selection = 1
					table.remove(controlFocus.focus.items, controlFocus.focus.prevSelection)
					if # controlFocus.focus.items <= 0 then 
						controlFocus = false
					end
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'addto' then 
				local word = Message.aOrAn(Item.getDisplayName(controlFocus.focus.itemFocus))
				StateGame.sendMessage({text = 'You put ' .. word .. ' ' .. Item.getDisplayName(controlFocus.focus.itemFocus) .. ' away.', color = {1, 1, 1}})
				table.insert(controlFocus.addToOtherContainer, controlFocus.focus.itemFocus)
				Creature.removeItemFromInventory(PlayerCharacter, controlFocus.focus.itemFocus)
				for i = # controlFocus.focus.items, 1, -1 do 
					if controlFocus.focus.items[i] == controlFocus.focus.itemFocus then 
						table.remove(controlFocus.focus.items, i) 
						break 
					end 
				end
				Creature.waitTurn(PlayerCharacter, true)
				controlFocus.selection = 1
				controlFocus.focus.itemFocus = false 
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'addtox' then 
				controlFocus.focus.backOption = controlFocus.focus.options 
				controlFocus.focus.selection = 1
				controlFocus.amountSelection = false
				controlFocus.allowAmountSelection = true
				controlFocus.amountSelectionHelp = 'Number Keys:\nInput amount\nto put in\n\nBackspace:\nUndo amount'
				controlFocus.focus.options = {{option = 'addxitem', name = 'Add x', amountSelection = true}, {option = 'back', name = 'Back...'}}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'addxitem' then 
				local amountpickedup = tonumber(controlFocus.amountSelection) or 0
				if amountpickedup > 0 then 
					local pickedupitem = Item.duplicateItem(controlFocus.focus.itemFocus)
					local word = ''
					local dsel = 0
					pickedupitem.stack = amountpickedup 
					word = Message.aOrAn(Item.getDisplayName(pickedupitem))
					table.insert(controlFocus.addToOtherContainer, pickedupitem)
					StateGame.sendMessage({text = 'You put ' .. word .. ' ' .. Item.getDisplayName(pickedupitem) .. ' away.', color = {1, 1, 1}})
					if amountpickedup >= controlFocus.focus.itemFocus.stack then 
						Creature.removeItemFromInventory(PlayerCharacter, controlFocus.focus.itemFocus)
						controlFocus.focus.items = Item.sortContainer(PlayerCharacter.inventory, true)
						dsel = -1
					else 
						controlFocus.focus.itemFocus.stack = controlFocus.focus.itemFocus.stack - amountpickedup
					end 
					Creature.waitTurn(PlayerCharacter, true)
					controlFocus.allowAmountSelection = false 
					controlFocus.amountSelection = false
					controlFocus.focus.options = false
					controlFocus.focus.backOption = false
					controlFocus.focus.itemFocus = false
					controlFocus.focus.selection = math.max(1, controlFocus.focus.prevSelection + dsel)
					Creature.waitTurn(PlayerCharacter, true)
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'open' then 
				controlFocus.focus.selection = 1 
				controlFocus.focus.options = {{option = 'takeitem', name = 'Take Item'}, {option = 'additem', name = 'Add Item'}, {option = 'back', name = 'Back...'}}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'additem' then 
				local containertoaddto = controlFocus.focus.itemFocus.item.container 
				controlFocus = {type = 'container', addToOtherContainer = containertoaddto, focus = {selection = 1, items = Item.sortContainer(PlayerCharacter.inventory, true), containerType = 'inventory', container = PlayerCharacter, itemFocus = false, options = { }}}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'takeitem' then 
				local containertoacces = controlFocus.focus.itemFocus.item.container
				controlFocus = {type = 'container', focus = {selection = 1, items = Item.sortContainer(containertoacces), containerType = 'inventory', container = controlFocus.focus.itemFocus.item, itemFocus = false, options = { }}}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'remove' then 
				Creature.removeItem(PlayerCharacter, controlFocus.focus.options[controlFocus.focus.selection].slot)
				controlFocus.focus.itemFocus = false 
				controlFocus.focus.selection = controlFocus.focus.prevSelection
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'equip' then 
				controlFocus.focus.backOption = controlFocus.focus.options 
				controlFocus.focus.options = { }
				controlFocus.focus.selection = 1
				table.insert(controlFocus.focus.options, {option = 'equipitem', slot = 1, name = 'Main Hand:'})
				table.insert(controlFocus.focus.options, {option = 'equipitem', slot = 2, name = 'Off Hand:'})
				if controlFocus.focus.itemFocus.item.stats.equipSlot and controlFocus.focus.itemFocus.item.stats.equipSlot == 'ranged' then 
					table.insert(controlFocus.focus.options, {option = 'equipitem', slot = 3, name = 'Ranged Weapon:'})
				end
				table.insert(controlFocus.focus.options, {option = 'equipitem', slot = 4, name = 'Throwing Weapon:'})
				for i = 5, # PlayerCharacter.equipSlots do 
					if controlFocus.focus.itemFocus.item.stats.equipSlot and PlayerCharacter.equipSlots[i].slot == controlFocus.focus.itemFocus.item.stats.equipSlot then 
						table.insert(controlFocus.focus.options, {
							option = 'equipitem',
							slot = i, 
							name = PlayerCharacter.equipSlots[i].name .. ':',
							})
					end
				end
				table.insert(controlFocus.focus.options, {option = 'back', name = 'Back...'})
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'equipitem' then 
				if Creature.equipItem(PlayerCharacter, controlFocus.focus.options[controlFocus.focus.selection].slot, controlFocus.focus.itemFocus) then 
					controlFocus.focus.itemFocus = false 
					PlayerCharacter.inventory = Item.sortContainer(PlayerCharacter.inventory)
					controlFocus.focus.items = PlayerCharacter.inventory
					if controlFocus.focus.prevSelection > 1 then 
						controlFocus.focus.prevSelection = controlFocus.focus.prevSelection - 1
					end
					controlFocus.focus.selection = controlFocus.focus.prevSelection
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'applyto' then 
				controlFocus.directionalSelection = {
					dx = 0, 
					dy = 0, 
					sx = Creature.getX(PlayerCharacter),
					sy = Creature.getY(PlayerCharacter),
					helpText = 'Apply ' .. Item.getDisplayName(controlFocus.focus.itemFocus, true) .. ' to?',
					confirmfunc =	function ()
										local target = Creature.isCreatureAt(controlFocus.directionalSelection.sx + controlFocus.directionalSelection.dx, controlFocus.directionalSelection.sy + controlFocus.directionalSelection.dy)
										if target then 
											Creature.applyItemToCreature(PlayerCharacter, target, controlFocus.focus.itemFocus)
											Creature.waitTurn(PlayerCharacter, true)
											return true
										else 
											StateGame.sendMessage({text = 'There is nothing there to apply this to.', color = {1, 1, 1}})
											return false
										end
									end
				}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'apply' then 
				Creature.applyItemToSelf(PlayerCharacter, controlFocus.focus.itemFocus)
				controlFocus.focus.options = false 
				controlFocus.focus.itemFocus = false
				controlFocus.focus.selection = controlFocus.focus.prevSelection
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'drop' then 
				controlFocus.focus.backOption = controlFocus.focus.options 
				if controlFocus.focus.itemFocus.stack > 1 then 
					controlFocus.focus.selection = 1
					controlFocus.focus.options = {{option = 'dropall', name = 'Drop All'}, {option = 'dropx', name = 'Drop X'}, {option = 'back', name = 'Back...'}}
				else 
					local word = Message.aOrAn(Item.getDisplayName(controlFocus.focus.itemFocus))
					Creature.removeItemFromInventory(controlFocus.focus.container, controlFocus.focus.itemFocus)
					Item.dropItemFromContainer(controlFocus.focus.itemFocus, Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter))
					StateGame.sendMessage({text = 'You dropped ' .. word .. ' ' .. Item.getDisplayName(controlFocus.focus.itemFocus), color = {1, 1, 1}})
					Creature.waitTurn(PlayerCharacter, true)
					controlFocus.focus.itemFocus = false 
					controlFocus.focus.options = false 
					controlFocus.focus.selection = controlFocus.focus.prevSelection - 1
					if controlFocus.focus.selection < 1 then 
						controlFocus.focus.selection = 1
					end
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'dropall' then 
				local word = Message.aOrAn(Item.getDisplayName(controlFocus.focus.itemFocus))
				Creature.removeItemFromInventory(controlFocus.focus.container, controlFocus.focus.itemFocus)
				Item.dropItemFromContainer(controlFocus.focus.itemFocus, Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter))
				StateGame.sendMessage({text = 'You dropped ' .. word .. ' ' .. Item.getDisplayName(controlFocus.focus.itemFocus), color = {1, 1, 1}})
				Creature.waitTurn(PlayerCharacter, true)
				controlFocus.focus.itemFocus = false 
				controlFocus.focus.options = false 
				controlFocus.amountSelectionHelp = 'Number Keys:\nInput amount\nto pick up\n\nBackspace:\nUndo amount'
				controlFocus.focus.selection = controlFocus.focus.prevSelection - 1
				if controlFocus.focus.selection < 1 then 
					controlFocus.focus.selection = 1
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'pickupx' then 
				controlFocus.focus.backOption = controlFocus.focus.options 
				controlFocus.focus.selection = 1
				controlFocus.amountSelection = false
				controlFocus.allowAmountSelection = true
				controlFocus.amountSelectionHelp = 'Number Keys:\nInput amount\nto pick up\n\nBackspace:\nUndo amount'
				controlFocus.focus.options = {{option = 'pickupxitem', name = 'Pick Up x', amountSelection = true}, {option = 'back', name = 'Back...'}}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'dropx' then 
				controlFocus.focus.selection = 1
				controlFocus.amountSelection = false
				controlFocus.allowAmountSelection = true
				controlFocus.amountSelectionHelp = 'Number Keys:\nInput amount\nto drop\n\nBackspace:\nUndo amount'
				controlFocus.focus.options = {{option = 'dropxitem', name = 'Drop x', amountSelection = true}, {option = 'back', name = 'Back...'}}
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'pickupxitem' then 
				local amountpickedup = tonumber(controlFocus.amountSelection) or 0
				if amountpickedup > 0 then 
					local pickedupitem = Item.duplicateItem(controlFocus.focus.itemFocus)
					local word = ''
					local dsel = 0
					pickedupitem.stack = amountpickedup 
					word = Message.aOrAn(Item.getDisplayName(pickedupitem))
					Creature.addItemToInventory(PlayerCharacter, pickedupitem)
					StateGame.sendMessage({text = 'You picked up ' .. word .. ' ' .. Item.getDisplayName(pickedupitem) , color = {1, 1, 1}})
					if amountpickedup >= controlFocus.focus.itemFocus.stack then 
						Item.removeFromWorld(controlFocus.focus.itemFocus)
						if controlFocus.focus.container then
							for i = # controlFocus.focus.container.container, 1, -1 do 
								if controlFocus.focus.container.container[i] == controlFocus.focus.itemFocus then 
									table.remove(controlFocus.focus.container.container, i)
									break 
								end
							end
						end
						for i = 1, # controlFocus.focus.items do 
							if controlFocus.focus.items[i] == controlFocus.focus.itemFocus then 
								table.remove(controlFocus.focus.items, i) 
								break 
							end
						end
						dsel = -1
					else 
						controlFocus.focus.itemFocus.stack = controlFocus.focus.itemFocus.stack - amountpickedup
					end 
					Creature.waitTurn(PlayerCharacter, true)
					controlFocus.allowAmountSelection = false 
					controlFocus.amountSelection = false
					controlFocus.focus.options = false
					controlFocus.focus.backOption = false
					controlFocus.focus.itemFocus = false
					controlFocus.focus.selection = math.max(1, controlFocus.focus.prevSelection + dsel)
					Creature.waitTurn(PlayerCharacter, true)
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'dropxitem' then 
				local amountdropped = tonumber(controlFocus.amountSelection) or 0
				if amountdropped > 0 then 
					local droppeditem = Item.duplicateItem(controlFocus.focus.itemFocus)
					local word = ''
					local dsel = 0
					droppeditem.stack = amountdropped 
					word = Message.aOrAn(Item.getDisplayName(droppeditem))
					Item.dropItemFromContainer(droppeditem, Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter))
					StateGame.sendMessage({text = 'You dropped ' .. word .. ' ' .. Item.getDisplayName(droppeditem), color = {1, 1, 1}})
					if amountdropped == controlFocus.focus.itemFocus.stack then 
						Creature.removeItemFromInventory(controlFocus.focus.container, controlFocus.focus.itemFocus)
						dsel = -1
					else 
						controlFocus.focus.itemFocus.stack = controlFocus.focus.itemFocus.stack - amountdropped 
					end 
					controlFocus.allowAmountSelection = false 
					controlFocus.amountSelection = false
					controlFocus.focus.options = false
					controlFocus.focus.backOption = false
					controlFocus.focus.itemFocus = false
					controlFocus.focus.selection = math.max(1, controlFocus.focus.prevSelection + dsel)
					Creature.waitTurn(PlayerCharacter, true)
				end
			elseif controlFocus.focus.options[controlFocus.focus.selection].option == 'back' then 
				controlFocus.allowAmountSelection = false 
				controlFocus.amountSelection = false
				if not controlFocus.focus.backOption then 
					controlFocus.focus.itemFocus = false 
					controlFocus.focus.selection = controlFocus.focus.prevSelection
				else 
					controlFocus.focus.options = controlFocus.focus.backOption
					controlFocus.focus.backOption = false
					controlFocus.focus.selection = 1
				end
			end 
		end
	end
	if controlFocus and # controlFocus.focus.items < 1 and controlFocus.focus.containerType == 'world' then 
		controlFocus = false 
	end
end

---
--- Input
---

--- No controlFocus
--- Direct character control, movement, attacking, interacting...
function StateGame.inputNoControlFocus(key, isrepeat)
	--- Movement keys
	local dx, dy = StateGame.inputMovementKeyPressed(key, isrepeat)
	--- If movement key was pressed then move player character
	if dx and dy then 
		--- Wait a turn
		if dx == 0 and dy == 0 then 
			Creature.waitTurn(PlayerCharacter)
		else
			--- Forced Attack
			if love.keyboard.isDown(inputKeys.forcedAttack[1]) then 
				local hit = Creature.forcedMeleeAttack(PlayerCharacter, Creature.getX(PlayerCharacter) + dx, Creature.getY(PlayerCharacter) + dy)
				if not hit then 
					StateGame.sendMessage({text = 'You swing at the air.', color = {1, 1, 0.19}})
					PlayerCharacter.dx = PlayerCharacter.dx + dx / 2
					PlayerCharacter.dy = PlayerCharacter.dy + dy / 2
				end
				Creature.waitTurn(PlayerCharacter, true)
			--- Move player character
			else
				Creature.moveBy(PlayerCharacter, dx, dy)
				--- If there are items below the players feet at their new position then display a message
				local itemsBelowFeet = Item.getItemsAt(Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter))
				if # itemsBelowFeet == 1 then 
					local word = Message.aOrAn(Item.getDisplayName(itemsBelowFeet[1]))
					StateGame.sendMessage({text = 'You pass by ' .. word .. ' ' .. Item.getDisplayName(itemsBelowFeet[1]) .. '.', color = {1, 1, 1}})
				elseif # itemsBelowFeet > 1 then 
					StateGame.sendMessage({text = 'You pass by several items.', color = {1, 1, 1}})
				elseif # itemsBelowFeet > 9 then 
					StateGame.sendMessage({text = 'You pass by many items.', color = {1, 1, 1}})
				end
			end
		end
		--- The character has mvoed so recalculate the FOV around the player
		Map.calculateFOV(Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter), Creature.getSightRadius(PlayerCharacter))
	--- Movement was selected, other options
	else 
		--- Pickup Items
		if key == inputKeys.pickupItem[1] or key == inputKeys.pickupItem[2] then 
			StateGame.playerPickupWorldItems()
		--- Inventory
		elseif key == inputKeys.inventory[1] or key == inputKeys.inventory[2] then 
			PlayerCharacter.inventory = Item.sortContainer(PlayerCharacter.inventory)
			controlFocus = {type = 'container', focus = {selection = 1, items = Creature.getInventory(PlayerCharacter), containerType = 'inventory', container = PlayerCharacter, itemFocus = false, options = { }}}
		--- Equipment
		elseif key == inputKeys.equipment[1] or key == inputKeys.equipment[2] then 
			local equip = { }
			for i = 1, # PlayerCharacter.equipSlots do 
				if PlayerCharacter.equipSlots[i].equip then 
					table.insert(equip, PlayerCharacter.equipSlots[i].equip)
				end
			end
			controlFocus = {type = 'container', focus = {selection = 1, items = equip, containerType = 'equipment', container = PlayerCharacter, itemFocus = false, options = { }}}
		--- Character
		elseif key == inputKeys.character[1] or key == inputKeys.character[2] then 
			controlFocus = {type = 'character', focus = PlayerCharacter, selection = 1}
		--- Fire ranged weapon if applicable
		elseif key == inputKeys.fire[1] or key == inputKeys.fire[2] then 
			local wep = Creature.hasRangedWeaponEquipped(PlayerCharacter)
			if wep and wep.item.stats.rangedWeapon and wep.item.stats.rangedWeapon.currentAmmo > 0 then
				controlFocus = {type = 'target', focus = 'ranged', targetX = PlayerCharacter.x, targetY = PlayerCharacter.y, startX = PlayerCharacter.x, startY = PlayerCharacter.y}
			elseif wep and wep.item.stats.rangedWeapon and wep.item.stats.rangedWeapon.currentAmmo == 0 then
				StateGame.sendMessage({text = "Your weapon isn\'t loaded.", color = {1, 1, 1}})
			else 
				StateGame.sendMessage({text = "You don\'t have a ranged weapon equipped.", color = {1, 1, 1}})
			end
		--- Reload ranged weapon if applicable
		elseif key == inputKeys.reload[1] or key == inputKeys.reload[2] then 
			Creature.reloadRangedWeapon(PlayerCharacter)
		end
	end
end

--- Attempts to pickup items at the Player Characters feet.  Single items go directly
--- to the players inventory.  Multiple items swiches to container control to select
--- which items to pick up.
function StateGame.playerPickupWorldItems()
	local itemsBelowFeet = Item.getItemsAt(Creature.getX(PlayerCharacter), Creature.getY(PlayerCharacter))
	if # itemsBelowFeet > 0 then 
		itemsBelowFeet = Item.sortContainer(itemsBelowFeet)
		controlFocus = {type = 'container', focus = {selection = 1, items = itemsBelowFeet, containerType = 'world', container = false, itemFocus = false, options = { }}}
	end
end

--- Returns directional values dx,dy if a movement key was pressed
function StateGame.inputMovementKeyPressed(key, isrepeat)
	local dx, dy = false, false
	if key == inputKeys.moveWest[1] or key == inputKeys.moveWest[2] then 
		return -1, 0
	elseif key == inputKeys.moveEast[1] or key == inputKeys.moveEast[2] then 
		return 1, 0
	elseif key == inputKeys.moveNorth[1] or key == inputKeys.moveNorth[2] then 
		return 0, -1
	elseif key == inputKeys.moveSouth[1] or key == inputKeys.moveSouth[2] then 
		return 0, 1
	elseif key == inputKeys.moveNorthWest[1] or key == inputKeys.moveNorthWest[2] then 
		return -1, -1
	elseif key == inputKeys.moveNorthEast[1] or key == inputKeys.moveNorthEast[2] then 
		return 1, -1
	elseif key == inputKeys.moveSouthWest[1] or key == inputKeys.moveSouthWest[2] then 
		return -1, 1
	elseif key == inputKeys.moveSouthEast[1] or key == inputKeys.moveSouthEast[2] then 
		return 1, 1
	elseif key == inputKeys.waitTurn[1] or key == inputKeys.waitTurn[2] then 
		return 0, 0
	end
	return dx, dy
end

---
--- Messaging
---

function StateGame.sendMessage(msg)
	Message.receiveMessage(msg)
	Message.setCurrentTurn(gameCurrentTurn)
end

function StateGame.playerDeathTriggered()
	
end

function StateGame.incrementCurrentTurn()
 	gameCurrentTurn = gameCurrentTurn + 1
end

---
--- HUD
---

function StateGame.drawHUD()
	local cx, cy = StateGame.cameraMapLockCoords()
	local sx, sy = 12, love.graphics.getHeight()
	if PlayerCharacter.x <= cx - 5 then 
		sx = love.graphics.getWidth() - 600
	end
	StateGame.drawHealthBar(sx, sy - 47)
	StateGame.drawStaminaBar(sx, sy - 47 * 2)
	StateGame.drawBodyTempMoveCost(sx, sy - 47 * 3)
	StateGame.drawAVDV(sx, sy - 47 * 4)
	StateGame.drawAmmo(sx, sy - 47 * 5)
	if not controlFocus then 
		StateGame.drawNavHud(sx, 0)
	else
		StateGame.drawNavHud(sx, 28)
	end
	if StateGame.DEBUG then 
		love.graphics.setFont(gameFonts.slkscr30)
		love.graphics.print('FPS: ' .. love.timer.getFPS(), sx, love.graphics.getHeight() - 47 * 6)
	end
end

function StateGame.drawAmmo(sx, sy)
	local wep = Creature.hasRangedWeaponEquipped(PlayerCharacter)
	love.graphics.setFont(gameFonts.pixelu32)
	love.graphics.print('AMMO', sx, sy - 6)
	if wep and wep.item and wep.item.stats and wep.item.stats.rangedWeapon then 
		love.graphics.setFont(gameFonts.slkscr30)
		love.graphics.print(wep.item.stats.rangedWeapon.currentAmmo .. ' / ' .. wep.item.stats.rangedWeapon.maxAmmo, sx + 130, sy)
	else
		love.graphics.setFont(gameFonts.slkscr30)
		love.graphics.print('---', sx + 130, sy)
	end
end

function StateGame.drawNavHud(sx, sy)
	--- Label
	love.graphics.setFont(gameFonts.pixelu32)
	love.graphics.print('LOC', sx, sy)
	--- Location
	love.graphics.setFont(gameFonts.slkscr20)
	love.graphics.print('surface', sx + 85, sy + 12)
	--- World Map
	local worlds = Map.getGameWorldsLoaded()
	local worldPos = Map.getGameWorldPosition()
	local w = # worlds
	local h = # worlds[1]
	local dx, dy = 1, 1
	local img = false
	for x = math.max(1, worldPos[1] - 4), math.min(w, worldPos[1] + 4) do 
		for y = math.max(1, worldPos[2] - 4), math.min(h, worldPos[2] + 4) do 
			img = Map.getOverworldTile(x, y, 1)
			love.graphics.setColor(0, 0, 0, 0.75)
			love.graphics.rectangle('fill', sx + (dx-1) * 20, sy + 68 + (dy-1) * 22, 20, 22)
			love.graphics.setColor(1, 1, 1, 0.15)
			love.graphics.rectangle('line', sx + (dx-1) * 20, sy + 68 + (dy-1) * 22, 20, 22)
			if img then 
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.draw(img, sx + (dx-1) * 20, sy + 68 + (dy-1) * 22)
			else 
				love.graphics.setColor(0.25, 0.25, 0.25, 1)
				love.graphics.printf('?', sx + (dx-1) * 20, sy + 68 + (dy-1) * 22, 20, "center")
			end
			love.graphics.setFont(gameFonts.slkscr24)
			if worldPos[1] == x and worldPos[2] == y then 
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.rectangle('fill', sx + (dx-1) * 20, sy + 68 + (dy-1) * 22, 20, 22)
				love.graphics.setColor(0.78, 0.78, 0.78, 1)
				love.graphics.setLineWidth(2)
				love.graphics.rectangle('line', sx + (dx-1) * 20, sy + 68 + (dy-1) * 22, 20, 22)
				love.graphics.printf('@', sx + (dx-1) * 20, sy + 68 + (dy-1) * 22, 20, "center")
				love.graphics.setFont(gameFonts.slkscr18)
				love.graphics.print(Map.getOverworldTileName(x, y, 1), sx + 5, sy + 42)
			end
			love.graphics.setLineWidth(1)
			dy = dy + 1
		end 
		dy = 1
		dx = dx + 1
	end
	love.graphics.setColor(0.78, 0.78, 0.78, 1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line', sx, sy + 68, 20 * 9, 22 * 9)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(1)
end

function StateGame.drawBodyTempMoveCost(sx, sy)
	--- Print Label 
	love.graphics.setFont(gameFonts.pixelu32)
	love.graphics.print('AC', sx + 133, sy - 6)
	love.graphics.print('MC', sx, sy - 6)
	love.graphics.setFont(gameFonts.slkscr30)
	love.graphics.print(Creature.getActionCost(PlayerCharacter), sx + 193, sy)
	love.graphics.print(Creature.getMoveCost(PlayerCharacter), sx + 60, sy)
	love.graphics.setLineWidth(1)
end

function StateGame.drawAVDV(sx, sy)
	--- Print Label 
	love.graphics.setFont(gameFonts.pixelu32)
	love.graphics.print('AV', sx, sy - 6)
	love.graphics.print('DV', sx + 133, sy - 6)
	love.graphics.setFont(gameFonts.slkscr30)
	love.graphics.print(Creature.getAV(PlayerCharacter), sx + 60, sy)
	love.graphics.print(Creature.getDV(PlayerCharacter), sx + 193, sy)
	love.graphics.setLineWidth(1)
end

function StateGame.drawStaminaBar(sx, sy)
	local width = Creature.getMaxStamina(PlayerCharacter)
	local curwidth = Creature.getCurrentStamina(PlayerCharacter)
	love.graphics.setLineWidth(3)
	--- Draw Background
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle('fill', sx + 80, sy, 170, 32)
	--- Draw Stamina Progres Bar
	love.graphics.setColor(0.19, 0.49, 0.19, 1)
	love.graphics.rectangle('fill', sx + 80, sy, 170 * (curwidth / width), 32)
	--- Draw Foreground Border
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('line', sx + 80, sy, 170, 32)
	--- Print Stamina Amount on Bar
	love.graphics.setFont(gameFonts.slkscr24)
	love.graphics.print(curwidth .. ' / ' .. width, sx + 15 + 80, sy + 4)
	--- Print Label Before Stamina Bar
	love.graphics.setFont(gameFonts.pixelu32)
	love.graphics.print('END', sx, sy - 6)
	love.graphics.setLineWidth(1)
end

function StateGame.drawHealthBar(sx, sy)
	local width = Creature.getMaxHealth(PlayerCharacter)
	local curwidth = Creature.getCurrentHealth(PlayerCharacter)
	love.graphics.setLineWidth(3)
	--- Draw Background
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle('fill', sx + 80, sy, 170, 32)
	--- Draw Health Progres Bar
	love.graphics.setColor(0.52, 0.19, 0.19, 1)
	love.graphics.rectangle('fill', sx + 80, sy, 170 * (curwidth / width), 32)
	--- Draw Foreground Border
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('line', sx + 80, sy, 170, 32)
	--- Print Health Amount on Bar
	love.graphics.setFont(gameFonts.slkscr24)
	love.graphics.print(curwidth .. ' / ' .. width, sx + 15 + 80, sy + 4)
	--- Print Label Before Health Bar
	love.graphics.setFont(gameFonts.pixelu32)
	love.graphics.print('VIT', sx, sy - 6)
	love.graphics.setLineWidth(1)
end

---
--- Camera
---

--- Locks the camera to window around the player character, 
--- adjusted by proximity to screen edge.  Camera cant look
--- past the edge of maps.
function StateGame.cameraLookAtPlayerCharacter(dt)
	--- TODO
	--- Lock camera to map edge
	if not PlayerCharacter then return end
	local x, y = Creature.getDrawPosition(PlayerCharacter)
	local cx, cy = StateGame.cameraMapLockCoords()
	local xval = 1
	local yval = 1
	if love.math.random(1, 2) == 2 then 
		xval = -1
	end
	if love.math.random(1, 2) == 2 then 
		yval = -1
	end
	screenShakeVal = math.max(0, screenShakeVal - 1000 * dt)
	x = math.min(math.max(x, cx - 3), 86 - cx)
	y = math.min(math.max(y, cy + 1.5), 40.5 - cy)
	gameCamera:move(math.floor(screenShakeVal * xval / 100), math.floor(screenShakeVal * yval / 100))
	gameCamera:rotateTo(0 + screenShakeVal * xval / 10000)
	gameCamera:lockPosition((x + 4.5) * 16 + 8, y * 16 + 8, LibCamera.smooth.damped(10))
end

function StateGame.cameraMapLockCoords()
	local cx, cy = (love.graphics.getWidth() / 2) / 32, (love.graphics.getHeight() / 2) / 32
	return cx, cy
end

function StateGame.snapCameraToPlayerCharacter()
	if not PlayerCharacter then return end 
	local x, y = Creature.getDrawPosition(PlayerCharacter)
	gameCamera:lookAt((x + 4.5) * 16 + 8, y * 16 + 8)
end

function StateGame.screenShake(amnt)
	screenShakeVal = math.min(300, screenShakeVal + amnt^2)
end

--- 
--- Control
---

function StateGame.deleteSavedGame(path)
	local p = path or 'cdata'
	local list = love.filesystem.getDirectoryItems(p) or { }
	for i = 1, # list do 
		if not love.filesystem.remove(p..'/'..list[i]) then 
			StateGame.deleteSavedGame(p..'/'..list[i])
		end 
	end
end

function StateGame.emitParticlesAt(part, x, y, amount)
	if gameParticles[part] then 
		gameParticles[part]:start()
		gameParticles[part]:setPosition(x * 16 + 8, y * 16 + 8)
		gameParticles[part]:emit(amount)
		gameParticles[part]:stop()
	end
end

function StateGame.tableContentCompare(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or StateGame.tableContentCompare(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end


---
--- Getters
---

function StateGame.getPlayerCharacter() return PlayerCharacter end
function StateGame.getEffect() return Effect end
function StateGame.getFonts() return gameFonts end
function StateGame.getMap() return Map end
function StateGame.getItem() return Item end
function StateGame.getCreature() return Creature end
function StateGame.getBitSer() return LibBitSer end
function StateGame.getMessage() return Message end

---
---
---
return StateGame