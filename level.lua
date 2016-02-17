local class = require 'middleclass'
local Ship = require 'ship'
local Level = class('Level')


function Level:initialize(theater, level)
	self.theater = theater
	self.level = level
	self.time = 0
end
--[[
{ type = 'ship', model = 'enemy', interval = 0.25, count = 10, route = function(ship)
			return Route.curve:new(ship, {
				0, 0,
				400, 300,
				0, 650
			})
		end }
]]
function Level:tick(dt)
	self.time = self.time + dt
	for i, action in ipairs(self.level) do
		if not action.startAt or action.startAt < self.time then
			if not action.ended and (not action.lastTick or (love.timer.getTime() > action.lastTick + action.interval)) then
				self:handle(action)
				print('tickhit')
				action.lastCount = (action.lastCount or 0) + 1
				action.lastTick = love.timer.getTime()

				if action.count and action.lastCount >= action.count then
					action.ended = true
					print('Done!')
				end

			end
		end
	end
end

function Level:handle(action)
	if action.type == 'ship' then

		local Enemy = Ship:new(self.theater)

		if action.model then
			Enemy:setModel('enemy')
		end

		if action.route then
			Enemy:setRoute(action.route(Enemy))
		end

	end
end

return Level