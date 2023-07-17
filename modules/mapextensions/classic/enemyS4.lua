
-- Extends an object to give it a physics body
math.randomseed(os.time()) 

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local color = composer.getVariable( "settedColor" )

	-- add physic to instance
	local imageOutline = graphics.newOutline( 2, "images/maps/" .. color .. "/cactusSmall4.png" )
	physics.addBody( instance, "static", { outline = imageOutline, isSensor = true } )

	local tag = false
	
	local function callGameEnemies2()
		scene:spawnEnemies2()
	end

	function instance:moveEnemy()
		tag = true
		local rand = math.random(5, 15)
		print("calling spawnEnemies2 en ".. rand*100 .." ms")
		tm2 = timer.performWithDelay( rand*100, callGameEnemies2 )
	end

	local function callGame()
		scene:spawnEnemies()
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
				local rand = math.random(0, 6)
				print("calling spawnEnemies1 en ".. rand*100 .." ms")
				tm = timer.performWithDelay( rand*100, callGame )
			end
		end
	end

	function instance:stopEnterFrame()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		if tm then timer.cancel( tm ) end
		if tm2 then timer.cancel( tm2 ) end
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	instance.name = "enemyS4"
	instance.type = "enemyS4"
	return instance
end

return M
