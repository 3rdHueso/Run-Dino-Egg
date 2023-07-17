
-- Module/class for platfomer animal/blob
-- Use this as a template to build an in-game animal/blob
math.randomseed(os.time())
-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local color = composer.getVariable( "settedColor" )

	local tag = false

	-- get properties before eliminate the place holder
	local parent = instance.parent
	local x, y = instance.x, instance.y
	instance:removeSelf()
	instance = nil

	-- Load spritesheet to create a new instance and replase the holder
	local fly = require("spritesheets.flysheet")
	local sheet = graphics.newImageSheet( "images/sprites/".. color .."/flysprite.png", fly:getSheet() )
	local sequenceData = {
		{ name = "flying", frames = { 1, 2 }, time = 333, loopCount = 0 },
	}
	instance = display.newSprite( parent, sheet, sequenceData )
	instance.x,instance.y = x, y
	instance:setSequence( "flying" )
	instance:play()

	local yi = math.random( 20, 29 )
	instance.y = yi*10

	-- get outlines for physics
	local fly_outlineUp = graphics.newOutline( 3, sheet, 1 )
	local fly_outlineDown = graphics.newOutline( 3, sheet, 2 )

	function instance:moveEnemy()
		tag = true
	end

	-- do this every frame
	local tPrevious = system.getTimer()
	local function enterFrame(event)
		local velFactor = instance.dino.speed
		local tDelta = event.time - tPrevious
		tPrevious = event.time
		if instance.dino.running and not tag then
			instance.x = instance.x + (tDelta * velFactor)
		end

		-- change the physics body depending on the frame
		if instance then
			if instance.frame == 1  then
				if instance.anim == 1 then
					physics.removeBody( instance )
					instance.bodyAdded = false
				end
				if not instance.bodyAdded then
					physics.addBody( instance, "static", { outline = fly_outlineUp, bounce = 0, friction =  1.0 } )	
					instance.isFixedRotation = true
					instance.anim = 2
					instance.bodyAdded = true
				end
			elseif instance.frame == 2 then
				if instance.anim == 2 then
					physics.removeBody( instance )
					instance.bodyAdded = false
				end
				if not instance.bodyAdded then
					physics.addBody( instance, "static", { outline = fly_outlineDown, bounce = 0, friction =  1.0 } )	
					instance.isFixedRotation = true
					instance.anim = 1
					instance.bodyAdded = true
				end
			end

			-- eliminate the objects off out the left side of screen
			local x, y = instance:localToContent( 0, 0 )
			if x < -50 then
				local yc = math.random( 20, 29 )
				instance:translate( display.contentWidth + 100, 0 )
				instance.y = yc*10
				tag = false
			end
		end
	end

	-- stop the sprite animation and enterframe listener
	function instance:stopAnimation()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		if instance then
			instance:pause()
		end
	end

	-- listeners for instance
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Return instance
	instance.name = "fly2_2nd"
	instance.type = "fly2_2nd"
	return instance
end

return M
