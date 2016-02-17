local class = require 'middleclass'
local anim8 = require 'anim8'
local Bullet = require 'bullet'
local Ship = class('Ship')


local images = {
	player = love.graphics.newImage('images/player.png'),
	enemy = love.graphics.newImage('images/enemy.png'),
}

local explosions = {
	enemy = {
		image = love.graphics.newImage('images/explosion.png'),
		frames = 7,
		width = 27,
		height = 23,
		offsetX = 4,
		offsetY = 0,
		speed = 0.03
	},
}

local quads = {
	player = { -- 25x26
		l2 = love.graphics.newQuad(  0,  0, 25, 26,  images.player:getWidth(), images.player:getHeight() ),
		l1 = love.graphics.newQuad( 25,  0, 25, 26,  images.player:getWidth(), images.player:getHeight() ),
		c  = love.graphics.newQuad( 50,  0, 25, 26,  images.player:getWidth(), images.player:getHeight() ),
		r1 = love.graphics.newQuad( 75,  0, 25, 26,  images.player:getWidth(), images.player:getHeight() ),
		r2 = love.graphics.newQuad( 100, 0, 25, 26,  images.player:getWidth(), images.player:getHeight() ),
		w = 25,
		h = 26
	},
	enemy = { -- 21x19
		l2 = love.graphics.newQuad(  0, 0, 21, 19, images.enemy:getWidth(), images.enemy:getHeight() ),
		l1 = love.graphics.newQuad( 21, 0, 21, 19, images.enemy:getWidth(), images.enemy:getHeight() ),
		c  = love.graphics.newQuad( 42, 0, 21, 19, images.enemy:getWidth(), images.enemy:getHeight() ),
		r1 = love.graphics.newQuad( 63, 0, 21, 19, images.enemy:getWidth(), images.enemy:getHeight() ),
		r2 = love.graphics.newQuad( 84, 0, 21, 19, images.enemy:getWidth(), images.enemy:getHeight() ),
		w = 21,
		h = 19
	}
}

function table.sum(t)
	local s = 0
	for i = 1, #t do
		s = t[i] + s
	end
	return s
end

function table.count(t)
	local s = 0
	for _, _ in ipairs(t) do
		s = s + 1
	end
	return s
end

function Ship:initialize(theater)
	table.insert(theater, self)
	self.theater = theater
	self.velocity = { x = 0, y = 0, ax = 0, ay = 0, _x = { }, _y = { } }
	self.velocityAngle = 0
	self.maxVelocity = 10
	self.x, self.y = 0, 0
	self.fizzed = false
	self.banged = false
	self.health = 100
	self.hit = false
	self.model = false
	self.route = false
	self.scale = 1
	self.bullets = { }
	self.firerate = 0.1
	self.bulletVelocity = 0
	self.maxBullets = 10
	self.exploding = false
	self.speed = 1
	self._debug = false
	self._fired = 0
	self._md = 0
	self._x, self._y = 0, 0
	self._t = 0
end

function Ship:tick(dt)

	-- have we died ?
	if self.banged then
		return false
	elseif self.health == 0 then
		self:explode()
	end

	-- Are we exploding ?
	if self.exploding then
		if self.explosion then
			self.explosion:update(dt)
			if self.explosion.status == 'paused' then
				self.banged = true
			end
		end
	end

	-- fire our bullets
	if self.firing then
		if love.timer.getTime() - self._fired > self.firerate then
			self:fire()
			self._fired = love.timer.getTime()
		end
	end

	-- tick our bullets
	for index, bullet in ipairs(self.bullets) do
		if not bullet:tick(dt) then
			table.remove(self.bullets, index)
		end
	end

	-- lets move the ship around
	if self.route then
		self.route:tick(dt)
	end

	return true
end

function Ship:explode()
	if not self.explosion then
		if explosions[self.model] then
			local explosion = anim8.newGrid(explosions[self.model].width, explosions[self.model].height, explosions[self.model].image:getWidth(), explosions[self.model].image:getHeight())
			self.explosion = anim8.newAnimation(explosion('1-'..explosions[self.model].frames, 1), explosions[self.model].speed, 'pauseAtEnd')
			self.exploding = true
		else
			self.banged = true
		end
	end
end

function Ship:damage(amount)
	self.health = self.health - amount
	self.hit = true
end

function Ship:move(x, y, dt)
	-- lock to the inside window
	if x + self.width*self.scale > love.graphics.getWidth() - 1 then
		x = love.graphics.getWidth() - self.width*self.scale - 1
	end
	if y + self.height*self.scale > love.graphics.getHeight() then
		y = love.graphics.getHeight() - self.height*self.scale
	end
	self._dx, self._dy = x, y
	self:setPosition(x, y)
end

function Ship:setPosition(x, y)

	if self.exploding then return end

	if self.x == 0 or self.y == 0 then
		self._x, self._y = self.x, self.y
	end

	self.x, self.y = x, y
	self:updateVelocity(x-self.x, y-self.y)
	self._x, self._y = self.x, self.y
end

local offset = math.rad(-90)

function Ship:updateVelocity(dx, dy)

	local angle = math.atan2((self.y - self._y), (self.x - self._x))
	--local angle = math.atan2 (self.x*self._y-self.y*self._x,self.x*self._x+self.y*self._y) 

	self.velocityAngle = angle

	if dx and dy and self.x ~= self._x then -- moving
		self.velocity.x = math.cos(angle) * 2
		self.velocity.y = math.sin(angle) * 2
	else -- auto level
		if self.velocity.x >= 0.1 then
			self.velocity.x = self.velocity.x - 0.1
		elseif self.velocity.x < -0.1 then
			self.velocity.x = self.velocity.x + 0.1
		else
			self.velocity.y = 0
		end
		if self.velocity.y > 0.1 then
			self.velocity.y = self.velocity.y - 0.1
		elseif self.velocity.y < -0.1 then
			self.velocity.y = self.velocity.y + 0.1
		else
			self.velocity.y = 0
		end
	end


	if #self.velocity._x == 40 then table.remove(self.velocity._x, 1) end
	table.insert(self.velocity._x, self.velocity.x)

	if #self.velocity._y == 40 then table.remove(self.velocity._y, 1) end
	table.insert(self.velocity._y, self.velocity.y)

	self.velocity.ax = table.sum(self.velocity._x) / #self.velocity._x
	self.velocity.ay = table.sum(self.velocity._y) / #self.velocity._y

end


function Ship:draw()
	if self.model then

		if self.exploding then
			self.explosion:draw(explosions[self.model].image, self.x, self.y, nil, self.scale, self.scale, explosions[self.model].offsetX, explosions[self.model].offsetY)
		else
			if self.hit then
				love.graphics.setColor(255, 255, 255, 100)
			else
				love.graphics.setColor(255, 255, 255, 255)
			end
			local velocity = self.velocity.ax
			if velocity > 1.5 then
				love.graphics.draw(images[self.model], quads[self.model].r2, self.x, self.y, nil, self.scale, self.scale)
			elseif velocity > 1 then
				love.graphics.draw(images[self.model], quads[self.model].r1, self.x, self.y, nil, self.scale, self.scale)
			elseif velocity < 1 and velocity > -1 then
				love.graphics.draw(images[self.model], quads[self.model].c, self.x, self.y, nil, self.scale, self.scale)
			elseif velocity < -1.5 then
				love.graphics.draw(images[self.model], quads[self.model].l2, self.x, self.y, nil, self.scale, self.scale)
			elseif velocity < -1 then
				love.graphics.draw(images[self.model], quads[self.model].l1, self.x, self.y, nil, self.scale, self.scale)
			end
		end
	end

	for index, bullet in ipairs(self.bullets) do
		bullet:draw()
	end

	if self._debug then
		self:debug()
	end

	self.hit = false

end

function Ship:setModel(model)
	if quads[model] then
		images[model]:setFilter("nearest", "nearest")
		self.model = model
		self.width = quads[model].w
		self.height = quads[model].h
	end
end

function Ship:setRoute(route)
	self.route = route
end

function Ship:setFiring(fire)
	self.firing = fire
end

function Ship:fire()
	if table.count(self.bullets) < self.maxBullets then
		local bullet = Bullet:new(self)
		bullet:setModel('player')	
		bullet:fire(self.bulletVelocity)
		table.insert(self.bullets, bullet)
	end
end

function Ship:debug()

	love.graphics.print(' X: ' .. tostring(self.x), 50, 50)
	love.graphics.print(' Y: ' .. tostring(self.y), 50, 70)
	love.graphics.print('vX: ' .. tostring(self.velocity.x), 50, 90)
	love.graphics.print('vY: ' .. tostring(self.velocity.y), 50, 110)
	love.graphics.print('vA: ' .. tostring(math.deg(self.velocityAngle)), 50, 130)

end

function Ship:setDebug(debug)
	self._debug = debug or false
end

return Ship