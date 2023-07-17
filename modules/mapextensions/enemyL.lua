
-- Extends an object to give it a physics body

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
	local color = composer.getVariable( "settedColor" )
	local number = instance.name

	-- add physic to instance
	local imageOutline = graphics.newOutline( 2, "images/maps/" .. color .. "/cactusLarge" .. number .. ".png" )
	physics.addBody( instance, "static", { outline = imageOutline, isSensor = true } )

	return instance
end

return M
