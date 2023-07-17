
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- required libraries
local translations = require("modules.translations")

-- declare required variables
local color = composer.getVariable( "settedColor" )
local levelsButton
local nextButton
local language = composer.getVariable( "settedLanguage" )
local helpGroup1
local helpGroup2
local helpGroup3
local helpGroup4

-- change the scene
local function changeScene(event)
	local name = event.target.name
	levelsButton:removeEventListener("tap", changeScene)
	if name == "levelsButton" then
		composer.gotoScene( "scenes.menu" )
	end
end

-- change the images.x properties to desired position
local function toRightAgain(obj)
	obj.x = display.contentWidth
end

--move the images group
local function nextHelp()
	if helpGroup1.x == 0 then
		transition.to( helpGroup1, { time=400, x=-display.contentWidth, onComplete=toRightAgain } )
		transition.to( helpGroup2, { time=400, x=0} )
	end
	if helpGroup2.x == 0 then
		transition.to( helpGroup2, { time=400, x=-display.contentWidth, onComplete=toRightAgain } )
		transition.to( helpGroup3, { time=400, x=0} )
	end
	if helpGroup3.x == 0 then
		transition.to( helpGroup3, { time=400, x=-display.contentWidth, onComplete=toRightAgain } )
		transition.to( helpGroup4, { time=400, x=0} )
	end
	if helpGroup4.x == 0 then
		transition.to( helpGroup4, { time=400, x=-display.contentWidth, onComplete=toRightAgain } )
		transition.to( helpGroup1, { time=400, x=0} )
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

	-- create the background
	local background = display.newImageRect( sceneGroup, "images/img_".. color .."/menubackground.png" , 800, 480 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	-- create and insert the groups for help
	helpGroup4 = display.newGroup()  
    sceneGroup:insert( helpGroup4 )
    helpGroup3 = display.newGroup()  
    sceneGroup:insert( helpGroup3 )
    helpGroup2 = display.newGroup()  
    sceneGroup:insert( helpGroup2 )
	helpGroup1 = display.newGroup()  
    sceneGroup:insert( helpGroup1 )
	-- create the images and insert in respective groups
	local helpImage4 = display.newImageRect( helpGroup4, "images/help/".. color .."/help4.png" , 800, 480 )
	helpImage4.x = display.contentCenterX
	helpImage4.y = display.contentCenterY
	local helpImage3 = display.newImageRect( helpGroup3, "images/help/".. color .."/help3.png" , 800, 480 )
	helpImage3.x = display.contentCenterX
	helpImage3.y = display.contentCenterY
	local helpImage2 = display.newImageRect( helpGroup2, "images/help/".. color .."/help2.png" , 800, 480 )
	helpImage2.x = display.contentCenterX
	helpImage2.y = display.contentCenterY
	local helpImage1 = display.newImageRect( helpGroup1, "images/help/".. color .."/help1.png" , 800, 480 )
	helpImage1.x = display.contentCenterX
	helpImage1.y = display.contentCenterY
	-- create separator line
	local yL = 70
	local xM = display.contentWidth
	local separator_line = display.newLine( sceneGroup, 0, yL, xM, yL )
	separator_line:setStrokeColor( 0.4, 0.4, 0.4, 1 )
	separator_line.strokeWidth = 5
	-- create buttons and text
	levelsButton = display.newImageRect( sceneGroup, "images/img_".. color .."/menu.png" , 50, 50 )
	levelsButton.x = display.contentWidth - levelsButton.contentWidth
	levelsButton.y = yL * 0.5
	levelsButton.name = "levelsButton"
	nextButton = display.newImageRect( sceneGroup, "images/img_".. color .."/next.png" , 50, 50 )
	nextButton.x = levelsButton.x - levelsButton.contentWidth * 1.4
	nextButton.y = yL * 0.5
	nextButton.name = "helpButton"
	local helptext = display.newText( sceneGroup, translations["Help"][language], 10, yL*0.5, "font/madness.ttf", 70 )
    helptext.anchorX = 0
    helptext:setFillColor( 0.4, 0.4, 0.4, 1 )
    --text for help group 1
    local options = {
    	parent = helpGroup1,
    	text = translations["HelpTxt1"][language],
    	x = display.contentCenterX,
    	y = yL+20,
    	font = "font/madness.ttf",
    	fontSize = 44,
    	width = 400,
    	align = "center"
	}
    local helpguide1 = display.newText( options )
    helpguide1.anchorY = 0
    helpguide1:setFillColor( 0.4, 0.4, 0.4, 1 )
    --backgroun in order to read easily the text above
    local rectagle = display.newRect( helpGroup1, helpguide1.x, helpguide1.y, helpguide1.contentWidth, helpguide1.contentHeight  )
    if color == "white" then
    	rectagle:setFillColor( 1, 1, 1, 1 )
    elseif color == "black" then
    	rectagle:setFillColor( 0, 0, 0, 1 )
    end
    rectagle.anchorY = 0
    helpguide1:toFront()
    --text for help group 2
    local options = {
    	parent = helpGroup2,
    	text = translations["HelpTxt2"][language],
    	x = display.contentCenterX,
    	y = yL+20,
    	font = "font/madness.ttf",
    	fontSize = 44,
    	width = 400,
    	align = "center"
	}
    local helpguide2 = display.newText( options )
    helpguide2.anchorY = 0
    helpguide2:setFillColor( 0.4, 0.4, 0.4, 1 )
    --text for help group 3
    local options = {
    	parent = helpGroup3,
    	text = translations["HelpTxt3"][language],
    	x = display.contentCenterX,
    	y = yL+20,
    	font = "font/madness.ttf",
    	fontSize = 44,
    	width = 400,
    	align = "center"
	}
    local helpguide3 = display.newText( options )
    helpguide3.anchorY = 0
    helpguide3:setFillColor( 0.4, 0.4, 0.4, 1 )
    --text for help group 4
    local options = {
    	parent = helpGroup4,
    	text = translations["HelpTxt4"][language],
    	x = display.contentCenterX,
    	y = yL+20,
    	font = "font/madness.ttf",
    	fontSize = 44,
    	width = 400,
    	align = "center"
	}
    local helpguide4 = display.newText( options )
    helpguide4.anchorY = 0
    helpguide4:setFillColor( 0.4, 0.4, 0.4, 1 )
   	--update the group position to get off the screen
    helpGroup2.x = display.contentWidth
    helpGroup3.x = display.contentWidth
    helpGroup4.x = display.contentWidth
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
		nextButton:addEventListener("tap", nextHelp)
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
		composer.removeScene( "scenes.help" )
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
