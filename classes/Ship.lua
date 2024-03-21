local class = require("lib.middleclass")

local Entity = require("classes.Entity")

local Ship = class("Ship", Entity)

Ship.static.preferredEngagementDistance = 150
Ship.static.engagementDistanceToleranceWidth = 20

Ship.static.displayObjectColoursByRelation = {
	ally = {0, 1, 0},
	neutral = {1, 1, 0},
	enemy = {1, 0, 0}
}

function Ship:initialize(args)
	Ship.super.initialize(self, args)

	assert(args.team)
	self.team = args.team

	self.aiEnabled = not not args.aiEnabled
	self.currentTarget = args.currentTarget

	self.hull = self.class.maxHull
	self.guns = {}
end

function Ship:clearTemporaryFields()
	Ship.super:clearTemporaryFields()

	self.will = nil

	if self.guns then
		for _, gun in ipairs(self.guns) do
			gun:clearTemporaryFields()
		end
	end
end

return Ship
