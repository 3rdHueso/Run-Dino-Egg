
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local json = require( "json" )
local translations = require("modules.translations") 

local color = composer.getVariable( "settedColor" )
local language = composer.getVariable( "settedLanguage" )
local levelsButton
local facebookButton
local twitterButton
local logoutTextBtn
local overallProgress = composer.getVariable( "overall" )
local overallAttempts = composer.getVariable( "attempts" )
local logouttm
local btntm
local dino = {}
local indx 
local settingsfilePath = system.pathForFile( "settings.json", system.DocumentsDirectory )

-- load saved settings on file if exist to correspondant variables
local settingsOnFile = {}
local settingsfilePath = system.pathForFile( "settings.json", system.DocumentsDirectory )
local file = io.open( settingsfilePath, "r" )
if file then
    local contents = file:read( "*a" )
    io.close( file )
    settingsOnFile = json.decode( contents )
end
local userCharacter = settingsOnFile["dinosaur"] or composer.getVariable( "settedCharacter" )
local availableDinos = settingsOnFile["availableDinos"] or composer.getVariable( "unlockedDinos" )

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

--return to menu scene
local function changeScene(event)
	levelsButton:removeEventListener("tap", changeScene)
	local name = event.target.name
	if name == "levelsButton" then
		composer.gotoScene( "scenes.menu" )
	end
end

local function changeDino(event)
	levelsButton:removeEventListener("tap", changeScene)
	if left.isVisible then
		leftRectangle:removeEventListener("tap", changeDino)
	end
	if right.isVisible then
		rightRectangle:removeEventListener("tap", changeDino)
	end

	local a = #dino
	local name = event.target.name
	if name == "left" then
		transition.to( dino[indx], { time=300, x = -200 } )
		indx = indx + 1
		if indx > a then
			indx = 1
		end
		transition.to( dino[indx], { time=300, x = display.contentCenterX + 10, onComplete=checkLeftRightButton } )
	elseif name == "right" then
		transition.to( dino[indx], { time=300, x = display.contentWidth + 200 } )
		indx = indx - 1
		if indx < 1 then
			indx = a
		end
		transition.to( dino[indx], { time=300, x = display.contentCenterX + 10, onComplete=checkLeftRightButton } )
	end
end

function checkLeftRightButton()
	levelsButton:addEventListener("tap", changeScene)

	loadSettings()
	settingsOnFile["dinosaur"] = tostring(indx)
	saveSettings()

	if indx == 1 then
		left.isVisible = true
		right.isVisible = false
		leftRectangle:addEventListener("tap", changeDino)
	elseif indx == #dino then
		left.isVisible = false
		right.isVisible = true
		rightRectangle:addEventListener("tap", changeDino)
	else
		left.isVisible = true
		right.isVisible = true
		leftRectangle:addEventListener("tap", changeDino)
		rightRectangle:addEventListener("tap", changeDino)
	end
	if availableDinos == 1 then
		left.isVisible = false
		right.isVisible = false
		message.isVisible = true
	else
		message.isVisible = false
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
	-- scene display objects
	local background = display.newImageRect( sceneGroup, "images/img_".. color .."/menubackground.png" , 800, 480 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	--separator
	local yL = 70
	local xM = display.contentWidth
	local separator_line = display.newLine( sceneGroup, 0, yL, xM, yL )
	separator_line:setStrokeColor( 0.4, 0.4, 0.4, 1 )
	separator_line.strokeWidth = 5
	-- scene button and text
	levelsButton = display.newImageRect( sceneGroup, "images/img_".. color .."/menu.png" , 50, 50 )
	levelsButton.x = display.contentWidth - levelsButton.contentWidth
	levelsButton.y = yL * 0.5
	levelsButton.name = "levelsButton"
	local infotext = display.newText( sceneGroup, translations["Character"][language], 10, yL*0.5, "font/madness.ttf", 70 )
    infotext.anchorX = 0
    infotext:setFillColor( 0.4, 0.4, 0.4, 1 )

    -- available dinos to select
    indx = tonumber(userCharacter)
    for i = 1, availableDinos do
    	dino[i] = display.newImageRect( sceneGroup, "images/maps/".. color .."/dino" .. tostring(i) .. ".png" , 350, 300 )
    	dino[i].y = yL * 3.5
    	if i < indx then
    		dino[i].x = -200
    	end
    	if i > indx then
    		dino[i].x = display.contentWidth + 200
    	end
    	if i == indx then
    		dino[i].x = display.contentCenterX + 10
    	end
    end    

	-- right, left buttons
	left = display.newText( sceneGroup, "<", dino[indx].contentBounds.xMin-20, dino[indx].y, "font/madness.ttf", 90 )
    left:setFillColor( 0.4, 0.4, 0.4, 1 )
    left.isVisible = false
    leftRectangle = display.newRect( sceneGroup, left.x, left.y, 80, 80 )
    leftRectangle:setFillColor(1, 1, 1)
    leftRectangle.name = "left"
    left:toFront()
    leftRectangle:toBack()

    right = display.newText( sceneGroup, ">", dino[indx].contentBounds.xMax+20, dino[indx].y, "font/madness.ttf", 90 )
    right:setFillColor( 0.4, 0.4, 0.4, 1 )
    right.isVisible = false
    rightRectangle = display.newRect( sceneGroup, right.x, right.y, 80, 80 )
    rightRectangle:setFillColor(1, 1, 1)
    rightRectangle.name = "right"
    right:toFront()
    rightRectangle:toBack()

    --informative text
    message = display.newText( sceneGroup, translations["CharacterMessage"][language], display.contentCenterX, yL*5.5, "font/madness.ttf", 70 )
    message:setFillColor( 0.4, 0.4, 0.4, 1 )
    message.isVisible = false

    --to the function to show and enable buttons
    checkLeftRightButton()
   
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
		-- add listener to return to menu
		--levelsButton:addEventListener("tap", changeScene)
		--left:addEventListener("tap", changeDino)
		--right:addEventListener("tap", changeDino)
		
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
		--remove the scene
		composer.removeScene( "scenes.charSelection" )
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
