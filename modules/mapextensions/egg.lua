
-- Extends an object to act as a pickup

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
	local color = composer.getVariable( "settedColor" )

	if sounds.state == "ON" then
		audio.setVolume( 1 )
	else
		audio.setVolume( 0 )
	end

	-- detects collision with instance egg 
	function instance:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.type == "dino" then
			audio.play( sounds.eggSound )
			other.eggList:heal()
			self:removeEventListener( "collision" )
			display.remove( self )
			self = nil
		end
	end

	-- add physics to instance
	local imageOutline = graphics.newOutline( 3, "images/img_" .. color .. "/egg.png" )
	physics.addBody( instance, "static", { outline = imageOutline, isSensor = true } )
	instance:addEventListener( "collision" )

	return instance
end

return M
