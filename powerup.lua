local class = require 'middleclass'

local Powerup = class('Powerup')

function Powerup:initialize(ship)
	self.ship = ship
end