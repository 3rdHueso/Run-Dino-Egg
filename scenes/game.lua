
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- required libraries
local physics = require( "physics" )
local json = require( "json" )
local tiled = require( "modules.ponytiled" )
local eggCounter = require( "modules.mapextensions.eggCounter" )
local translations = require("modules.translations")
local appodeal = require( "plugin.appodeal" )

-- needed variables
local levelsOnFile 
local settingsOnFile = {}
local aux
local positioned = false
local aucont = 0
local language 
local color
local character
local soundsVol 
local buttonPlace 
local map, dino, fly, volcano, eggList, parallaxCloud, finalGroup
local buttonA, buttonB
local p100
local levelsfilePath = system.pathForFile( "levels.json", system.DocumentsDirectory )
local settingsfilePath = system.pathForFile( "settings.json", system.DocumentsDirectory )
local levelQuantity = composer.getVariable( "levels" )
local attempts
local percentage
local videoButton
local nextButton
local againButton
local menuButton
local availableDinos
local lockedDinos = 1
local allDinos = composer.getVariable( "allDinos" ) -----this is the max quantity of dinos 

-- preoload sounds
scene.sounds = {
	jump1 = audio.loadSound( "sounds/jump1.mp3" ),
	jump2 = audio.loadSound( "sounds/jump2.mp3" ),
	dead = audio.loadSound("sounds/dead.mp3"),
	eggSound = audio.loadSound("sounds/egg.mp3"),
	endSound = audio.loadSound("sounds/end.mp3")
}

-- get de composer variables saved in other scenes, since this scene is open but not showed in menu scene
local function loadSettings()
	language = composer.getVariable( "settedLanguage" )
	color = composer.getVariable( "settedColor" )
	soundsVol = composer.getVariable( "settedSoundsVol" )
	buttonPlace = composer.getVariable( "settedButtonPlace" )
	character = composer.getVariable( "settedCharacter" )
	aux = tonumber(character)
	availableDinos = composer.getVariable( "unlockedDinos" )
	-- save variable state to turn off or on the sound
	scene.sounds.state = soundsVol
	if scene.sounds.state == "ON" then
		audio.setVolume( 1 )
	else
		audio.setVolume( 0 )
	end
end

--hidethe baner when dino.running
function scene:hideAd()
	appodeal.hide( "banner" )
end

-- load the ad video and give an extra egg to the begining usin the event rewarddVideo completed
local function watchAd()
	videoButton:removeEventListener( "tap", watchAd )
	videoButton:removeSelf()
	videoButton = nil
	adText:removeSelf()
	adText = nil
	appodeal.show( "rewardedVideo" )
end

-- shows the video button if a video ad is loaded
local function showButtonAd()
	if videoEnabled == true then
		-- create and place the button
		local space = display.contentWidth * 0.25
		videoButton = display.newImageRect(finalGroup, "images/img_".. color .."/video.png", 70, 70)
		videoButton.x = space * 2
		videoButton.y = 100
		-- table options for the text under the button
		local options = {
    	parent = finalGroup,
    	text = translations["WatchAd"][language],
    	x = videoButton.x,
    	y = videoButton.contentBounds.yMax + 20,
    	font = "font/madness.ttf",
    	fontSize = 32,
    	width = 250,
    	align = "center"
		}
		-- create the text object
		adText = display.newText( options )
		adText.anchorY = 0
		adText:setFillColor( 0.4, 0.4, 0.4, 1 )
		-- add listener to the button
		videoButton:addEventListener( "tap", watchAd )
	end
end

-- function to check ads events 
function scene:adListener( event )
	-- Successful initialization of the Appodeal plugin
	if ( event.phase == "init" ) then
		print( "Appodeal event: initialization successful" )
	end
	-- An ad loaded successfully
	if ( event.phase == "loaded" ) then
		print( "Appodeal event: " .. tostring(event.type) .. " ad loaded successfully" )
		if event.type == "rewardedVideo" then
			videoEnabled = true
			print("videoEnabled: " .. tostring(videoEnabled))
		end
	end
	-- The ad was displayed/played
	if ( event.phase == "displayed" or event.phase == "playbackBegan" ) then
		print( "Appodeal event: " .. tostring(event.type) .. " ad displayed" )
		if event.type == "rewardedVideo" then
			videoEnabled = false
			print("videoEnabled: " .. tostring(videoEnabled))			
		end
	end
	-- The ad was closed/hidden
	if ( event.phase == "hidden" or event.phase == "closed" ) then
		print( "Appodeal event: " .. tostring(event.type) .. " ad closed/hidden" )	
		if event.type == "rewardedVideo" then		
			print("rewarded closed")
		end
	end
	-- The ad was completed
	if ( event.phase == "playbackEnded" ) then
		print( "Appodeal event: " .. tostring(event.type) .. " ad completed" )
		if event.type == "rewardedVideo" then		
			completed = true
			print("rewarded completed")
			print("completed: " .. tostring(completed))	
		end
	end	
	-- The user clicked/tapped an ad
	if ( event.phase == "clicked" ) then
		print( "Appodeal event: " .. tostring(event.type) .. " ad clicked/tapped" )
	end
	-- The ad failed to load
	if ( event.phase == "failed" ) then
		print( "Appodeal event: " .. tostring(event.type) .. " ad failed to load" )
	end
end

-- function to open file to read settings
local function loadFile()
	local file = io.open( settingsfilePath, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        settingsOnFile = json.decode( contents )
    end
end

-- function to open file to save settings, if it doesn't exist, create a new one
local function saveFile()
	local file = io.open( settingsfilePath, "w" )
    if file then
        file:write( json.encode( settingsOnFile ) )
        io.close( file )
    else
    	file = io.open( settingsfilePath, "w" )
    	file:write( json.encode( settingsOnFile ) )
        io.close( file )
    end
end

-- loads the already unlocked levels
local function loadLevels()
	local file = io.open( levelsfilePath, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        levelsOnFile = json.decode( contents )
    end
end

-- save the new unlocked level
local function saveLevels()
	local file = io.open( levelsfilePath, "w" )
    if file then
        file:write( json.encode( levelsOnFile ) )
        io.close( file )
    end
end

-- reload level or change to next after complete the current level
local function endGame(event)
	local name = event.target.name
	-- if the buttos exist, then remove the tap listeners
	if nextButton then
		nextButton:removeEventListener( "tap", endGame )
	end
	if againButton then
		againButton:removeEventListener( "tap", endGame ) 
	end
	if menuButton then
		menuButton:removeEventListener( "tap", endGame )
	end
	-- if next was pressed, chenge to next level with 0 eggs
	if name == "next" then
		if dino.level < levelQuantity then
			composer.gotoScene( "scenes.refresh", { params = { level = dino.level + 1, extraEgg = 0 } }  )
		else
			composer.gotoScene( "scenes.refresh", { params = { level = 1, extraEgg = 0 } }  )
		end
	end
	-- if again pressed, refresh the scene. if completed (from watch ad) is true, then reinitialize and refresh with +1 egg
	if name == "again" then
		if completed == true then
			completed = false
			composer.gotoScene( "scenes.refresh", { params = { level = dino.level, extraEgg = 1 } }  )
		else
			composer.gotoScene( "scenes.refresh", { params = { level = dino.level, extraEgg = 0 } }  )
		end
	end
	-- if menu was pressed, change to menu scene
	if name == "menu" then
		composer.gotoScene( "scenes.menu" )
	end
	--return
	return true
end

-- function to display the final elements when the level is completed or dino died, also remove listener for keys
local function endInfo()	
	--show a banner add
	appodeal.show( "banner", { yAlign="bottom" })
	-- remove the jump and bend buttons
	buttonA:removeSelf()
	buttonA = nil
	buttonB:removeSelf()
	buttonB = nil
	-- variable to calculate the possition of butons
	local dcw = display.contentWidth
	-- if dino dies only show two buttons and call shoeButtonAd()
	if dino.isDead then 
		local space = dcw * 0.25
		againButton = display.newImageRect(finalGroup, "images/img_".. color .."/again.png", 70, 70)
    	againButton.x = space
    	againButton.y = 100
    	againButton.name = "again"
    	menuButton = display.newImageRect(finalGroup, "images/img_".. color .."/menu.png", 70, 70)
    	menuButton.x = space * 3
    	menuButton.y = 100
    	menuButton.name = "menu"
    	againButton:addEventListener( "tap", endGame ) 
    	menuButton:addEventListener( "tap", endGame ) 
    	-- open the file to save the data, aux correspond to the character, i to the level
    	loadLevels()
    	local i = dino.level
		if levelsOnFile[aux][i].progress < percentage then
    		levelsOnFile[aux][i] = {unlocked = true, progress = percentage, attempts = attemptsG}
    	else
    		levelsOnFile[aux][i] = {unlocked = true, progress = levelsOnFile[aux][i].progress, attempts = attemptsG}
    	end
    	saveLevels()
    	-- function to show the video button
    	showButtonAd()
	else 
		--if dino complete the level, show three buttons and save the next level as unlocked
		local space = dcw * 0.25
		nextButton = display.newImageRect(finalGroup, "images/img_".. color .."/play.png", 70, 70)
    	nextButton.x = space
    	nextButton.y = 100
    	nextButton.name = "next"
		againButton = display.newImageRect(finalGroup, "images/img_".. color .."/again.png", 70, 70)
    	againButton.x = space * 2
    	againButton.y = 100
    	againButton.name = "again"
    	menuButton = display.newImageRect(finalGroup, "images/img_".. color .."/menu.png", 70, 70)
    	menuButton.x = space * 3
    	menuButton.y = 100 
    	menuButton.name = "menu"
    	nextButton:addEventListener( "tap", endGame )
		againButton:addEventListener( "tap", endGame ) 
		menuButton:addEventListener( "tap", endGame )
    	-- open the file to save the data
    	loadLevels()
    	if dino.level < levelQuantity then
    		local i = dino.level + 1
    		levelsOnFile[aux][i] = {unlocked = true, progress = 0, attempts = 0}
    		levelsOnFile[aux][i-1] = {unlocked = true, progress = percentage, attempts = attemptsG}
		else
			levelsOnFile[aux][dino.level] = {unlocked = true, progress = percentage, attempts = attemptsG}
    	end
    	saveLevels()
	end
	-- finalize the runtime listener key
    dino:endKeys()
    -- return group
    return finalGroup
end

-- Function to scroll the map
local function enterFrame( event )
	local elapsed = event.time
	-- Easy way to scroll a map based on a character
	if dino and dino.x and dino.y and not dino.isDead then
		-- counter for percentage of level
		percentage = math.floor((100 - 100*(volcano.x - dino.x)/p100)+0.5)
		if percentage > 100 then percentage = 100 end
		percentText.text = percentage.."%"
		-- Easy way to scroll a map based on a character
		if volcano.contentBounds.xMax > display.contentWidth then
			local x, y = dino:localToContent( 300, -50 )
			x = display.contentCenterX - x -- scrolls map in x
			map.x = map.x + x
			y = display.contentCenterY - y
			vx, vy = dino:getLinearVelocity()
			-- if the character gest positioned start the the key listener in dino
			if display.contentCenterY - y == 240 and aucont == 0 then
				aucont = aucont + 1
				if aucont == 1 then
					positioned = true
					dino:startKeys()
				end
			end
			if display.contentCenterY - y > 250 then -- if the character moves a lot in y, fall, or is landing, scroll the map in y
				map.y = map.y + 0.5*y
			end
			if not dino.jumping and vy == 0 then -- if the character moves a lot in y, fall, or is landing, scroll the map in y
				if positioned and display.contentCenterY - y < 245 and display.contentCenterY - y > 235 then
					--map.y = map.y
				elseif display.contentCenterY - y < 200 then
					map.y = map.y + 0.5*y
				else
					map.y = map.y + 0.5*y
				end	
			end
			-- Easy parallax
			if parallax then
				parallax.x =  -map.x / 2 --moves only in x
			end
		elseif dino.contentBounds.xMax >  volcano.contentBounds.xMax - 50 then -- if dino reach the goal (volcano)
			Runtime:removeEventListener( "enterFrame", enterFrame ) -- stops scrolling the map removing the runtime listener
			audio.play( scene.sounds.endSound )
			-- finalize all listeners and animations
			dino:finalize()
			for i = 1, #fly do 
				fly[i]:stopAnimation()
			end
			-- if dino also reach the cave, then unlock new dino
			if cave then
				if dino.contentBounds.xMax > cave.contentBounds.xMin and dino.contentBounds.yMin >= cave.contentBounds.yMin - 70 then
					local numCharacter = tonumber( character )
					if numCharacter == availableDinos and availableDinos < allDinos then
						availableDinos = availableDinos + 1
						loadFile()
						settingsOnFile["availableDinos"] = availableDinos
						saveFile()
					end
				end
			end
			-- call function to show buttons
			endInfo()
		end
	end
	if dino.isDead then -- when dino dies
		-- finalize all listeners and animations
		Runtime:removeEventListener( "enterFrame", enterFrame )
		dino:finalize()
		for i = 1, #fly do 
			fly[i]:stopAnimation()
		end
		-- call function to show buttons
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
	loadSettings()
	appodeal.show( "banner", { yAlign="bottom" })
	physics.start()
	physics.setGravity( 0, 120 )
	--physics.setDrawMode( "hybrid" )

	-- Load our level
	local level = event.params.level
	local extraEgg  = event.params.extraEgg
	local filename = "images/maps/".. color .."/dinomap" .. level .. ".json" or event.filename
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "images/maps/" .. color )

	-- Find our hero!
	map.extensions = "modules.mapextensions."
	map:extend( "dino" )
	dino = map:findObject( "dino" )
	dino.level = level

	-- Find our enemies and other items
	map:extend( "egg", "fly" ) --huevos y voladores (watch egg and fly lua files)
	fly = map:listTypes( "fly" ) -- obtain fly as a table of fly objects in the map
	map:extend( "enemyS", "enemyL" ) -- cactus (watch enemyS and enemyL lua files)
	-- Find cave
	cave = map:findObject( "cave" )
	-- Find volcano
	volcano = map:findObject( "volcano" )
	-- Find the parallax layer
	parallax = map:findLayer( "parallax" )
	-- Add our hearts(eggs) module
	eggList = eggCounter.new()
	eggList.x = 48
	eggList.y = display.screenOriginY + eggList.contentHeight / 2 + 16
	dino.eggList = eggList
	for i=1, extraEgg do
		eggList:heal(1)
	end
	-- get 100% long of level 
	p100 = volcano.x - dino.x
	-- text for percentage
	percentText = display.newText( sceneGroup, "0%", display.contentWidth - 15, 10, "font/madness.ttf", 42 )
    percentText.anchorX = 1
    percentText.anchorY = 0
    percentText:setFillColor( 0.4, 0.4, 0.4, 1 )
    -- open the file to update the attempts
    loadLevels()
    if levelsOnFile[aux][dino.level].progress < 100 then
    	attemptsG = levelsOnFile[aux][dino.level].attempts + 1
    else
    	attemptsG = levelsOnFile[aux][dino.level].attempts
    end
    -- text for attempts and number of level
	local attemptText = display.newText( sceneGroup, translations["Attempt"][language] .. " " .. attemptsG, display.contentCenterX, display.contentCenterY, "font/madness.ttf", 42 )
    attemptText:setFillColor( 0.4, 0.4, 0.4, 1 )
    dino.attempt = attemptText
    local levelText = display.newText( sceneGroup, translations["Level"][language] .. " " .. level, display.contentCenterX, attemptText.y - 40, "font/madness.ttf", 42 )
    levelText:setFillColor( 0.4, 0.4, 0.4, 1 )
    dino.leveltxt = levelText
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
	-- insert objects to sceneGroup
	sceneGroup:insert( map )
	sceneGroup:insert( eggList )
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
		composer.removeScene( "scenes.game" )
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
