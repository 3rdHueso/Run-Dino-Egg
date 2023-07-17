
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- required libraries
math.randomseed(os.time()) 
local physics = require( "physics" )
local json = require( "json" )
local tiled = require( "modules.ponytiled" )
local translations = require("modules.translations")
local appodeal = require( "plugin.appodeal" )
local stopwatch = require "modules.stopwatch"

-- needed variables
local language = composer.getVariable( "settedLanguage" )
local color = composer.getVariable( "settedColor" )
local soundsVol = composer.getVariable( "settedSoundsVol" )
local buttonPlace = composer.getVariable( "settedButtonPlace" )
local map, dino, fly, fly2, enemyL, enemyL2, enemyL3, enemyL4, enemyL5, enemyS, enemyS2, enemyS3, enemyS4, enemyS5, cloud, cloud2, finalGroup
local fly_2nd, fly2_2nd, enemyL_2nd, enemyL2_2nd, enemyL3_2nd, enemyL4_2nd, enemyL5_2nd, enemyS_2nd, enemyS2_2nd, enemyS3_2nd, enemyS4_2nd, enemyS5_2nd, block
local rock, rock2
local buttonA, buttonB
local classicHiScore
local classicHifilePath = system.pathForFile( "classicHi.json", system.DocumentsDirectory )
local againButton
local menuButton
local score = 0
local scoreText
local scoreTextLit
local time
local i = 1
local cnt = 0
local hiScore
local v = 0

-- preoload sounds
scene.sounds = {
	jump1 = audio.loadSound( "sounds/jump1.mp3" ),
	dead = audio.loadSound("sounds/dead.mp3"),
	scoreSound = audio.loadSound("sounds/hitscore.mp3")
}
scene.sounds.state = soundsVol

-- save variable state to turn off or on the sound
if scene.sounds.state == "ON" then
	audio.setVolume( 1 )
else
	audio.setVolume( 0 )
end

--spawn enemies randomly
function scene:spawnEnemies()
	local rand
	if score > 500 then
		rand = math.random(1, 20)
	else
		rand = math.random(1, 10)
	end
	
	if rand == 1 then
		enemyL:moveEnemy()
	elseif rand == 2 then
		enemyL2:moveEnemy()
	elseif rand == 3 then
		enemyL3:moveEnemy()
	elseif rand == 4 then
		enemyL4:moveEnemy()
	elseif rand == 5 then
		enemyL5:moveEnemy()
	elseif rand == 6 then
		enemyS:moveEnemy()
	elseif rand == 7 then
		enemyS2:moveEnemy()
	elseif rand == 8 then
		enemyS3:moveEnemy()
	elseif rand == 9 then
		enemyS4:moveEnemy()
	elseif rand == 10 then
		enemyS5:moveEnemy()
	elseif rand == 11 or 12 or 13 or 14 or 15 then
		fly:moveEnemy()
	elseif rand == 16 or 17 or 18 or 19 or 20 then
		fly2:moveEnemy()
	end
end

--spawn 2nd enemies randomly
function scene:spawnEnemies2()
	local rand
	if score > 500 then
		rand = math.random(1, 20)
	else
		rand = math.random(1, 10)
	end
	
	if rand == 1 then
		enemyL_2nd:moveEnemy()
	elseif rand == 2 then
		enemyL2_2nd:moveEnemy()
	elseif rand == 3 then
		enemyL3_2nd:moveEnemy()
	elseif rand == 4 then
		enemyL4_2nd:moveEnemy()
	elseif rand == 5 then
		enemyL5_2nd:moveEnemy()
	elseif rand == 6 then
		enemyS_2nd:moveEnemy()
	elseif rand == 7 then
		enemyS2_2nd:moveEnemy()
	elseif rand == 8 then
		enemyS3_2nd:moveEnemy()
	elseif rand == 9 then
		enemyS4_2nd:moveEnemy()
	elseif rand == 10 then
		enemyS5_2nd:moveEnemy()
	elseif rand == 11 or 12 or 13 or 14 or 15 then
		fly_2nd:moveEnemy()
	elseif rand == 16 or 17 or 18 or 19 or 20 then
		fly2_2nd:moveEnemy()
	end
end

--spawn the rocks for background
function scene:spawnRocks()
	local c = math.random(1, 4)
	if c == 1 or c == 3 then
		rock:move()
	end
	if c == 2 or c == 4 then
		rock2:move()
	end
end

--spawn cloud for background
function scene:spawnBackground()
	cloud:move()
end

--spawn 2nd cloud for background
function scene:spawnBackground2()
	cloud2:move()
end

--blink the score
local function blinkScore()
	function onText()
		cnt = cnt + 1
		scoreTextLit.isVisible = true
		if cnt < 4 then
			local timer3 = timer.performWithDelay(100, offText)
		else
			scoreText.isVisible = true
			scoreTextLit.isVisible = false
		end
	end
	function offText()
		scoreTextLit.isVisible = false
		local timer2 = timer.performWithDelay(100, onText)
	end
	local timer1 = timer.performWithDelay(100, offText)
end

-- loads the hi score
local function loadHi()
	local file = io.open( classicHifilePath, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        classicHiScore = json.decode( contents )
    end
end

-- save the new hi score
local function saveHi()
	local file = io.open( classicHifilePath, "w" )
    if file then
        file:write( json.encode( classicHiScore ) )
        io.close( file )
    else
		file = io.open( classicHifilePath, "w" )
		file:write( json.encode( classicHiScore ) )
    	io.close( file )
    end
end

--reload level or change to menu
local function endGame(event)
	-- remove listener from existing buttons
	if againButton then
		againButton:removeEventListener( "tap", endGame ) 
	end
	if menuButton then
		menuButton:removeEventListener( "tap", endGame )
	end
	-- refresh game2 or go to menu deoending on the button pressed
	local name = event.target.name
	if name == "again" then
		composer.gotoScene( "scenes.refreshClassic" )	
	end
	if name == "menu" then
		composer.gotoScene( "scenes.menu" )
	end
	--return
	return true
end

-- function to display the final elements when dino died, also remove listener for keys
local function endInfo()
	-- remove jump and bend buttons
	buttonA:removeSelf()
	buttonA = nil
	buttonB:removeSelf()
	buttonB = nil
	--show banner
	appodeal.show( "banner", { yAlign="bottom" })
	--place again and menu buttons
	local dcw = display.contentWidth
	local space = dcw * 0.33
	againButton = display.newImageRect(finalGroup, "images/img_".. color .."/again.png", 70, 70)
	againButton.x = space
	againButton.y = 100
	againButton.name = "again"
	menuButton = display.newImageRect(finalGroup, "images/img_".. color .."/menu.png", 70, 70)
	menuButton.x = space * 2
	menuButton.y = 100
	menuButton.name = "menu"
	againButton:addEventListener( "tap", endGame ) 
	menuButton:addEventListener( "tap", endGame ) 
	-- finalize the runtime listener key
    dino:endKeys()
    -- open the file to save the data
    loadHi()
    classicHiScore = hiScore  
    saveHi()
    --update the HI score text
    hiScoreText.text = hiScore
    if hiScore < 10 then
		hiScoreText.text = "HI   0000"..hiScore
	elseif hiScore < 100 then
		hiScoreText.text = "HI   000"..hiScore
	elseif hiScore < 1000 then
		hiScoreText.text = "HI   00"..hiScore
	elseif hiScore < 10000 then
		hiScoreText.text = "HI   0"..hiScore
	else
		hiScoreText.text = "HI   " ..hiScore
	end
	--return group
    return finalGroup
end

-- Function to scroll the map and update the scores
local function enterFrame( event )
	local elapsed = event.time
	-- Easy way to scroll a map based on a character
	if dino and dino.x and dino.y and not dino.isDead then
		-- Easy way to scroll a map based on a character
		local x, y = dino:localToContent( 300, -50 )
		x = display.contentCenterX - x -- scrolls map in x
		map.x = map.x + x
		---begin call enemies
		if dino.firstButton then
			v = v + 1
			if v == 1 then
				--first call to spawnEnemies and other elements
				appodeal.hide( "banner" )
				scene:spawnEnemies()
				scene:spawnRocks()
				scene:spawnBackground()
				timer.performWithDelay( 10, spawnBackground2 )
				--begin to count elapsed time (to calculate distance)
				time = stopwatch.new()
			end
		end
		-- update the distance calculated as the record of the game
		if time then
			--calculate the distance every frame
			local elapsed = time:getElapsed()
			local speed = dino:getSpeed()
			local distance = math.round(elapsed * speed*0.03) 
			-- the score is the distance traveled
			score = distance
			-- update the score every frame
			if score < 10 then
				scoreText.text = "0000"..score
			elseif score < 100 then
				scoreText.text = "000"..score
			elseif score < 1000 then
				scoreText.text = "00"..score
			elseif score < 10000 then
				scoreText.text = "0"..score
			else
				scoreText.text = score
			end
			--increase the velocity each 100
			if score == 100 * i then
				i = i + 1
				if speed < 1 then  -- speed limit in 1.0
					dino:setSpeed()
				end
				audio.play( scene.sounds.scoreSound )
				--use a text object to make the score blinks each 100
				scoreTextLit.text = scoreText.text
				scoreText.isVisible = false
				scoreTextLit.isVisible = true
				cnt = 0
				blinkScore()
			end
			--update de HI Score value
			if score > hiScore then
				hiScore = score
			end
		end
	end
	if dino.isDead then -- whe dino dies
		--stop the runtime event
		Runtime:removeEventListener( "enterFrame", enterFrame )
		-- stops all the runtime event in the modules, stop counting the elapsed time
		dino:finalize()
		time:pause()
		time = nil
		for i = 1, #block do 
			block[i]:stopTranslation()
		end
		enemyL:stopEnterFrame()
		enemyL2:stopEnterFrame()
		enemyL3:stopEnterFrame()
		enemyL4:stopEnterFrame()
		enemyL5:stopEnterFrame()
		enemyS:stopEnterFrame()
		enemyS2:stopEnterFrame()
		enemyS3:stopEnterFrame()
		enemyS4:stopEnterFrame()
		enemyS5:stopEnterFrame()
		fly:stopAnimation()
		fly2:stopAnimation()
		enemyL_2nd:stopEnterFrame()
		enemyL2_2nd:stopEnterFrame()
		enemyL3_2nd:stopEnterFrame()
		enemyL4_2nd:stopEnterFrame()
		enemyL5_2nd:stopEnterFrame()
		enemyS_2nd:stopEnterFrame()
		enemyS2_2nd:stopEnterFrame()
		enemyS3_2nd:stopEnterFrame()
		enemyS4_2nd:stopEnterFrame()
		enemyS5_2nd:stopEnterFrame()
		fly_2nd:stopAnimation()
		fly2_2nd:stopAnimation()
		cloud:stopEnterFrame()
		cloud2:stopEnterFrame()
		rock:stopEnterFrame()
		rock2:stopEnterFrame()
		--call function to show the again and menu buttons
		endInfo()
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- -------------------------------------------------------------------------------
	appodeal.show( "banner", { yAlign="bottom" })
	physics.start()
	physics.setGravity( 0, 120 )
	--physics.setDrawMode( "hybrid" )

	-- Load our level
	local filename = "images/maps/".. color .."/classic.json" or event.filename
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "images/maps/" .. color )
	-- Find our hero!
	map.extensions = "modules.mapextensions.classic."
	map:extend( "dino" )
	dino = map:findObject( "dino" )
	-- Find our enemies and other items as individual items (watch the extension files)
	map:extend( "fly", "fly2" ) 
	fly = map:findObject( "fly" ) 
	fly.dino = dino
	fly2 = map:findObject( "fly2" ) 
	fly2.dino = dino
	map:extend( "fly_2nd", "fly2_2nd" ) 
	fly_2nd = map:findObject( "fly_2nd" ) 
	fly_2nd.dino = dino
	fly2_2nd = map:findObject( "fly2_2nd" ) 
	fly2_2nd.dino = dino
	map:extend( "enemyL", "enemyL2", "enemyL3", "enemyL4", "enemyL5" ) 
	enemyL = map:findObject( "enemyL" )
	enemyL.dino = dino
	enemyL2 = map:findObject( "enemyL2" )
	enemyL2.dino = dino
	enemyL3 = map:findObject( "enemyL3" )
	enemyL3.dino = dino
	enemyL4 = map:findObject( "enemyL4" )
	enemyL4.dino = dino
	enemyL5 = map:findObject( "enemyL5" )
	enemyL5.dino = dino
	map:extend( "enemyL_2nd", "enemyL2_2nd", "enemyL3_2nd", "enemyL4_2nd", "enemyL5_2nd" )  
	enemyL_2nd = map:findObject( "enemyL_2nd" )
	enemyL_2nd.dino = dino
	enemyL2_2nd = map:findObject( "enemyL2_2nd" )
	enemyL2_2nd.dino = dino
	enemyL3_2nd = map:findObject( "enemyL3_2nd" )
	enemyL3_2nd.dino = dino
	enemyL4_2nd = map:findObject( "enemyL4_2nd" )
	enemyL4_2nd.dino = dino
	enemyL5_2nd = map:findObject( "enemyL5_2nd" )
	enemyL5_2nd.dino = dino
	map:extend( "enemyS", "enemyS2", "enemyS3", "enemyS4", "enemyS5" ) 
	enemyS = map:findObject( "enemyS" )
	enemyS.dino = dino
	enemyS2 = map:findObject( "enemyS2" )
	enemyS2.dino = dino
	enemyS3 = map:findObject( "enemyS3" )
	enemyS3.dino = dino
	enemyS4 = map:findObject( "enemyS4" )
	enemyS4.dino = dino
	enemyS5 = map:findObject( "enemyS5" )
	enemyS5.dino = dino
	map:extend( "enemyS_2nd", "enemyS2_2nd", "enemyS3_2nd", "enemyS4_2nd", "enemyS5_2nd" ) 
	enemyS_2nd = map:findObject( "enemyS_2nd" )
	enemyS_2nd.dino = dino
	enemyS2_2nd = map:findObject( "enemyS2_2nd" )
	enemyS2_2nd.dino = dino
	enemyS3_2nd = map:findObject( "enemyS3_2nd" )
	enemyS3_2nd.dino = dino
	enemyS4_2nd = map:findObject( "enemyS4_2nd" )
	enemyS4_2nd.dino = dino
	enemyS5_2nd = map:findObject( "enemyS5_2nd" )
	enemyS5_2nd.dino = dino
	map:extend( "rock", "rock2" )
	rock = map:findObject( "rock" )
	rock.dino = dino
	rock2 = map:findObject( "rock2" )
	rock2.dino = dino
	map:extend( "cloud", "cloud2" )
	cloud = map:findObject( "cloud" )
	cloud.dino = dino
	cloud2 = map:findObject( "cloud2" )
	cloud2.dino = dino
	map:extend("block")
	block = map:listTypes("block")
	-- each item has a .dino property in order to obtain value from dino

	-- add virtual joysticks to mobile 
	local vjoy = require( "modules.vjoy" )
	buttonA = vjoy.newButton("buttonA", "images/img_".. color .."/upbutton.png")
	buttonB = vjoy.newButton("buttonB", "images/img_".. color .."/downbutton.png")
	-- place the jump and bend buttons depending on the settings on file
	if buttonPlace == "right" then
		buttonA.x, buttonA.y = display.contentWidth*0.75, display.contentHeight*0.5
		buttonB.x, buttonB.y = display.contentWidth*0.25, display.contentHeight*0.5
	elseif buttonPlace == "left" then
		buttonB.xScale = -1
		buttonB.x, buttonB.y = display.contentWidth*0.75, display.contentHeight*0.5	
		buttonA.xScale = -1	
		buttonA.x, buttonA.y = display.contentWidth*0.25, display.contentHeight*0.5
	end
	-- text for score
	scoreText = display.newText( sceneGroup, "00000", display.contentWidth - 15, 10, "font/madness.ttf", 42 )
    scoreText.anchorX = 1
    scoreText.anchorY = 0
    scoreText:setFillColor( 0.4, 0.4, 0.4, 1 )
    -- text for blink the score
    scoreTextLit = display.newText( sceneGroup, "00000", display.contentWidth - 15, 10, "font/madness.ttf", 42 )
    scoreTextLit.anchorX = 1
    scoreTextLit.anchorY = 0
    scoreTextLit:setFillColor( 0.4, 0.4, 0.4, 1 )
    scoreTextLit.isVisible = false
	-- open the file to update the score
    loadHi()
    hiScore = classicHiScore or 0
	-- text for HIscore
	hiScoreText = display.newText( sceneGroup, hiScore, scoreText.contentBounds.xMin - 20, 10, "font/madness.ttf", 42 )
    hiScoreText.anchorX = 1
    hiScoreText.anchorY = 0
    hiScoreText:setFillColor( 0.6, 0.6, 0.6, 1 )
    if hiScore < 10 then
		hiScoreText.text = "HI   0000"..hiScore
	elseif hiScore < 100 then
		hiScoreText.text = "HI   000"..hiScore
	elseif hiScore < 1000 then
		hiScoreText.text = "HI   00"..hiScore
	elseif hiScore < 10000 then
		hiScoreText.text = "HI   0"..hiScore
	else
		hiScoreText.text = "HI   " ..hiScore
	end
	-- insert objects to sceneGroup
	sceneGroup:insert( map )
	sceneGroup:insert( buttonA )
	sceneGroup:insert( buttonB )
	-- create a group for the final
	finalGroup = display.newGroup()  
    sceneGroup:insert( finalGroup )
	-- -------------------------------------------------------------------------------
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		-- ----------------------------------------------------------------------------
		Runtime:addEventListener( "enterFrame", enterFrame )
		-- ----------------------------------------------------------------------------
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- ----------------------------------------------------------------------------
		
		-- ----------------------------------------------------------------------------
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		-- -----------------------------------------------------------------------------

		-- -----------------------------------------------------------------------------
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		-- -----------------------------------------------------------------------------
		physics.pause()
		composer.removeScene( "scenes.game2" )
		-- -----------------------------------------------------------------------------
	end
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	-- --------------------------------------------------------------------------------
	for s, v in pairs( self.sounds ) do  -- Release all audio handles
		audio.dispose( s )
		self.sounds[s] = nil
	end
	-- --------------------------------------------------------------------------------
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
