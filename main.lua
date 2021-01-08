local ProFi = require('lib/profi')
local gameState = 'game'
local states = { }
local DEBUG = true

function love.load()
	print("Initializing Display")
	love.window.setMode(1280, 720, {resizable = false, fullscreen = true, vsync = true})
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setKeyRepeat(true)
	love.graphics.setBackgroundColor(0.07, 0.08, 0.09, 255)
	love.graphics.setBlendMode('alpha')
	print("Initializing Game States")
	states.game = {state = require("game"), loaded = false}
end

function love.update(dt)
	if states[gameState] then
		if not states[gameState].loaded and states[gameState].state.load then 
			states[gameState].state.load()
			states[gameState].loaded = true
		end
		if states[gameState].state.update then 
			states[gameState].state.update(dt)
		end
		states[gameState].state.DEBUG = DEBUG
	end
end

function love.draw()
	if states[gameState] then 
		if states[gameState].state.draw then 
			states[gameState].state.draw()
		end
	end
end

function love.keypressed(key, isrepeat)
	if states[gameState] then 
		if states[gameState].state.keypressed then 
			states[gameState].state.keypressed(key, isrepeat)
		end
	end
	if DEBUG then 
		if key == 'f1' then 
			ProFi:start()
		elseif key == 'f2' then
			ProFi:stop()
			ProFi:writeReport( 'MyProfilingReport.txt' )
		end
	end
end