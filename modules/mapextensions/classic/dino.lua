
-- Module/class for platfomer dino

-- Use this as a template to build an in-game hero 
local composer = require( "composer" )

-- Define module
local M = {}

function M.new( instance, options )
	-- Get the current scene
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
	local color = composer.getVariable( "settedColor" )
	local velFactor = 0.3
	local character = composer.getVariable( "settedCharacter" )
	local numChar = tonumber(character)
	local myDensity

	--set the density dependin on the character
	if numChar == 1 then --Trex
		myDensity = 80
	elseif numChar == 2 then --velociraptor
		myDensity = 90
	elseif numChar == 3 then --allosaurio
		myDensity = 90
	elseif numChar == 4 then --espinosaurio
		myDensity = 57
	elseif numChar == 5 then --compi
		myDensity = 130
	end

	if sounds.state == "ON" then
		audio.setVolume( 1 )
	else
		audio.setVolume( 0 )
	end

	-- Default options for instance
	options = options or {}

	-- Store map placement and hide placeholder
	local parent = instance.parent
	local x, y = instance.x, instance.y
	instance:removeSelf()
	instance = nil

	-- Load spritesheet
	local dinoSheet = require("spritesheets.dinosheet" .. character)
	local sheet = graphics.newImageSheet( "images/sprites/".. color .."/dinosprite" .. character .. ".png", dinoSheet:getSheet() )
	local sequenceData1 = {
		{ name = "idle", frames = { 1 } },
		{ name = "walk", frames = { 2, 3}, time = 333, loopCount = 0 },
		{ name = "bendwalk", frames = { 4, 5}, time = 333, loopCount = 0 },
		{ name = "jump", frames = { 1 } },
		{ name = "ouch", frames = { 6 } },
	}
	instance = display.newSprite( parent, sheet, sequenceData1 )
	instance.x,instance.y = x, y
	instance:setSequence( "idle" )
	instance.speed = velFactor

	-- outlines to add physics bodies
	local dinoStand_outline = graphics.newOutline( 2, sheet, 1 )
	local dinoBend_outline = graphics.newOutline( 2, sheet, 4 )

	-- Keyboard control
	instance.running = false
	local first = true
	local lastEvent = {}

	local function key( event )
		local phase = event.phase
		local name = event.keyName
		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
		if phase == "down" then
			if "up" == name or "w" == name or "buttonA" == name then
				if instance.bodyType then
					if not instance.running and not instance.isDead then
						instance.running = true
						first = true
						instance.firstButton = first
					end	
					if not instance.bend then
						instance:jump()
					end
				end
				instance.first = first
			end
			if "down" == name or "s" == name or "buttonB" == name then
				if instance.running and not instance.isDead and not instance.jumping then
					instance:setSequence( "bendwalk" )
					instance:play()
				elseif instance.jumping then
					instance:applyLinearImpulse( 0, 2500 )
				end
				instance.bend = true
			end
		elseif phase == "up" then
			if "down" == name or "s" == name or "buttonB" == name then
				if instance.running and not instance.isDead then
					instance:setSequence( "walk" )
					instance:play()
				end
				instance.bend = false
			end
			if "up" == name or "w" == name or "buttonA" == name then
				instance.firstButton = false
			end
		end
		lastEvent = event
	end

	-- performs the  jump
	function instance:jump()
		if not self.jumping then
			self:applyLinearImpulse( 0, -2600 )
			instance:setSequence( "jump" )
			self.jumping = true
			audio.play( sounds.jump1 )
		end
	end

	-- dino was huert and die
	function instance:hurt()
		instance.isDead = true
		instance:setSequence( "ouch" )
		instance:finalize()
		audio.play( sounds.dead )
	end

	-- detects collision by dino
	function instance:collision( event )
		local phase = event.phase
		local other = event.other		
		local vx, vy = self:getLinearVelocity()
		if phase == "began" then
			if not self.isDead and ( other.type == "enemyS" or other.type == "enemyS2" or other.type == "enemyS3" or other.type == "enemyS4" or other.type == "enemyS5" or other.type == "enemyL" or other.type == "enemyL2" or other.type == "enemyL3" or other.type == "enemyL4" or other.type == "enemyL5" or other.type == "fly" or other.type == "fly2") then
					self:hurt()
			elseif not self.isDead and ( other.type == "enemyS_2nd" or other.type == "enemyS2_2nd" or other.type == "enemyS3_2nd" or other.type == "enemyS4_2nd" or other.type == "enemyS5_2nd" or other.type == "enemyL_2nd" or other.type == "enemyL2_2nd" or other.type == "enemyL3_2nd" or other.type == "enemyL4_2nd" or other.type == "enemyL5_2nd" or other.type == "fly_2nd" or other.type == "fly2_2nd" ) then
					self:hurt()
			elseif self.jumping and vy > 0 and not self.isDead then
				-- Landed after jumping
				self.jumping = false
				if not instance.bend then
					instance:setSequence( "walk" )
					instance:play()
				else
					instance:setSequence( "bendwalk" )
					instance:play()
				end	
			end
		end
	end

	--set the speed according to the score
	function instance:setSpeed()
		velFactor = velFactor + 0.02
		instance.speed = velFactor
	end

	--set the speed according to the score
	function instance:getSpeed()
		return instance.speed
	end

	local tPrevious = system.getTimer()
	-- Do this every frame
	local function enterFrame(event)
		if not instance.isDead and instance.anim then
			local vx, vy = instance:getLinearVelocity()
			if vx < 0 then	-- corrects the dino vx in case it gets slower after landing
				instance:setLinearVelocity( 0, vy )		
			end 
			if vx > 0 then	-- corrects the dino vx in case it gets faster after landing
				instance:setLinearVelocity( 0, vy )		
			end 
		end
		-- move the instance "dino" to right
		local tDelta = event.time - tPrevious
		tPrevious = event.time
		if first and not instance.jumping then
			first = false
		elseif instance.running and not first then
			instance.x = instance.x + (tDelta * velFactor)
		end

		-- change the physics body depending on the sequence
		if instance.sequence == "idle" or instance.sequence == "walk" or instance.sequence == "jump" or instance.sequence == "ouch" then
			if instance.anim == 1 then
				physics.removeBody( instance )
				instance.bodyAdded = false
			end
			if not instance.bodyAdded then
				physics.addBody( instance, "dynamic", { outline = dinoStand_outline, density = myDensity, bounce = 0, friction =  0.0 } )	
				instance.isFixedRotation = true
				instance.anim = 2
				instance.bodyAdded = true
			end
		elseif instance.sequence == "bendwalk" then
			if instance.anim == 2 then
				physics.removeBody( instance )
				instance.bodyAdded = false
			end
			if not instance.bodyAdded then
				physics.addBody( instance, "dynamic", { outline = dinoBend_outline, density = myDensity, bounce = 0, friction =  0.0 } )	
				instance.isFixedRotation = true
				instance.anim = 1
				instance.bodyAdded = true
			end
		end

	end

	-- On remove, cleanup instance, or call directly for non-visual
	function instance:finalize()
		physics.pause()
		instance:removeEventListener( "collision" )
		Runtime:removeEventListener( "enterFrame", enterFrame )
		instance:removeEventListener( "finalize" )
		instance:pause()
	end

	-- finalize key listener 
	function instance:endKeys()
		Runtime:removeEventListener( "key", key )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )
	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )
	-- Add our key/joystick listeners
	Runtime:addEventListener( "key", key )
	-- Add our collision listeners
	instance:addEventListener( "collision" )

	-- Return instance
	instance.name = "dino"
	instance.type = "dino"
	return instance
end

return M
