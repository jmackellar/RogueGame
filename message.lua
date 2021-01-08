--- Module File
local Message = { }
--- Message Variables
local messages = { }
local messageDrawX = false 
local messageDrawY = false 
local messageDrawWidth = 300
local messageDrawHeight = 300
local messageDrawOpacity = 0.75
local messageCurrentTurn = 0
local messageTime = false

function Message.loadAssets()
	print("Loading Message Assets")
	messageDrawX = love.graphics.getWidth() - 315
	messageDrawY = 30
end

function Message.draw(gameFonts)
	--- Break Down Message Data
	local width, text = 0, ''
	local messagetodraw = { }
	local lines = 1
	local maxlines = math.floor(love.graphics.getHeight() / 14) - 4
	for i = # messages, 1, -1 do 
		width, text = gameFonts.slkscr14:getWrap(messages[i].text, messageDrawWidth - 20)
		for j = 1, # text do 
			table.insert(messagetodraw, {text = text[j], color = messages[i].color})
			lines = lines + 1
		end
	end
	love.graphics.setLineWidth(3)
	--- Background
	love.graphics.setColor(0, 0, 0, messageDrawOpacity)
	love.graphics.rectangle('fill', messageDrawX, messageDrawY, messageDrawWidth, ((maxlines) + 1) * 14)
	--- Foreground
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('line', messageDrawX, messageDrawY, messageDrawWidth, ((maxlines) + 1) * 14)
	--- Draw Message
	for i = 1, math.min(lines - 1, maxlines - 1) do 
		love.graphics.setFont(gameFonts.slkscr14)
		love.graphics.setColor(messagetodraw[i].color[1], messagetodraw[i].color[2], messagetodraw[i].color[3])
		love.graphics.printf(messagetodraw[i].text, messageDrawX + 10, messageDrawY + i * 14, messageDrawWidth - 20, "left")
	end
	love.graphics.setFont(gameFonts.pixelu24)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf('INFO', messageDrawX, messageDrawY - 32, messageDrawWidth - 10, "right")
	love.graphics.setLineWidth(1)
	love.graphics.setFont(gameFonts.slkscr18)
	love.graphics.printf(Message.clockString(), messageDrawX, messageDrawY - 27, messageDrawWidth - 90, "left")
	love.graphics.printf(Message.dateString(), messageDrawX, messageDrawY - 27, messageDrawWidth, "center")
end

function Message.dateString()
	local str = ''
	return str .. messageTime.day .. '/' .. messageTime.month .. '/' .. messageTime.year
end

function Message.clockString()
	local str = ''
	local hrstr = messageTime.hour
	local append = ' AM'
	if hrstr > 12 then 
		hrstr = hrstr - 12 
		append = ' PM'
	end 
	if string.len(messageTime.hour) == 1 then 
		str = str .. '0' .. hrstr
	else 
		str = str .. hrstr
	end 
	str = str .. ':'
	if string.len(messageTime.minute) == 1 then 
		str = str .. '0' .. messageTime.minute 
	else 
		str = str .. messageTime.minute 
	end 
	return str .. append
end

function Message.receiveMessage(msg)
	msg['turn'] = messageCurrentTurn
	table.insert(messages, msg)
end

function Message.setCurrentTurn(turn)
	messageCurrentTurn = turn 
end

function Message.sendTime(time)
	messageTime = time 
end

--- Takes a passed text and returns either 'a' or 'an' based
--- on which would be more grammatically correct preceding 
function Message.aOrAn(text)
	local check = {'a','e','o','i','u'}
	local letter = string.lower(string.sub(text, 1, 1))
	local ret = 'a'
	for i = 1, # check do 
		if letter == check[i] then 
			ret = 'an'
			break
		end 
	end
	return ret
end

return Message