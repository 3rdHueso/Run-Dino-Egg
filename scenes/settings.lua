
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- required libraries
local json = require( "json" )
local translations = require("modules.translations")

-- needed variables
local levelsButton
local thumbWhite
local thumbBlack
local languagetext
local left
local right
local soundstext
local leftSound
local rightSound
local eraseText
local switchText
local thumbUp
local thumbDown

-- load saved settings on file if exist to correspondant variables
local settingsOnFile = {}
local settingsfilePath = system.pathForFile( "settings.json", system.DocumentsDirectory )
local file = io.open( settingsfilePath, "r" )
if file then
    local contents = file:read( "*a" )
    io.close( file )
    settingsOnFile = json.decode( contents )
end
local color = settingsOnFile["colorScheme"] or composer.getVariable( "settedColor" ) 
local language = settingsOnFile["language"] or composer.getVariable( "settedLanguage" ) 
local soundsVol = settingsOnFile["soundsVol"] or composer.getVariable( "settedSoundsVol" ) 
local buttonPlace = settingsOnFile["placement"] or composer.getVariable( "settedButtonPlace" )
local character = settingsOnFile["dinosaur"] or composer.getVariable( "settedCharacter" )
local chId = tonumber(character)

-- function to open file to read settings
local function loadSettings()
	local file = io.open( settingsfilePath, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        settingsOnFile = json.decode( contents )
    end
end

-- function to open file to save settings, if it doesn't exist, create a new one
local function saveSettings()
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

-- function to change the scene to "menu" scene
local function changeScene(event)
	local name = event.target.name
	if name == "levelsButton" then
		composer.gotoScene( "scenes.menu" )
	end
end

-- save the selected color and refresh the scene to adquire the change
local function selectColor(event)
	thumb = event.target
	if thumb.name == "thumbWhite" then
		thumbWhite.stroke = { 1, 0, 0.5 }
		thumbWhite.strokeWidth = 4
		thumbBlack.stroke = { 1, 1, 1 }
		loadSettings()
		settingsOnFile["colorScheme"] = "white"
		saveSettings()
		composer.gotoScene( "scenes.refreshSett" )
	elseif thumb.name == "thumbBlack" then
		thumbBlack.stroke = { 1, 0, 0.5 }
		thumbBlack.strokeWidth = 4
		thumbWhite.stroke = { 1, 1, 1 }
		loadSettings()
		settingsOnFile["colorScheme"] = "black"
		saveSettings()
		composer.gotoScene( "scenes.refreshSett" )
	end
end

-- define the existent languages in the "translation.lua" file
local languages = {
	{"English", "en"},
	{"Español", "es"},
	--{"russian", "en"},
	--{"japanese", "en"},
}

-- define the position of defined language in the table "languages"
local langPos
for i=1, #languages do
	if translations["Language"][language] == languages[i][1] then
		langPos = i
	end
end

-- depending on the pressed button "right" or "left" change "langPos" to next or previous language
-- update the text showing the selected language
-- save the language on settings file
local function changeLanguage(event)
	levelsButton:removeEventListener("tap", changeScene)
	languagetext:removeEventListener("tap", changeLanguage)
	left:removeEventListener("tap", changeLanguage)
	right:removeEventListener("tap", changeLanguage)
	local a = #languages
	local name = event.target.name
	if name == "left" then
		langPos = langPos - 1
		if langPos < 1 then
			langPos = a
		end
		transition.from( languagetext, { time=300, x = display.contentWidth, onComplete=addLangListener } )
	elseif name == "right" then
		langPos = langPos + 1
		if langPos > a then
			langPos = 1
		end
		transition.from( languagetext, { time=300, x = 0, onComplete=addLangListener } )
	end
	languagetext.text = translations["Language"][languages[langPos][2]]
	settingstext.text = translations["Settings"][languages[langPos][2]]
	if soundsVol == "ON" then
		soundstext.text = translations["SoundOn"][languages[langPos][2]]
	elseif soundsVol == "OFF" then
		soundstext.text = translations["SoundOff"][languages[langPos][2]]
	end
	eraseText.text = translations["Erase"][languages[langPos][2]]
	switchText.text = translations["Switch"][languages[langPos][2]]
	loadSettings()
	buttonPlace = settingsOnFile["placement"]
	language = languages[langPos][2]
	settingsOnFile["language"] = language
	saveSettings()
	if buttonPlace == "right" then
		thumbUp.anchorX = 0
		thumbUp.x = switchText.contentBounds.xMax + 20
		thumbDown.anchorX = 1
		thumbDown.x = switchText.contentBounds.xMin - 20
	elseif buttonPlace == "left" then
		thumbDown.anchorX = 0
		thumbDown.x = switchText.contentBounds.xMax + 20
		thumbUp.anchorX = 1
		thumbUp.x = switchText.contentBounds.xMin - 20
	end
end

-- add listener for language buttons
function addLangListener()
	levelsButton:addEventListener("tap", changeScene)
	languagetext:addEventListener("tap", changeLanguage)
	left:addEventListener("tap", changeLanguage)
	right:addEventListener("tap", changeLanguage)
end

-- update the text showing the selected volume
-- save the volume on settings file
local function changeVol(event)
	levelsButton:removeEventListener("tap", changeScene)
	soundstext:removeEventListener("tap", changeVol)
	leftSound:removeEventListener("tap", changeVol)
	rightSound:removeEventListener("tap", changeVol)
	local name = event.target.name
	if soundsVol == "ON" then
		soundstext.text = translations["SoundOff"][language]
		soundsVol = "OFF"
	elseif soundsVol == "OFF" then
		soundstext.text = translations["SoundOn"][language]
		soundsVol = "ON"
	end
	if name == "left" then
		transition.from( soundstext, { time=300, x = display.contentWidth, onComplete=addVolListener } )
	elseif name == "right" then
		transition.from( soundstext, { time=300, x = 0, onComplete=addVolListener } )
	end
	loadSettings()
	settingsOnFile["soundsVol"] = soundsVol
	saveSettings()
end

-- add listeners to volume buttons
function addVolListener()
	levelsButton:addEventListener("tap", changeScene)
	soundstext:addEventListener("tap", changeVol)
	leftSound:addEventListener("tap", changeVol)
	rightSound:addEventListener("tap", changeVol)
end

-- loads the already unlocked levels
local levelsfilePath = system.pathForFile( "levels.json", system.DocumentsDirectory )
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

-- loads the classic game hiscore
local classicHifilePath = system.pathForFile( "classicHi.json", system.DocumentsDirectory )
local function loadClassicScore()
	local file = io.open( classicHifilePath, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        classicHiScore = json.decode( contents )
    end
end

-- save the classic game hiscore
local function saveClassicScore()
	local file = io.open( classicHifilePath, "w" )
    if file then
        file:write( json.encode( classicHiScore ) )
        io.close( file )
    end
end

-- erase the unlocked levels and progresa and attempts data
local function eraseData(event)
	if ( event.action == "clicked" ) then
        local i = event.index
        if ( i == 1 ) then
        	--open the file for levels, update the values with zeros, save the file 
            loadLevels()
			for i=1, #levelsOnFile[chId] do
				levelsOnFile[chId][i] = {unlocked = true, progress = 0, attempts = 0} --false to erase and lock, true to unlock all
			end
			levelsOnFile[chId][1] = {unlocked = true, progress = 0, attempts = 0}
			saveLevels()
			--open the file for HIScore, update and save
			loadClassicScore()
			classicHiScore = 0  
    		saveClassicScore()
    		--change the scene
			composer.gotoScene( "scenes.menu" )
		else
			eraseText:addEventListener("tap", myAlert)
        end
    end
end

-- show up a msg before continua to erase the data
function myAlert()
	eraseText:removeEventListener("tap", myAlert)
	local alert = native.showAlert( translations["Erase"][language], translations["Erase Warning"][language], { translations["Continue"][language], translations["Cancel"][language] }, eraseData )
end

-- change the sides of jump and bend buttons 
local function changeButtons()
	levelsButton:removeEventListener("tap", changeScene)
	switchText:removeEventListener("tap", changeButtons)
	local upPlaceHolder = thumbUp.x
	local downPlaceHolder = thumbDown.x
	local anchorHolder = thumbUp.anchorX
	local aux1
	local aux2
	local placement
	-- asign variables corresponding to the sides
	if anchorHolder == 1 then
		aux1 = 1
		aux2 = 0
		placement = "right"
	elseif anchorHolder == 0 then
		aux1 = 0
		aux2 = 1
		placement = "left"
	end	
	-- move the elements to the holder variables
	transition.to(thumbUp, { time=200, x=downPlaceHolder, anchorX = aux2, })
	transition.to(thumbDown, { time=200, x=upPlaceHolder, anchorX = aux1, onComplete=addListener })
	--open the file and save the new placement of buttons
	loadSettings()
	settingsOnFile["placement"] = placement
	saveSettings()
end

-- add listener again to the switch text and menu buttons
function addListener()
	switchText:addEventListener("tap", changeButtons)
	levelsButton:addEventListener("tap", changeScene)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- -------------------------------------------------------------------------------
	-- create the background
	local background = display.newImageRect( sceneGroup, "images/img_".. color .."/menubackground.png" , 800, 480 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	-- create the separator line
	local yL = 70
	local xM = display.contentWidth
	local separator_line = display.newLine( sceneGroup, 0, yL, xM, yL )
	separator_line:setStrokeColor( 0.4, 0.4, 0.4, 1 )
	separator_line.strokeWidth = 5
	-- create the button to return to levels (menu)
	levelsButton = display.newImageRect( sceneGroup, "images/img_".. color .."/menu.png" , 50, 50 )
	levelsButton.x = display.contentWidth - levelsButton.contentWidth
	levelsButton.y = yL * 0.5
	levelsButton.name = "levelsButton"
	-- create the both thumbs showing the color and add a stroke depending on the selected color
	thumbWhite = display.newImageRect( sceneGroup, "images/settings/miniwhite.png" , 100, 70 )
	thumbWhite.x = display.contentCenterX - thumbWhite.contentWidth * 0.6
	thumbWhite.y = yL * 1.9
	thumbWhite.name = "thumbWhite"
	thumbBlack = display.newImageRect( sceneGroup, "images/settings/miniblack.png" , 100, 70 )
	thumbBlack.x = display.contentCenterX + thumbBlack.contentWidth * 0.6
	thumbBlack.y = yL * 1.9
	thumbBlack.name = "thumbBlack"
	--show the selected color depending on setting color
	if color == "white" then
		thumbWhite.stroke = { 1, 0, 0.5 }
		thumbWhite.strokeWidth = 4
	elseif color == "black" then
		thumbBlack.stroke = { 1, 0, 0.5 }
		thumbBlack.strokeWidth = 4
	end
	-- create the title text
	settingstext = display.newText( sceneGroup, translations["Settings"][language], 10, yL*0.5, "font/madness.ttf", 70 )
    settingstext.anchorX = 0
    settingstext:setFillColor( 0.4, 0.4, 0.4, 1 )
    -- create all text for language option 
    languagetext = display.newText( sceneGroup, translations["Language"][language], display.contentCenterX, thumbBlack.contentBounds.yMax + 40, "font/madness.ttf", 44 )
    languagetext:setFillColor( 0.4, 0.4, 0.4, 1 )
    languagetext.name = "right"
    left = display.newText( sceneGroup, "<", languagetext.contentBounds.xMin-20, languagetext.y, "font/madness.ttf", 60 )
    left:setFillColor( 0.4, 0.4, 0.4, 1 )
    left.name = "left"
    right = display.newText( sceneGroup, ">", languagetext.contentBounds.xMax+20, languagetext.y, "font/madness.ttf", 60 )
    right:setFillColor( 0.4, 0.4, 0.4, 1 )
    right.name = "right"
    -- create all text for volume option
    if soundsVol == "ON" then
   		soundstext = display.newText( sceneGroup, translations["SoundOn"][language], display.contentCenterX, languagetext.contentBounds.yMax + 40, "font/madness.ttf", 44 )
    elseif soundsVol == "OFF" then
      	soundstext = display.newText( sceneGroup, translations["SoundOff"][language], display.contentCenterX, languagetext.contentBounds.yMax + 40, "font/madness.ttf", 44 )
    end
    soundstext:setFillColor( 0.4, 0.4, 0.4, 1 )
    soundstext.name = "right"
    leftSound = display.newText( sceneGroup, "<", soundstext.contentBounds.xMin-20, soundstext.y, "font/madness.ttf", 60 )
    leftSound:setFillColor( 0.4, 0.4, 0.4, 1 )
    leftSound.name = "left"
    rightSound = display.newText( sceneGroup, ">", soundstext.contentBounds.xMax+20, soundstext.y, "font/madness.ttf", 60 )
    rightSound:setFillColor( 0.4, 0.4, 0.4, 1 )
    rightSound.name = "right"
    -- create the "erase data" text
	eraseText = display.newText( sceneGroup, translations["Erase"][language], display.contentCenterX, soundstext.contentBounds.yMax + 40, "font/madness.ttf", 44 )
    eraseText:setFillColor( 0.4, 0.4, 0.4, 1 )
    -- create the switch buttons text and thumb images for buttons
    switchText = display.newText( sceneGroup, translations["Switch"][language], display.contentCenterX, eraseText.contentBounds.yMax + 40, "font/madness.ttf", 44 )
    switchText:setFillColor( 0.4, 0.4, 0.4, 1 )
    thumbUp = display.newImageRect( sceneGroup, "images/settings/thumbupbutton.png" , 90, 40 )
	thumbDown = display.newImageRect( sceneGroup, "images/settings/thumbdownbutton.png" , 90, 40 )
	if buttonPlace == "right" then
		thumbUp.anchorX = 0
		thumbUp.x = switchText.contentBounds.xMax + 20
		thumbUp.y = switchText.y
		thumbDown.anchorX = 1
		thumbDown.x = switchText.contentBounds.xMin - 20
		thumbDown.y = switchText.y
	elseif buttonPlace == "left" then
		thumbDown.anchorX = 0
		thumbDown.x = switchText.contentBounds.xMax + 20
		thumbDown.y = switchText.y
		thumbUp.anchorX = 1
		thumbUp.x = switchText.contentBounds.xMin - 20
		thumbUp.y = switchText.y
	end
	-- -------------------------------------------------------------------------------
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		-- ----------------------------------------------------------------------------

		-- ----------------------------------------------------------------------------
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- ----------------------------------------------------------------------------
		levelsButton:addEventListener("tap", changeScene)
		thumbBlack:addEventListener("tap", selectColor)
		thumbWhite:addEventListener("tap", selectColor)
		languagetext:addEventListener("tap", changeLanguage)
		left:addEventListener("tap", changeLanguage)
		right:addEventListener("tap", changeLanguage)
		soundstext:addEventListener("tap", changeVol)
		leftSound:addEventListener("tap", changeVol)
		rightSound:addEventListener("tap", changeVol)
		eraseText:addEventListener("tap", myAlert)
		switchText:addEventListener("tap", changeButtons)
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
		composer.removeScene( "scenes.settings" )
		-- -----------------------------------------------------------------------------
	end
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	-- --------------------------------------------------------------------------------

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
