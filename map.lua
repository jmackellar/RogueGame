--- Module File
local Map = { }
local FOV = require("lib/fov")
local Bresenham = require("lib/bresenham")
--- Map Variables
local gameWorld = false
local gameWorldZ = 1
local gameWorldWidth = 0
local gameWorldHeight = 0
local gameWorldVisible = { }
local gameWorldsLoaded = { }
local gameWorldPosition = {0, 0, 0}
local gameWorldCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
local gameRedrawWorld = true
local time = {year = 00, day = 31, month = 12, hour = 12, minute = 0, second = 0, halfday = false}
local tileTypes = false 
local tileQuads = { }
local tileImages = { }
local worldTileTypes = false
local ReferenceStateGame = false

--- Load All Map Assets
function Map.loadAssets()
	print("Loading Map Assets")
	local imagestoload = love.filesystem.getDirectoryItems("img/tile")
	for k,v in pairs(imagestoload) do 
		tileImages[string.sub(v, 1, string.len(v) - 4)] = love.graphics.newImage("img/tile/"..v)
	end
	local chunk = love.filesystem.load("dat/tiles.lua")
	tileTypes = chunk()
	chunk = love.filesystem.load("dat/worldTiles.lua")
	worldTileTypes = chunk()
	local x = 0
	local y = 0
	for i = 1, 16 do 
		tileQuads[i] = love.graphics.newQuad(x * 16, y * 16, 16, 16, 64, 64)
		x = x + 1
		if x > 3 then 
			x = 0
			y = y + 1
		end
	end
end

--- Pass high level object
function Map.passHighLevelObjects(stateGame)
	ReferenceStateGame = stateGame 
end

--- Reveal map
function Map.revealMap(visible)
	for x = 1, 80 do 
		for y = 1, 40 do
		 	if gameWorld[x] and gameWorld[x][y] then  
				gameWorld[x][y].seen = true 
				if visible then 
					gameWorld[x][y].visible = visible
					table.insert(gameWorldVisible, {x, y})
				end
			end
		end
	end
	gameRedrawWorld = true
end

--- Creates a blank map of specified width and height values
function Map.createNewMap(width, height, zLayer)
	print("Creating New Map, " .. width .. ", " .. height)
	gameWorld = { }
	gameWorldsLoaded = { }
	gameWorldsVisited = { }
	gameWorldsNoise = { }
	gameWorldWidth = 80
	gameWorldHeight = 40
	gameOverWorldWidth = width
	gameOverWorldHeight = height
	gameWorldCanvas = love.graphics.newCanvas(gameWorldWidth * 16 + 16, gameWorldHeight * 16 + 16)
	for wx = 1, width do 
		gameWorldsLoaded[wx] = { }
		gameWorldsVisited[wx] = { }
		gameWorldsNoise[wx] = { }
		for wy = 1, height do 
			local dir = love.math.random(-1, 1)
			local roll = (love.math.random() / 5) * dir
			gameWorldsLoaded[wx][wy] = false
			gameWorldsVisited[wx][wy] = false
			gameWorldsNoise[wx][wy] = love.math.noise(math.floor(wx / 4) + roll, math.floor(wy / 4) + roll, zLayer)
		end
	end
end

--- Fills a map with a base of sand 
function Map.fillWithSand(t)
	for x = 2, gameWorldWidth do 
		t[x] = { }
		for y = 2, gameWorldHeight do 
			if love.math.random(1, 100) <= 75 then 
				t[x][y] = Map.createNewTile(tileTypes['sand1'])
			else
				t[x][y] = Map.createNewTile(tileTypes['sand'.. love.math.random(1,4)])
			end
			
		end 
	end
	return t
end

--- Fills a map with a base of rock 
function Map.fillWithRockFloor(t)
	for x = 2, gameWorldWidth do 
		t[x] = { }
		for y = 2, gameWorldHeight do 
			if love.math.random(1, 100) <= 50 then 
				t[x][y] = Map.createNewTile(tileTypes['rockfloor1'])
			else
				t[x][y] = Map.createNewTile(tileTypes['rockfloor'.. love.math.random(2,4)])
			end
			
		end 
	end
	return t
end

--- Fills a map with a base of grass
function Map.fillWithGrass(t)
	local roll = 0
	for x = 2, gameWorldWidth do 
		t[x] = { }
		for y = 2, gameWorldHeight do 
			roll = love.math.random(1, 3)
			if love.math.random(1, 100) <= 1 then 
				roll = 4 
			end
			t[x][y] = Map.createNewTile(tileTypes['grass'.. roll])
		end 
	end
	return t
end

function Map.overworldMapTileType(currentWorldX, currentWorldY)
	local roll = 0
	local wtt = false
	local wtiles = {
		'pond', 
		'pond', 
		'barrenplains', 
		'plains', 
		'slums', 
		'warehouse', 
		'residential', 
		'caverns', 
		'caverns', 
		'mountain', 
		'mountain', 
		'complex'
	}
	roll = gameWorldsNoise[currentWorldX][currentWorldY]
	for i = 1, # wtiles do 
		if roll >= (i - 1) / # wtiles and roll <= i / # wtiles then 
			wtt = wtiles[i]
		end 
	end
	return wtt 
end

--- Generates a tile of the overall game world.  Size of one screen 
function Map.generateGameWorldMapTile(worldWidth, worldHeight, currentWorldX, currentWorldY)
	local t = { }
	local wtt = Map.overworldMapTileType(currentWorldX, currentWorldY)
	--local wtiles = {'complex'} --- This is the the testing code :D
	--- Fill in base tile
	--t = Map.fillWithGrass(t)
	t = Map.fillWithSand(t)
	--- Detect overall world edges
	if currentWorldY <= 1 then 
		for x = 2, gameWorldWidth do 
			t[x][2] = Map.createNewTile(tileTypes['rockwall1'])
		end
	elseif currentWorldY >= worldHeight then 
		for x = 2, gameWorldWidth do 
			t[x][gameWorldHeight] = Map.createNewTile(tileTypes['rockwall1'])
		end
	end 
	if currentWorldX <= 1 then 
		for y = 2, gameWorldHeight do 
			t[2][y] = Map.createNewTile(tileTypes['rockwall1'])
		end
	elseif currentWorldX >= worldWidth then 
		for y = 2, gameWorldHeight do 
			t[gameWorldWidth][y] = Map.createNewTile(tileTypes['rockwall1'])
		end
	end
	t = worldTileTypes.surface[wtt].generator(t, currentWorldX, currentWorldY, Map)
	t = Map.populateNPCs(t, 
						currentWorldX, 
						currentWorldY, 
						worldTileTypes.surface[wtt].popTable,
						worldTileTypes.surface[wtt].outOfDepthPopTable,
						love.math.random(worldTileTypes.surface[wtt].popAmount.min, worldTileTypes.surface[wtt].popAmount.max)
						)
	t = Map.populateItems(t,
						currentWorldX,
						currentWorldY,
						worldTileTypes.surface[wtt].itemTable,
						love.math.random(worldTileTypes.surface[wtt].itemAmount.min, worldTileTypes.surface[wtt].itemAmount.max)
						)
	return t
end

function Map.generateComplex(t, cX, cY, subdivisions, roomMargins, averageRoomSize)
	local node = false
	local tree = { 
		{area = {x = love.math.random(5, 15), y = love.math.random(5, 10), w = love.math.random(55, 60), h = love.math.random(25, 30)}},
	}
	--- Divide binary tree into subdivisions
	tree[1] = Map.divideNode(tree[1], 1, subdivisions, roomMargins, averageRoomSize)
	t = Map.buildBinaryTreeMap(t, tree, tree[1], 'woodfloor2', 'brickwall2')
	t = Map.placeBSPEntrances(t, love.math.random(4, 8))
	t = Map.placeDoorways(t)
	t = Map.generateLiquidPools(t, 'waste', 'sand', love.math.random(9, 15), 25, 45)
	t = Map.generateFoliage(t, 'woodfloor2', love.math.random(15, 25), 10)
	return t
end

function Map.generateWarehouse(t, cX, cY, subdivisions, roomMargins, averageRoomSize)
	local node = false
	local tree = { 
		{area = {x = love.math.random(5, 15), y = love.math.random(5, 10), w = love.math.random(55, 60), h = love.math.random(25, 30)}},
	}
	--- Divide binary tree into subdivisions
	tree[1] = Map.divideNode(tree[1], 1, subdivisions, roomMargins, averageRoomSize)
	t = Map.buildBinaryTreeMap(t, tree, tree[1], 'woodfloor1', 'brickwall1')
	t = Map.placeBSPEntrances(t, love.math.random(2, 4))
	t = Map.placeDoorways(t)
	t = Map.generateLiquidPools(t, 'waste', 'sand', love.math.random(9, 15), 25, 45)
	t = Map.generateFoliage(t, 'woodfloor1', love.math.random(15, 25), 10)
	return t
end

--- Places bushes around a map.  Exclude is a string that matches the name of 
--- a tile type.  The matching tile will be excluded from having any foliage
--- placed ontop of it.
function Map.generateFoliage(t, exclude, amount, density)
	for i = 1, amount do 
		local rX = love.math.random(5, 75)
		local rY = love.math.random(5, 35)
		local rW = 0
		local rH = 0
		local attempts = 0
		repeat 		
			rX = rX + love.math.random(-1, 1)
			rY = rY + love.math.random(-1, 1)
			if rX < 5 then 
				rX = 5 
			elseif rX > 75 then 
				rX = 75
			end 
			if rY < 5 then 
				rY = 5 
			elseif rY > 35 then 
				rY = 35 
			end
			if t[rX][rY].name ~= 'bush' and t[rX][rY].name ~= exclude and not t[rX][rY].blockMovement and not t[rX][rY].liquid then 
				t[rX][rY] = Map.createNewTile(tileTypes.bush1)
				attempts = attempts + 1
			end
		until attempts > love.math.random(density * 0.75, density * 1.25)
	end
	return t
end

--- Places liquid pools around a map.  Check is a string that 
--- matches the first 4 letters of the name of tile.  Only the tile
--- with the matching check is eligble to have liquid placed on it
function Map.generateLiquidPools(t, liquid, check, pools, min, max)
	local attempts = 0
	for i = 1, pools do 
		local rX = love.math.random(5, 75)
		local rY = love.math.random(5, 35)
		local rW = 0
		local rH = 0
		repeat 		
			rW = rW + love.math.random(-1, 1)
			rH = rH + love.math.random(-1, 1)
			if t[rX + rW] and t[rX + rW][rY + rH] and string.sub(t[rX + rW][rY + rH].name, 1, 4) == check and 
				not t[rX + rW][rY + rH].liquid and not t[rX + rW][rY + rH].blockMovement then 
				Map.addLiquid(t, liquid, 4, rX + rW, rY + rH)
				attempts = attempts + 1
			end
		until attempts > love.math.random(min, max)
	end
	return t
end

--- Place doorways on a bsp map 
function Map.placeDoorways(t)
	for x = 3, 77 do 
		for y = 3, 37 do 
			if not t[x][y].blockMovement then 
				if (t[x-1][y].blockMovement and t[x+1][y].blockMovement) or
					(t[x][y-1].blockMovement and t[x][y+1].blockMovement) then 
					if (not t[x-1][y-1].blockMovement or not t[x+1][y-1].blockMovement or
						not t[x-1][y+1].blockMovement or not t[x+1][y+1].blockMovement) and
						t[x-1][y].name ~= 'doorclosed' and
						t[x+1][y].name ~= 'doorclosed' and 
						t[x][y-1].name ~= 'doorclosed' and 
						t[x][y+1].name ~= 'doorclosed' then
						t[x][y] = Map.createNewTile(tileTypes.doorclosed)
					end
				end
			end
		end
	end
	return t
end

--- Place entranceways to buildings from a binary tree map
function Map.placeBSPEntrances(t, entrances)
	local posEntrance = { }
	local roll = false
	for x = 3, 77 do 
		for y = 3, 37 do 
			if t[x][y].blockMovement and
				(
					(t[x-1][y].blockMovement and t[x+1][y].blockMovement and (string.sub(t[x][y-1].name, 1, 4) == 'sand' or string.sub(t[x][y+1].name, 1, 4) == 'sand')) or
					(t[x][y-1].blockMovement and t[x][y+1].blockMovement and (string.sub(t[x-1][y].name, 1, 4) == 'sand' or string.sub(t[x+1][y].name, 1, 4) == 'sand'))
				) 
				then 
				table.insert(posEntrance, {x, y})
			end
		end 
	end
	for i = 1, entrances do 
		roll = love.math.random(1, # posEntrance)
		t[posEntrance[roll][1]][posEntrance[roll][2]] = Map.createNewTile(tileTypes.woodfloor1)
		table.remove(posEntrance, roll)
	end
	return t
end

--- Takes a completed binary tree dataset and builds the map 
--- from it 
function Map.buildBinaryTreeMap(t, tree, node, floor, wall)
	local posEntrance = { }
	local check = {
		{-1,-1},
		{-1,0},
		{-1,1},
		{0,-1},
		{0,1},
		{1,-1},
		{1,0},
		{1,1},
	}
	if node.room then 
		for x = node.room.x, node.room.x + node.room.w do 
			for y = node.room.y, node.room.y + node.room.h do 
				t[x][y] = Map.createNewTile(tileTypes[floor])
			end
		end
	end
	if node.connectors then 
		for i = 1, # node.connectors do 
			local dx, dy = 1, 1
			if node.connectors[i].ex < node.connectors[i].sx then 
				dx = -1 
			end 
			if node.connectors[i].ey < node.connectors[i].sy then 
				dy = -1 
			end
			for x = node.connectors[i].sx, node.connectors[i].ex, dx do 
				t[x][node.connectors[i].sy] = Map.createNewTile(tileTypes[floor])
			end
			for y = node.connectors[i].sy, node.connectors[i].ey, dy do 
				t[node.connectors[i].ex][y] = Map.createNewTile(tileTypes[floor])
			end
		end
	end
	if node.children then 
		t = Map.buildBinaryTreeMap(t, tree, node.children[1], floor, wall)
		t = Map.buildBinaryTreeMap(t, tree, node.children[2], floor, wall)
	else 
		--- Place walls down 
		for x = 2, 78 do 
			for y = 2, 38 do 
				if t[x] and t[x][y] and t[x][y].name == floor then 
					for k = 1, # check do 
						if t[x+check[k][1]] and t[x+check[k][1]][y+check[k][2]] and 
							t[x+check[k][1]][y+check[k][2]].name ~= floor then 
							t[x+check[k][1]][y+check[k][2]] = Map.createNewTile(tileTypes[wall])
						end
					end
				end
			end
		end
	end
	return t
end

--- Divides a binary tree into nodes, rooms, and connectors
function Map.divideNode(node, division, maxdivision, roomMargins, averageRoomSize)
	local roll = love.math.random(1, 2)
	local xmargin, ymargin = 4, 4
	if division <= maxdivision then 
		node.children = { }
		if node.area.w > node.area.h then 
			roll = 1 
		elseif node.area.w < node.area.h then 
			roll = 2 
		end
		--- Divide node Vertically
		if roll == 1 then 
			xmargin = math.max(3, math.ceil(node.area.w * roomMargins[1]))
			node.divider = {type = 'vertical', sx = love.math.random(node.area.x + xmargin, node.area.x + node.area.w - xmargin), sy = node.area.y}
			node.children[1] = {
				area = { 
					x = node.area.x, 
					y = node.area.y, 
					w = node.divider.sx - node.area.x,
					h = node.area.h,
				},
			}
			node.children[2] = {
				area = {
					x = node.divider.sx, 
					y = node.area.y, 
					w = node.area.w - (node.divider.sx - node.area.x), 
					h = node.area.h,
				},
			}
			node.children[1].sibling = node.children[2] 
			node.children[2].sibling = node.children[1]
			node.children[1].parent = node
			node.children[2].parent = node
			node.children[1] = Map.divideNode(node.children[1], division + 1, maxdivision, roomMargins, averageRoomSize)
			node.children[2] = Map.divideNode(node.children[2], division + 1, maxdivision, roomMargins, averageRoomSize)
		--- Divide node horizontally
		else 
			ymargin = math.max(3, math.ceil(node.area.h * roomMargins[2]))
			node.divider = {type = 'horizontal', sx = node.area.x, sy = love.math.random(node.area.y + ymargin, node.area.y + node.area.h - ymargin)}
			node.children[1] = {
				area = {
					x = node.area.x,
					y = node.area.y,
					w = node.area.w,
					h = node.divider.sy - node.area.y,
				},
			}
			node.children[2] = {
				area = {
					x = node.area.x,
					y = node.divider.sy,
					w = node.area.w,
					h = node.area.h - (node.divider.sy - node.area.y),
				},
			}
			node.children[1].sibling = node.children[2] 
			node.children[2].sibling = node.children[1]
			node.children[1].parent = node
			node.children[2].parent = node
			node.children[1] = Map.divideNode(node.children[1], division + 1, maxdivision, roomMargins, averageRoomSize)
			node.children[2] = Map.divideNode(node.children[2], division + 1, maxdivision, roomMargins, averageRoomSize)
		end
	--- Reached max divisions, place rooms in subdivided area 
	else
		local minw, minh = 3, 3
		minw = math.max(3, math.ceil(node.area.w * averageRoomSize))
		minh = math.max(3, math.ceil(node.area.h * averageRoomSize))
		node.room = { }
		node.room.w = love.math.random(minw, node.area.w - minw)
		node.room.h = love.math.random(minh, node.area.h - minh)
		node.room.x = love.math.random(node.area.x, node.area.x + node.area.w - node.room.w)
		node.room.y = love.math.random(node.area.y, node.area.y + node.area.h - node.room.h)
	end
	--- Place connectors 
	if node.children and node.children[1].room and node.children[2].room then 
		node.connectors = { }
		table.insert(node.connectors, {
			sx = node.children[1].room.x + math.ceil(node.children[1].room.w / 2),
			sy = node.children[1].room.y + math.ceil(node.children[1].room.h / 2),
			ex = node.children[2].room.x + math.ceil(node.children[2].room.w / 2),
			ey = node.children[2].room.y + math.ceil(node.children[2].room.h / 2),
			})
	elseif node.children and node.children[1].connectors and node.children[2].connectors then 
		node.connectors = { }
		table.insert(node.connectors, {
			sx = node.children[1].connectors[1].sx,
			sy = node.children[1].connectors[1].sy,
			ex = node.children[2].connectors[1].sx, 
			ey = node.children[2].connectors[1].sy,
			})
	end
	return node
end

--- Takes a passed blank map and generates a poor residential area
function Map.generatePoorResidential(t, cX, cY, population, prosperity)
	local roomsPlaced = { }
	local attempts = 0
	local canPlaceRoom = false 
	local rX, rY, rW, rH = 0, 0, 0, 0 
	local minW, maxW, minH, maxH = 4, 8, 4, 8
	local door = { }
	--- Generate buildings
	repeat 
		rW = love.math.random(minW, maxW)
		rH = love.math.random(minH, maxH)
		if love.math.random(1, 100) <= 15 then 
			rW = love.math.random(maxW, maxW * 2)
		end
		if love.math.random(1, 100) <= 15 then 
			rH = love.math.random(maxH, maxH * 2)
		end
		rX = love.math.random(5, 75 - rW)
		rY = love.math.random(5, 35 - rH)
		--- Check if the building area is clear 
		canPlaceRoom = true 
		for i = 1, # roomsPlaced do 
			if rX - 1 <= roomsPlaced[i].x + roomsPlaced[i].w and 
				rX + rW + 1 >= roomsPlaced[i].x and 
				rY - 1 <= roomsPlaced[i].y + roomsPlaced[i].h and 
				rY + rH + 1 >= roomsPlaced[i].h then 
				canPlaceRoom = false 
			end
		end
		if canPlaceRoom then 
			table.insert(roomsPlaced, {x = rX, y = rY, w = rW, h = rH})
		end
		attempts = attempts + 1
	until # roomsPlaced >= population or attempts > 999
	--- Place buildings on map
	for i = 1, # roomsPlaced do  
		for x = roomsPlaced[i].x, roomsPlaced[i].x + roomsPlaced[i].w do 
			for y = roomsPlaced[i].y, roomsPlaced[i].y + roomsPlaced[i].h do 
				if love.math.random(1, 100) <= prosperity + 15 then 
					t[x][y] = Map.createNewTile(tileTypes['woodfloor1'])
				end
			end
		end
		for x = roomsPlaced[i].x, roomsPlaced[i].x + roomsPlaced[i].w do 
			if love.math.random(1, 100) <= prosperity then 
				t[x][roomsPlaced[i].y] = Map.createNewTile(tileTypes['brickwall1'])
			end
			if love.math.random(1, 100) <= prosperity then 
				t[x][roomsPlaced[i].y + roomsPlaced[i].h] = Map.createNewTile(tileTypes['brickwall1'])
			end
		end 
		for y = roomsPlaced[i].y, roomsPlaced[i].y + roomsPlaced[i].h do 
			if love.math.random(1, 100) <= prosperity then 
				t[roomsPlaced[i].x][y] = Map.createNewTile(tileTypes['brickwall1'])
			end
			if love.math.random(1, 100) <= prosperity then 
				t[roomsPlaced[i].x + roomsPlaced[i].w][y] = Map.createNewTile(tileTypes['brickwall1'])
			end
		end
		door = {
			{love.math.random(roomsPlaced[i].x + 2, roomsPlaced[i].x + roomsPlaced[i].w - 2), roomsPlaced[i].y},
			{love.math.random(roomsPlaced[i].x + 2, roomsPlaced[i].x + roomsPlaced[i].w - 2), roomsPlaced[i].y + roomsPlaced[i].h},
			{roomsPlaced[i].x, love.math.random(roomsPlaced[i].y + 2, roomsPlaced[i].y + roomsPlaced[i].h - 2)},
			{roomsPlaced[i].x + roomsPlaced[i].w, love.math.random(roomsPlaced[i].y + 2, roomsPlaced[i].y + roomsPlaced[i].h - 2)},
			love.math.random(1, 4)
		}
		if love.math.random(1, 100) <= prosperity then 
			t[door[door[5]][1]][door[door[5]][2]] = Map.createNewTile(tileTypes['woodfloor1'])
		end
	end
	--- Place waste pools
	attempts = 0
	for i = 1, love.math.random(3, 7) do 
		rX = love.math.random(5, 75)
		rY = love.math.random(5, 35)
		rW = 0
		rH = 0
		repeat 		
			rW = rW + love.math.random(-1, 1)
			rH = rH + love.math.random(-1, 1)
			if t[rX + rW] and t[rX + rW][rY + rH] and string.sub(t[rX + rW][rY + rH].name, 1, 4) == 'sand' and 
				not t[rX + rW][rY + rH].liquid and not t[rX + rW][rY + rH].blockMovement then 
				Map.addLiquid(t, 'waste', 4, rX + rW, rY + rH)
				rW = 0 
				rH = 0
				attempts = attempts + 1
			end
		until attempts > love.math.random(25, 45)
	end
	if prosperity < 100 then
		--- Place foliage
		for i = 1, love.math.random(15, 25) do 
			rX = love.math.random(5, 75)
			rY = love.math.random(5, 35)
			rW = 0
			rH = 0
			attempts = 0
			repeat 		
				rX = rX + love.math.random(-1, 1)
				rY = rY + love.math.random(-1, 1)
				if rX < 5 then 
					rX = 5 
				elseif rX > 75 then 
					rX = 75
				end 
				if rY < 5 then 
					rY = 5 
				elseif rY > 35 then 
					rY = 35 
				end
				if t[rX][rY].name ~= 'bush' and t[rX][rY].name ~= 'woodfloor1' and not t[rX][rY].blockMovement then 
					t[rX][rY] = Map.createNewTile(tileTypes.bush1)
					attempts = attempts + 1
				end
			until attempts > love.math.random(3, 10)
		end
	else 
		t = Map.placeDoorways(t)
		t = Map.generateFoliage(t, 'woodfloor1', love.math.random(10, 15), 7)
	end
	return t
end

function Map.generatePond(t, cX, cY, minFoliage, maxFoliage, foliageDensity)
	--- Place foliage
	for i = 1, love.math.random(minFoliage, maxFoliage) do 
		rX = love.math.random(5, 75)
		rY = love.math.random(5, 35)
		rW = 0
		rH = 0
		attempts = 0
		repeat 		
			rX = rX + love.math.random(-1, 1)
			rY = rY + love.math.random(-1, 1)
			if rX < 5 then 
				rX = 5 
			elseif rX > 75 then 
				rX = 75
			end 
			if rY < 5 then 
				rY = 5 
			elseif rY > 35 then 
				rY = 35 
			end
			if t[rX][rY].name ~= 'bush' and not t[rX][rY].blockMovement then 
				t[rX][rY] = Map.createNewTile(tileTypes.bush1)
				attempts = attempts + 1
			end
		until attempts > love.math.random(foliageDensity, foliageDensity * 1.5)
	end
	--- Place waste pools
	attempts = 0
	for i = 1, love.math.random(15, 25) do 
		rX = love.math.random(5, 75)
		rY = love.math.random(5, 35)
		rW = 0
		rH = 0
		attempts = 0
		repeat 		
			rW = rW + love.math.random(-1, 1)
			rH = rH + love.math.random(-1, 1)
			if t[rX + rW] and t[rY + rH] and
				string.sub(t[rX + rW][rY + rH].name, 1, 4) == 'sand' and
			 	not t[rX + rW][rY + rH].liquid and
			 	not t[rX + rW][rY + rH].blockMovement then 
				Map.addLiquid(t, 'waste', 4, rX + rW, rY + rH)
				rW = 0 
				rH = 0
				attempts = attempts + 1
			end
		until attempts > love.math.random(35, 45)
	end
	return t
end

function Map.generatePlains(t, cX, cY, minFoliage, maxFoliage, foliageDensity)
	--- Place foliage
	for i = 1, love.math.random(minFoliage, maxFoliage) do 
		rX = love.math.random(5, 75)
		rY = love.math.random(5, 35)
		rW = 0
		rH = 0
		attempts = 0
		repeat 		
			rX = rX + love.math.random(-1, 1)
			rY = rY + love.math.random(-1, 1)
			if rX < 5 then 
				rX = 5 
			elseif rX > 75 then 
				rX = 75
			end 
			if rY < 5 then 
				rY = 5 
			elseif rY > 35 then 
				rY = 35 
			end
			if t[rX][rY].name ~= 'bush' and not t[rX][rY].blockMovement then 
				t[rX][rY] = Map.createNewTile(tileTypes.bush1)
				attempts = attempts + 1
			end
		until attempts > love.math.random(foliageDensity, foliageDensity * 1.5)
	end
	--- Place waste pools
	attempts = 0
	for i = 1, love.math.random(3, 7) do 
		rX = love.math.random(5, 75)
		rY = love.math.random(5, 35)
		rW = 0
		rH = 0
		attempts = 0
		repeat 		
			rW = rW + love.math.random(-1, 1)
			rH = rH + love.math.random(-1, 1)
			if t[rX + rW] and t[rY + rH] and
				string.sub(t[rX + rW][rY + rH].name, 1, 4) == 'sand' and
			 	not t[rX + rW][rY + rH].liquid and
			 	not t[rX + rW][rY + rH].blockMovement then 
				Map.addLiquid(t, 'waste', 4, rX + rW, rY + rH)
				rW = 0 
				rH = 0
				attempts = attempts + 1
			end
		until attempts > love.math.random(15, 35)
	end
	return t
end

--- Takes a passed blank map and generates a randomized cave
--- system map
function Map.generateCaves(t, cX, cY, seed, generations, threshold)
	local wallAround = 0
	local check = {{-1,-1},{0,-1},{1,-1},{-1,0},{1,0},{-1,1},{0,1},{1,1},{0,0}}
	local roll = 0
	for x = 3, gameWorldWidth - 1 do 
		for y = 3, gameWorldHeight - 1 do 
			if love.math.random(1, 100) <= seed then 
				t[x][y] = Map.createNewTile(tileTypes['rockwall1'])
			end
		end 
	end
	repeat 
		for x = 3, gameWorldWidth - 1 do 
			for y = 3, gameWorldHeight - 1 do 
				wallAround = 0 
				for i = 1, # check do 
					if t[x + check[i][1]] and t[x + check[i][1]][y + check[i][2]] and t[x + check[i][1]][y + check[i][2]].blockMovement then 
						wallAround = wallAround + 1
					end
				end
				if wallAround >= threshold then 
					t[x][y] = Map.createNewTile(tileTypes['rockwall1'])
				else 
					if love.math.random(1, 100) <= 75 then 
						t[x][y] = Map.createNewTile(tileTypes['sand1'])
					else
						t[x][y] = Map.createNewTile(tileTypes['sand'..love.math.random(1,4)])
					end
				end
			end
		end
		generations = generations - 1
	until generations <= 0
	--- Place water
	local wx = love.math.random(20, 60)
	local wy = love.math.random(10, 30)
	local ww = love.math.random(10, 40)
	local wh = love.math.random(3, 20)
	local d = ((ww / 2) + (wh / 2)) / 2
	for x = wx - ww, wx + ww do
		for y = wy - wh, wy + wh do
			if t[x] and t[x][y] and not t[x][y].blockMovement then 
				if math.sqrt(math.pow(x - wx, 2) + math.pow(y - wy, 2)) <= d then 
					t = Map.addLiquid(t, "waste", 4, x, y)
				end
			end
		end
	end
	return t
end

--- Populates a map with items
function Map.populateItems(t, cX, cY, itemTable, itemAmount)
	local roll = 0
	local maxroll = 0
	local x = 0
	local y = 0
	local placed = 0
	local choice = false 
	local stack = 0
	for i = 1, # itemTable do 
		maxroll = maxroll + itemTable[i].chance 
	end
	repeat 
		choice = false
		x = love.math.random(1, 80)
		y = love.math.random(1, 40)
		if t[x] and t[x][y] and not t[x][y].blockMovement then 
			roll = love.math.random(1, maxroll)
			maxroll = 0
			for i = 1, # itemTable do 
				if roll >= maxroll and roll <= maxroll + itemTable[i].chance then 
					choice = ReferenceStateGame.getItem().createNewItem(itemTable[i].type)
					stack = love.math.random(itemTable[i].min, itemTable[i].max)
				end
				maxroll = maxroll + itemTable[i].chance
			end
			if choice then 
				ReferenceStateGame.getItem().addItemToWorld(choice, x, y, stack)
				placed = placed + 1
			end
		end
	until placed >= itemAmount
	ReferenceStateGame.getItem().saveWorldItems()
	ReferenceStateGame.getItem().clearWorldItems()
	return t
end

--- Populates a map with npcs
function Map.populateNPCs(t, cX, cY, popTable, outOfDepthPopTable, popAmount)
	local roll = 0
	local maxroll = 0
	local x = 0
	local y = 0
	local placed = 0
	local choice = false	
	local table = popTable
	local tries = 0
	repeat 
		maxroll = 0
		tries = tries + 1
		if love.math.random(1, 100) <= 3 then 
			table = outOfDepthPopTable
		else 
			table = popTable 
		end
		for i = 1, # table do 
			maxroll = maxroll + table[i].chance 
		end 
		roll = love.math.random(1, maxroll)
		maxroll = 0
		for i = 1, # table do 
			if roll >= maxroll and roll <= maxroll + table[i].chance then 
				choice = table[i].type 
			end
			maxroll = maxroll + table[i].chance
		end
		if choice then 
			x = love.math.random(3, gameWorldWidth - 1)
			y = love.math.random(3, gameWorldHeight - 1)
			if t[x] and t[x][y] and not t[x][y].blockMovement and not ReferenceStateGame.getCreature().isCreatureAt(x, y) then 
				placed = placed + 1
				ReferenceStateGame.getCreature().addNewCreature(choice, x, y, gameWorldZ, cX, cY)
			end		
		end
	until placed > popAmount or tries > 999
	ReferenceStateGame.getCreature().saveCreatures()
	ReferenceStateGame.getCreature().clearAllCreatures()
	return t
end

--- Attempts to load a different tile of the overall game world 
function Map.switchGameWorldLoaded(wx, wy, wz)
	ReferenceStateGame.getCreature().saveCreatures()
	ReferenceStateGame.getCreature().clearAllCreatures()
	ReferenceStateGame.getItem().saveWorldItems()
	ReferenceStateGame.getItem().clearWorldItems()
	if not gameWorldsLoaded[wx][wy] then 
		gameWorldPosition = {wx, wy, wz}
		gameWorldsLoaded[wx][wy] = Map.generateGameWorldMapTile(gameOverWorldWidth, gameOverWorldHeight, wx, wy)
	end	
	gameWorld = gameWorldsLoaded[wx][wy]
	gameWorldPosition = {wx, wy, wz}
	ReferenceStateGame.getCreature().loadAllCreatures(wx, wy, wz)
	ReferenceStateGame.getItem().loadWorldItems(wx, wy, wz)
	local searchRadius = 7
	for x = wx - searchRadius, wx + searchRadius do 
		for y = wy - searchRadius, wy + searchRadius do 
			local wtt = Map.overworldMapTileType(x, y)
			gameWorldsVisited[x][y] = worldTileTypes.surface[wtt]
		end
	end
	Map.resetVisibility()
	Map.redrawGameWorld()
	return true
end

--- Reset map visibility complete
function Map.resetVisibility()
	for x = 2, gameWorldWidth do 
		for y = 2, gameWorldHeight do 
			gameWorld[x][y].visible = false 
		end 
	end
end

--- Marks all areas of the map between start points x,y and ex,ey 
--- as not being visible 
function Map.markAsNotVisible(x, y, ex, ey)
	for xx = x, ex do 
		for yy = y, ey do 
			if gameWorld[xx] and gameWorld[xx][yy] then 
				gameWorld[xx][yy].visible = false
			end
		end
	end
end

--- Creates a new tile object from a base tile asset
function Map.createNewTile(tileType)
	local t = { }
	for k,v in pairs(tileType) do 
		t[k] = v 
	end 
	t['seen'] = false 
	t['visible'] = false
	t['liquid'] = false
	return t
end

--- Adds a liquid of type and amount to passed tile
function Map.addLiquid(world, liquid, amount, x, y)
	if world[x] and world[x][y] then 
		world[x][y].liquid = {type = liquid, amount = amount}
	end
	return world
end

--- Drops liquid into the currently loaded game world and takes
--- into account liquids already on the tile beforehand
--- TODO Some type of liquid mixing thingey
function Map.dropLiquid(liquid, amount, x, y)
	if gameWorld[x] and gameWorld[x][y] and not gameWorld[x][y].blockMovement then 
		if not gameWorld[x][y].liquid then 
			gameWorld[x][y].liquid = {type = liquid, amount = amount}
		elseif gameWorld[x][y].liquid and gameWorld[x][y].liquid.type == liquid then 
			gameWorld[x][y].liquid.amount = gameWorld[x][y].liquid.amount + amount 
		elseif gameWorld[x][y].liquid and gameWorld[x][y].liquid.type == 'water' then 
			gameWorld[x][y].liquid = {type = liquid, amount = amount}
		end
		for xx = -2, 2 do 
			for yy = -2, 2 do 
				if gameWorld[x + xx] and gameWorld[x + xx][y + yy] and gameWorld[x + xx][y + yy].liquid then 
					gameWorld[x + xx][y + yy].liquid.calculatedBit = false
				end
			end 
		end
	end
end

--- Draws the game world specified between the starting x, y,
--- ex, and ey values.
function Map.drawGameWorld(x, y, ex, ey)
	if gameRedrawWorld then 
		love.graphics.setCanvas(gameWorldCanvas)
		love.graphics.clear()
		for dx = x, ex do 
			for dy = y, ey do 
				Map.drawTileAt(dx, dy)
			end
		end
		love.graphics.setCanvas()
		gameRedrawWorld = false 
	end
	return gameWorldCanvas
end

--- Sets the world to be redrawn
function Map.redrawGameWorld()
	gameRedrawWorld = true
end

--- Draws a liquid on x, y tile 
function Map.drawLiquid(x, y)
	if gameWorld[x][y].liquid then 
		if not gameWorld[x][y].liquid.calculatedBit and gameWorld[x][y].liquid.amount > 3 then 
			local bit = 0
			local loc = {{x, y - 1, 1},{x, y + 1, 8},{x - 1, y, 2},{x + 1, y, 4}}
			--- Check the four directional values and assign either 0 or 1
			--- based on whether that tile matches the current.  then multiplay
			--- that by the directional value, north = 1, south = 8, west = 2, east = 4
			for i = 1, 4 do 
				if gameWorld[loc[i][1]] and gameWorld[loc[i][1]][loc[i][2]] and gameWorld[loc[i][1]][loc[i][2]].liquid and gameWorld[loc[i][1]][loc[i][2]].liquid.type == gameWorld[x][y].liquid.type and gameWorld[loc[i][1]][loc[i][2]].liquid.amount > 3 then 
					bit = bit + loc[i][3]
				end
			end
			gameWorld[x][y].liquid.calculatedBit = bit 
		elseif not gameWorld[x][y].liquid.calculatedBit then 
			gameWorld[x][y].liquid.calculatedBit = 0
		end
		if gameWorld[x][y].liquid.amount > 2 then 
			love.graphics.draw(tileImages['liquid'..gameWorld[x][y].liquid.type], tileQuads[gameWorld[x][y].liquid.calculatedBit + 1], x * 16, y * 16) 
		elseif gameWorld[x][y].liquid.amount > 1 then 
			love.graphics.draw(tileImages['smallliquid'..gameWorld[x][y].liquid.type], tileQuads[gameWorld[x][y].liquid.calculatedBit + 1], x * 16, y * 16) 
		else 
			love.graphics.draw(tileImages['tinyliquid'..gameWorld[x][y].liquid.type], tileQuads[gameWorld[x][y].liquid.calculatedBit + 1], x * 16, y * 16) 
		end
	end
end

--- Draws the specified map tile
function Map.drawTileAt(x, y)
	if gameWorld[x] and gameWorld[x][y] and gameWorld[x][y].seen then 
		local drawfunc = false
		--- Non bitmasking tile
		if not gameWorld[x][y].bitmask then 
			drawfunc =	function () 
							love.graphics.draw(tileImages[gameWorld[x][y].img], x * 16, y * 16) 
							Map.drawLiquid(x, y)
						end
		--- Bitmasking tile
		else	
			if not gameWorld[x][y].calculatedBit then 
				local bit = 0
				local loc = {{x, y - 1, 1},{x, y + 1, 8},{x - 1, y, 2},{x + 1, y, 4}}
				--- Check the four directional values and assign either 0 or 1
				--- based on whether that tile matches the current.  then multiplay
				--- that by the directional value, north = 1, south = 8, west = 2, east = 4
				for i = 1, 4 do 
					if gameWorld[loc[i][1]] and gameWorld[loc[i][1]][loc[i][2]] and gameWorld[loc[i][1]][loc[i][2]].name == gameWorld[x][y].name then 
						bit = bit + loc[i][3]
					end
				end
				gameWorld[x][y].calculatedBit = bit 
			end
			--- Draw the cooresponding segment of the bitmask image based on the 
			--- above calculated bit		
			drawfunc =	function () 
							love.graphics.draw(tileImages[gameWorld[x][y].img], tileQuads[gameWorld[x][y].calculatedBit + 1], x * 16, y * 16) 
							Map.drawLiquid(x, y)
						end
		end
		if gameWorld[x][y].visible then
			drawfunc()
			--- Grid
		else 
			drawfunc()
			love.graphics.setColor(0.1, 0.1, 0.1, 0.78)
			love.graphics.rectangle("fill", x * 16, y * 16, 16, 16)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
end

---
--- Mapgen
---

--- Test map
function Map.genTestMap()
	Map.createNewMap(1000, 1000)
end

--- Calculates the FOV around point x,y with radius without settings the seen tag
function Map.calculateNonPlayerFOV(x, y, radius)
	Map.markAllNonVisible()
	FOV(x, y, radius, Map.isTileTransparentAt, Map.tileOnVisibleNonPlayer)
end


--- Calculates the FOV around point x,y with radius
function Map.calculateFOV(x, y, radius)
	Map.markAllNonVisible()
	FOV(x, y, radius, Map.isTileTransparentAt, Map.tileOnVisible)
end


--- Marks all map tiles as not being visible
function Map.markAllNonVisible()
	for i = 1, # gameWorldVisible do 
		gameWorld[gameWorldVisible[i][1]][gameWorldVisible[i][2]].visible = false 
	end
	gameWorldVisible = { }
end

--- Gets called when a tile is marked as being visible
function Map.tileOnVisible(x, y)
	if x > 1 and y > 1 and x <= gameWorldWidth and y <= gameWorldHeight then 
		gameWorld[x][y].seen = true 
		gameWorld[x][y].visible = true 
		table.insert(gameWorldVisible, {x, y})
	end
end

--- Gets called when a tile is marked as being visible
function Map.tileOnVisibleNonPlayer(x, y)
	if gameWorld[x] and gameWorld[x][y] then 
		gameWorld[x][y].visible = true 
		table.insert(gameWorldVisible, {x, y})
	end
end

--- Returns true if there is a visible line of sight between
--- point x1,y1 and x2,y2
function Map.isLineOfSightClear(x1, y1, x2, y2)
	return Bresenham.los(x1, y1, x2, y2, Map.isTileTransparentAt)
end

--- Returns table of path and boolean if path was found in
--- a bresenham line
function Map.bresenhamLine(x1, y1, x2, y2)
	return Bresenham.line(x1, y1, x2, y2, Map.isTileTransparentAt)
end

--- Opens a closed door or closes an opened door at tile x,y
function Map.interactWithDoor(x, y)
	if gameWorld[x] and gameWorld[x][y] then 
		if gameWorld[x][y].name == 'doorclosed' then 
			gameWorld[x][y] = Map.createNewTile(tileTypes.dooropen)
		elseif gameWorld[x][y].name == 'dooropen' then 
			gameWorld[x][y] = Map.createNewTile(tileTypes.doorclosed)
		end
		gameRedrawWorld = true
	end
end

---
--- Time
---
function Map.incrementTime()
	time.second = time.second + 0.25
	if time.second > 59 then 
		time.second = 0
		time.minute = time.minute + 1
		if time.minute > 59 then 
			time.minute = 0 
			time.hour = time.hour + 1
			if time.hour > 24 then 
				time.hour = 0
				time.day = time.day + 1
				if time.day > 30 then 
					time.day = 1
					time.month = time.month + 1
					if time.month > 12 then 
						time.month = 1
						time.year = time.year + 1
					end 
				end
			end
		end
	end
	ReferenceStateGame.getMessage().sendTime(time)
end

---
--- Getters
---

--- Returns boolean whether map exists or not
function Map.doesMapExist()
	if gameWorld then
		return true 
	else 
		return false 
	end
end

--- Returns tile data at location x, y
function Map.getTileAt(x, y)
	if gameWorld[x] and gameWorld[x][y] then 
		return gameWorld[x][y] 
	else 
		print("WARNING: Can not return tile at {" .. x .. "," .. y .."} as tile does not exist")
		return false 
	end
end

--- Returns true if the tile at passed coordinates blocks movement
function Map.doesTileBlockMovementAt(x, y)
	if gameWorld[x] and gameWorld[x][y] and gameWorld[x][y].blockMovement then 
		return true 
	else 
		return false 
	end
end

--- Returns true if the tile can be moved through and if the 
--- tile has no creatures standing on it
function Map.isTotallyClear(x, y)
	if gameWorld[x] and gameWorld[x][y] then 
		if not gameWorld[x][y].blockMovement and not ReferenceStateGame.getCreature().isCreatureAt(x, y) then 
			return true 
		end 
	end 
	return false 
end

--- Returns true if the if the tile can be seen through
function Map.isTileTransparentAt(x, y)
	if gameWorld[x] and gameWorld[x][y] then 
		return not gameWorld[x][y].blockSight
	else 
		return false 
	end
end

--- Returns true if the current tile is visible or not
function Map.isTileVisibleAt(x, y)
	if gameWorld[x] and gameWorld[x][y] then 
		return gameWorld[x][y].visible 
	end
end

--- Returns an overworld tile image if that overworld tile
--- has been visited before
function Map.getOverworldTile(wx, wy, wz)
	if gameWorldsVisited[wx] and gameWorldsVisited[wx][wy] then 
		return tileImages[gameWorldsVisited[wx][wy].tileImg]
	end
	return false
end

function Map.getOverworldTileName(wx, wy, wz)
	if gameWorldsVisited[wx] and gameWorldsVisited[wx][wy] then 
		return gameWorldsVisited[wx][wy].tileName
	end
	return false
end

function Map.getGameWorldWidth() return gameWorldWidth end 
function Map.getGameWorldHeight() return gameWorldHeight end
function Map.getGameWorldZ() return gameWorldZ end
function Map.getGameWorldsLoaded() return gameWorldsLoaded end
function Map.getGameWorldPosition() return gameWorldPosition end
function Map.getTime() return time end

---
---
---
return Map