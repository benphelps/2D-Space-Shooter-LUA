local class = require 'middleclass'

local images = {
	player = {
		image = love.graphics.newImage('images/player_bullet.png'),
		offsetX = -11,
		offsetY = 10
	}
}



local Bullet = class('Bullet')

function Bullet:initialize(ship)
	self.x, self.y = 0, 0
	self.angle = 0
	self.scale = ship.scale
	self.ship = ship
	self.model = ship.model or false
	self.born = love.timer.getTime()
	self.banged = false
	self.exploding = false
	self._exploding = 0
	self.damage = 100
end

function Bullet:fire(velocity)
	self.velocity = velocity
	self.x = self.ship.x
	self.y = self.ship.y
end


function Bullet:collied()

	if self.model and images[self.model] then

		for _, ship in ipairs(self.ship.theater) do
			if self.ship ~= ship
			and not ship.exploding
			and self.x < ship.x + ship.width
			and self.x + self.width > ship.x - ship.width
			and self.y - self.height < ship.y + ship.height
			and self.height + self.y > ship.y then
				self.banged = true
				ship:damage(self.damage)
			end
		end

	end

end

function Bullet:tick(dt)
	if self.banged then
		return false
	elseif love.timer.getTime() - self.born > 2 then
		return false
	else
		self.y = self.y + self.velocity
		self:collied()
	end
	return true
end

function Bullet:setModel(model)
	if images[model] then
		self.model = model
		local width, height = images[model].image:getDimensions()
		self.width, self.height = width * self.scale, height * self.scale
	end
end

function Bullet:draw()
	if self.model and images[self.model] then
		love.graphics.draw(images[self.model].image, self.x, self.y, nil, self.scale, self.scale, images[self.model].offsetX, images[self.model].offsetY)
	end
end

return Bullet