
-- Extends an object

-- Define module
local M = {}

math.randomseed(os.time()) 
local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local color = composer.getVariable( "settedColor" )

	local tag = false
	
	function instance:move()
		tag = true
	end

	local function callGame()
		scene:spawnRocks()
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
				local rand = math.random(0, 10)
				tm = timer.performWithDelay( rand*200, callGame )
			end
		end
	end

	function instance:stopEnterFrame()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		if tm then timer.cancel( tm ) end
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	instance.name = "rock"
	instance.type = "rock"
	return instance
end

return M
