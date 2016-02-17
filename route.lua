local class = require 'middleclass'

local Routes = {
	
}
local Route = class('Route')

-- simple sin wave movement

local RouteSin = class('RouteSin', Route)

RouteSin.angle = 180
RouteSin.velocity = 1

function RouteSin:initialize(ship, angle, velocity)
	self.ship = ship
	self.angle = angle
	self.velocity = velocity
end

function RouteSin:tick()

	local mx, my = love.graphics.getDimensions()

	self.angle = self.angle + 1
	if self.angle > 359 then
		self.angle = 1
	end

	local x = self.ship.x + (math.sin(math.rad(self.angle)) * 2)
	local y = self.ship.y + self.velocity

	self.ship:setPosition(x, y)

	if self.ship.y > my then
		self.ship.banged = true
	end

end

Routes.sin = RouteSin


local RouteCurve = class('RouteCurve', Route)

RouteCurve.vertices = {
	0, 0,
	800, 300,
	0, 650,
}
RouteCurve.curve = love.math.newBezierCurve( RouteCurve.vertices )
RouteCurve.resolution = 100
RouteCurve.step = 0

function RouteCurve:initialize(ship, vertices, velocity)
	self.ship = ship
	self.resolution = self.resolution * velocity
	self:setVertices(vertices)
end

function RouteCurve:setVertices(vertices)
	self.vertices = vertices
	self.curve = love.math.newBezierCurve( self.vertices )
end

function RouteCurve:tick()

	local mx, my = love.graphics.getDimensions()

	self.step = self.step + 1
	if self.step > self.resolution then self.step = 0 end
	local t = (1 / self.resolution) * self.step
	local x, y = self.curve:evaluate(t)
	self.ship:setPosition(x, y)

	if self.ship.y > my  then
		self.ship.banged = true
	end

end

Routes.curve = RouteCurve

return Routes