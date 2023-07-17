
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
	
	-- change the tag value, so in the enterFrame function changes the condition to move the element
	-- (this and the other elements in the classic game are moving to right, the same as dino)
	-- whe they stop the the motion to right, it apears as movin to the left, but actually they are still
	function instance:move()
		tag = true
	end

	-- call function in game2.lua to spaw a new element
	local function callGame()
		scene:spawnBackground()
	end
	
	local tPrevious = system.getTimer()
	local function enterFrame(event)
		-- move the instance "enemyL" to right, based on dino.first and dino.jumping properties
		local velFactor = instance.dino.speed
		local tDelta = event.time - tPrevious
		tPrevious = event.time
		if instance.dino.running and not tag then
			instance.x = instance.x + (tDelta * velFactor)
		elseif instance.dino.running then
			instance.x = instance.x + (tDelta * (velFactor-0.05))
		end

		if instance then
			-- eliminate the objects off out the left side of screen
			local x, y = instance:localToContent( 0, 0 )
			if x < -50 then
				local yc = math.random( 1, 27 )
				instance:translate( display.contentWidth + 100, 0 )
				instance.y = yc*10
				tag = false
				local rand = math.random(1, 5)
				tm = timer.performWithDelay( rand*200, callGame )
			end
		end
	end

	--stops the runtime listener
	function instance:stopEnterFrame()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		if tm then timer.cancel( tm ) end
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- return object
	instance.name = "cloud"
	instance.type = "cloud"
	return instance
end

return M
