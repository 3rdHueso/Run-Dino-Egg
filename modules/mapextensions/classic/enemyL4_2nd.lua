
-- Extends an object to give it a physics body

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local color = composer.getVariable( "settedColor" )

	-- add physic to instance
	local imageOutline = graphics.newOutline( 2, "images/maps/" .. color .. "/cactusLarge4.png" )
	physics.addBody( instance, "static", { outline = imageOutline, isSensor = true } )

	local tag = false
	
	function instance:moveEnemy()
		tag = true
	end

	local tPrevious = system.getTimer()
	local function enterFrame(event)
		-- move the instance "enemyL" to right, based on dino.first and dino.jumping properties
		local velFactor = instance.dino.speed
		local tDelta = event.time - tPrevious
		tPrevious = event.time
		if instance.dino.running and not tag then
			instance.x = instance.x + (tDelta * velFactor)
		end

		if instance then
			-- eliminate the objects off out the left side of screen
			local x, y = instance:localToContent( 0, 0 )
			if x < -50 then
				instance:translate( display.contentWidth + 100, 0 )
				tag = false					
			end
		end
	end

	function instance:stopEnterFrame()
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	instance.name = "enemyL4_2nd"
	instance.type = "enemyL4_2nd"
	return instance
end

return M
