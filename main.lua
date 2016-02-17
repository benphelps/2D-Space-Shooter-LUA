

--[[
local enemyInterval = 0.1
local enemyCountGoal = 25
local enemyCount = 0
local lastEnemy = 0
]]

function love.load()

	-- fixed mouse
	love.mouse.setRelativeMode(true)

	-- we're a pixel art game!
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- fixed width text
	local fixedFont = love.graphics.newFont("images/Inconsolata-Regular.ttf", 14)
	love.graphics.setFont(fixedFont)

	-- load stuff
	Ship = require 'ship'
	Route = require 'route'
	Level = require 'level'

	-- setup the game field/theater
	theater = {
		
	}

	-- setup the player
	Player = Ship:new(theater)
	Player:setModel('player')
	Player:setPosition(400, 300)
	Player.bulletVelocity = -5

	TestLevel = Level:new(theater, {
		{ type = 'ship', model = 'enemy', interval = 0.2, count = 5, route = function(ship) return Route.curve:new(ship, { 0, 0, 800, 300, 0, 650 }, 2) end },
		{ type = 'ship', model = 'enemy', interval = 0.2, startAt = 0.2, count = 5, route = function(ship) return Route.curve:new(ship, { 800, 0, 0, 300, 800, 650 }, 2) end },
		{ type = 'ship', model = 'enemy', interval = 0.15, startAt = 4, count = 25, route = function(ship) return Route.curve:new(ship, { 0, 0, 800, 650 }, 1.5) end },
		{ type = 'ship', model = 'enemy', interval = 0.15, startAt = 4, count = 25, route = function(ship) return Route.curve:new(ship, { 800, 0, 0, 650 }, 1.5) end },
		{ type = 'ship', model = 'enemy', interval = 0.15, startAt = 7, count = 10, route = function(ship) return Route.curve:new(ship, { 200, 0, 200, 650 }, 1.5) end },
		{ type = 'ship', model = 'enemy', interval = 0.15, startAt = 7, count = 10, route = function(ship) return Route.curve:new(ship, { 600, 0, 600, 650 }, 1.5) end },
	})

end

function love.draw()
	for index, ship in ipairs(theater) do
		ship:draw()
	end
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

local interval = 0.05
local total = 0
local lastMove = 0
function love.update(dt)
	total = total + dt   -- we add the time passed since the last update, probably a very small number like 0.01
	if total >= interval then
		total = total - interval
		if lastMove + interval < love.timer.getTime() then
			--Player:updateVelocity(false, false)
		end
	end

	for index, ship in ipairs(theater) do
		if not ship:tick(dt) then
			table.remove(theater, index)
		end
	end

	local x, y = love.mouse.getPosition()
	Player:move(x, y, dt)
	TestLevel:tick(dt)

end

function love.mousemoved(x, y, dx, dy)
	lastMove = love.timer.getTime()
end

function love.mousepressed( x, y, button )
	Player:setFiring(true)
end

function love.mousereleased( x, y, button )
	Player:setFiring(false)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end


love.mouse.setVisible(false)