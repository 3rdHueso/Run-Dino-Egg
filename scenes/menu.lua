
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- required libraries
local widget = require( "widget" )
local json = require( "json" )
local translations = require("modules.translations")
local appodeal = require( "plugin.appodeal" )

-- needed variables
local defaultLevels = 
{
	[1] = 
	{
		[1] = {},
	},

	[2] = -- one per each dino added to the project
	{
		[1] = {},
	},

	[3] = 
	{
		[1] = {},
	},

	[4] = 
	{
		[1] = {},
	},

	[5] = 
	{
		[1] = {},
	},

	[6] = 
	{
		[1] = {},
	},

	[7] = 
	{
		[1] = {},
	},

	[8] = 
	{
		[1] = {},
	},

	[9] = 
	{
		[1] = {},
	},

	[10] = 
	{
		[1] = {},
	},
}

local scrollView
local rows = 5
local columns = 4
local despX = 0
local despY = 175
local niv = 0
local numberFrame = {}
local classicFrame
local posF
local last
local infoButton
local helpButton
local settingsButton
local characterButton
local userColor
local userLanguage
local userCharacter
local numLevels = rows*columns
composer.setVariable( "levels", numLevels)
local allDinos = 5 --this is the max quantity of dinos. check dino.lua to add a new dino density
composer.setVariable( "allDinos", allDinos )

-- open the file which contains the settings
local settingsfilePath = system.pathForFile( "settings.json", system.DocumentsDirectory )
local fileS = io.open( settingsfilePath, "r" )
if fileS then
    local contents = fileS:read( "*a" )
    io.close( fileS )
    settingsOnFile = json.decode( contents )

    userColor = settingsOnFile["colorScheme"]
    userLanguage = settingsOnFile["language"]
    userSoundsVol = settingsOnFile["soundsVol"]
    userButtonPlace = settingsOnFile["placement"]
    userCharacter = settingsOnFile["dinosaur"]
    userUnlockedDinos = settingsOnFile["availableDinos"]
end

--[[
format of settings.json :
settings =
{
	["colorScheme"] = "white",
	["language"] = "en",
	["soundsVol"] = "ON",
	["placement"] = "right",
	["dinosaur"] = "1",
	["availableDinos"] = 1,
}
]]

-- default values for settings members and set their global variables
local defaultColor = "white"
local color = userColor or defaultColor
composer.setVariable( "settedColor", color)
local defaultLanguage = "en"
local language = userLanguage or defaultLanguage
composer.setVariable( "settedLanguage", language)
local defaultSoundsVol = "ON"
local soundsVol = userSoundsVol or defaultSoundsVol
composer.setVariable( "settedSoundsVol", soundsVol)
local defaultButtonPlace = "right"
local buttonPlace = userButtonPlace or defaultButtonPlace
composer.setVariable( "settedButtonPlace", buttonPlace)
local defaultCharacter = "1"
local character = userCharacter or defaultCharacter
composer.setVariable( "settedCharacter", character)
local defaulAvailableDinos = 1
local availableDinos = userUnlockedDinos or defaulAvailableDinos
composer.setVariable( "unlockedDinos", availableDinos )

-- open the file which contains the unlocked levels
local levelsfilePath = system.pathForFile( "levels.json", system.DocumentsDirectory )
local file = io.open( levelsfilePath, "r" )
if file then
    local contents = file:read( "*a" )
    io.close( file )
    levelsOnFile = json.decode( contents )
end

-- default values for levels (only first unlocked), then set unlockedlevels variable
local chId = tonumber(character)
for i=1, rows*columns do
	if i == 1 then
		defaultLevels[chId][i] = {unlocked = true, progress = 0, attempts = 0}
	else
		defaultLevels[chId][i] = {unlocked = false, progress = 0, attempts = 0}
	end
end
local unlockedLevels = levelsOnFile or defaultLevels

-- when new dino is unlocked, there is no reference to it in table (nil), therefore the 'for' create the elements, then save this
if unlockedLevels[chId][1].unlocked == nil then
	for i=1, rows*columns do
		if i == 1 then
			unlockedLevels[chId][i] = {unlocked = true, progress = 0, attempts = 0}
		else
			unlockedLevels[chId][i] = {unlocked = false, progress = 0, attempts = 0}
		end
	end
	-- save the items just added
	local file = io.open( levelsfilePath, "w" )
	if file then
	    file:write( json.encode( unlockedLevels ) )
	    io.close( file )
	else
		file = io.open( levelsfilePath, "w" )
		file:write( json.encode( unlockedLevels ) )
	    io.close( file )
	end
end

-- save the initial levels settings (from defaul values before)
local levelsfilePath = system.pathForFile( "levels.json", system.DocumentsDirectory )
local file = io.open( levelsfilePath, "w" )
if file then
    file:write( json.encode( unlockedLevels ) )
    io.close( file )
else
	file = io.open( levelsfilePath, "w" )
	file:write( json.encode( unlockedLevels ) )
    io.close( file )
end

-- preload scenes to call adListener function in other scenes when ads are initialized
local preloadScene = composer.loadScene( "scenes.game", true )
local sceneGame = composer.getScene( "scenes.game" )

--function to get an pass the events from appodeal
local function prim(event)
	appodealEvent = event
	sceneGame:adListener(appodealEvent)
end

-- Appodeal APPKEY and initialization
local appKey
if ( system.getInfo("platformName") == "Android" ) then  -- Android
	appKey = "2942f78d014d9e9ea4a7a73791a0a896d614951b8eba3da4"
elseif ( system.getInfo("platformName") == "iPhone OS" ) then  --iOS
	appKey = "[IOS-APP-KEY]"
end
appodeal.init( prim, { appKey=appKey, testMode=false, supportedAdTypes = {"banner", "rewardedVideo"} } )

-- function to change the scene to "game" level
local function toLevel(event)
	for i = 1, #unlockedLevels[chId] do
		if unlockedLevels[chId][i].unlocked then
			numberFrame[i]:removeEventListener("tap", toLevel)
		end
	end
	composer.gotoScene( "scenes.game", { time=300, effect="crossFade", params = {level = event.target.pos, extraEgg = 0 } } )
	return true
end

-- function to change the scene to "info", "help", "settings" or "classic game"
local function changeScene(event)
	settingsButton:removeEventListener("tap", changeScene)
	helpButton:removeEventListener("tap", changeScene)
	infoButton:removeEventListener("tap", changeScene)
	characterButton:removeEventListener("tap", changeScene)
	local name = event.target.name
	if name == "infoButton" then
		composer.gotoScene( "scenes.info" )
	end
	if name == "helpButton" then
		composer.gotoScene( "scenes.help" )
	end
	if name == "settingsButton" then
		composer.gotoScene( "scenes.settings" )
	end
	if name == "characterButton" then
		composer.gotoScene( "scenes.charSelection" )
	end
	if name == "classicFrame" then
		composer.gotoScene( "scenes.game2" )
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
	
	-- create background
	local background = display.newImageRect( sceneGroup, "images/img_".. color .."/menubackground.png" , 800, 480 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	-- create the scrollview
	scrollView = widget.newScrollView(
    	{
       		top = 70,
        	left = 0,
        	width = display.contentWidth,
        	height = display.contentHight,
        	scrollHeight = 100,
        	horizontalScrollDisabled = true,
        	hideScrollBar = true,
        	hideBackground = true,
    	}
	)
	sceneGroup:insert( scrollView )
	-- lonely classic level
	classicFrame = display.newImageRect( "images/menu/numberFrame.png" , 140, 140 )
	classicFrame.x = display.contentCenterX
	classicFrame.y = 135
	classicFrame.name = "classicFrame"
	scrollView:insert( classicFrame )
	local classictext = display.newText(  translations["Classic"][language], classicFrame.x, classicFrame.y, "font/madness.ttf", 35 )
	scrollView:insert( classictext )
	classictext:setFillColor( 0.4, 0.4, 0.4, 1 )
	-- create the level number and insert into scrollview
	for i = 1, rows do
		for j = 1, columns do
			local indx = j + niv
			local dir = "images/menu/numberFrame.png" or "numberFrame.png"
			numberFrame[indx] = display.newImageRect( dir , 140, 140 )
			scrollView:insert( numberFrame[indx] )
			numberFrame[indx].x = 135 + despX
			numberFrame[indx].y = 135 + despY
			numberFrame[indx].pos = indx
			numberFrame[indx]:setFillColor(0.3,0.3,0.3)
			local numtext = display.newText(  indx, numberFrame[indx].x, numberFrame[indx].y, "font/madness.ttf", 60 )
			scrollView:insert( numtext )
			numtext:setFillColor( 0.4, 0.4, 0.4, 1 )
			despX = despX + 175
			if j == columns then
				despX = 0
			end
		end
		despY = despY + 175
		niv = niv + 4
	end
	-- add color and listener "tap" to unlocked levels and calculate progress and attempts
	local progressSum = 0
	local attemptSum = 0
	for i = 1, #unlockedLevels[chId] do
		if unlockedLevels[chId][i].unlocked then
			numberFrame[i]:setFillColor(1,1,1)
			numberFrame[i]:addEventListener("tap", toLevel)
    		progressText = display.newText( sceneGroup, translations["Progress"][language]..": "..unlockedLevels[chId][i].progress .. "%", numberFrame[i].x, numberFrame[i].y - 57, "font/madness.ttf", 24 )
    		progressText:setFillColor( 0.4, 0.4, 0.4, 1 )
    		scrollView:insert( progressText )
    		progressSum = progressSum + unlockedLevels[chId][i].progress
    		attemptText = display.newText( sceneGroup, translations["Attempts"][language]..": "..unlockedLevels[chId][i].attempts, numberFrame[i].x, numberFrame[i].y + 57, "font/madness.ttf", 24 )
    		attemptText:setFillColor( 0.4, 0.4, 0.4, 1 )
    		scrollView:insert( attemptText )
    		attemptSum = attemptSum + unlockedLevels[chId][i].attempts
    		posF = numberFrame[i].y - (1.75*175)
    		last = i
		end
	end
	overallProgress = progressSum/numLevels
	composer.setVariable( "overall", overallProgress)
	composer.setVariable( "attempts", attemptSum)
	-- auto scrol to last unlocked level
	if last > 8 then
		scrollView:scrollToPosition( {y=-posF, time=0} )
	end
	-- create separator line
	local yL = scrollView.contentBounds.yMin
	local xM = display.contentWidth
	local separator_line = display.newLine( sceneGroup, 0, yL, xM, yL )
	separator_line:setStrokeColor( 0.4, 0.4, 0.4, 1 )
	separator_line.strokeWidth = 5
	-- create the buttons and text
	infoButton = display.newImageRect( sceneGroup, "images/img_".. color .."/share.png" , 50, 50 )
	infoButton.x = display.contentWidth - infoButton.contentWidth
	infoButton.y = yL * 0.5
	infoButton.name = "infoButton"
	helpButton = display.newImageRect( sceneGroup, "images/img_".. color .."/help.png" , 50, 50 )
	helpButton.x = infoButton.x - helpButton.contentWidth * 1.4
	helpButton.y = yL * 0.5
	helpButton.name = "helpButton"
	settingsButton = display.newImageRect( sceneGroup, "images/img_".. color .."/settings.png" , 50, 50 )
	settingsButton.x = helpButton.x - settingsButton.contentWidth * 1.4
	settingsButton.y = yL * 0.5
	settingsButton.name = "settingsButton"
	characterButton = display.newImageRect( sceneGroup, "images/img_".. color .."/head.png" , 50, 50 )
	characterButton.x = settingsButton.x - characterButton.contentWidth * 1.4
	characterButton.y = yL * 0.5
	characterButton.name = "characterButton"
	menutext = display.newText( sceneGroup, translations["Menu"][language], 10, yL*0.5, "font/madness.ttf", 70 )
    menutext.anchorX = 0
    menutext:setFillColor( 0.4, 0.4, 0.4, 1 )
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
		scrollView:setScrollHeight( numberFrame[#numberFrame].y + 220 )
		classicFrame:addEventListener("tap", changeScene)
		settingsButton:addEventListener("tap", changeScene)
		helpButton:addEventListener("tap", changeScene)
		infoButton:addEventListener("tap", changeScene)
		characterButton:addEventListener("tap", changeScene)
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
		composer.removeScene( "scenes.menu" )
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
