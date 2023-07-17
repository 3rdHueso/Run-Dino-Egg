
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
	local yi = math.random( 1, 27 )
	instance.y = yi*10
	
	function instance:move()
		tag = true
	end

	local function callGame()
		scene:spawnBackground2()
	end

	local tPrevious = system.getTimer()
	local function enterFrame(event)
		local velFactor = instance.dino.speed
		local tDelta = event.time - tPrevious
		tPrevious = event.time
		if instance.dino.running and not tag then
			instance.x = instance.x + (tDelta * velFactor)
		elseif instance.dino.running then
			instance.x = instance.x + (tDelta *  (velFactor-0.05))
		end

		if instance then
			-- eliminate the objects off out the left side of screen
			local x, y = instance:localToContent( 0, 0 )
			if x < -50 then
				local yc = math.random( 1, 27 )
				instance:translate( display.contentWidth + 100, 0 )
				instance.y = yc*10
				tag = false
				local rand = math.random(6, 10)
				tm = timer.performWithDelay( rand*200, callGame )
			end
			if x > display.contentWidth + 70 then
				instance:translate( -20, 0 )
				tm = timer.performWithDelay( 500, callGame )
			end
		end
	end

	function instance:stopEnterFrame()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		if tm then timer.cancel( tm ) end
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- return instance
	instance.name = "cloud2"
	instance.type = "cloud2"
	return instance
end

return M
