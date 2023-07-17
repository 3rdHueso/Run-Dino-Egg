
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local translations = require("modules.translations")
local facebook = require("plugin.facebook.v4a")
local socket = require("socket") 

local color = composer.getVariable( "settedColor" )
local language = composer.getVariable( "settedLanguage" )
local character = composer.getVariable( "settedCharacter" )
local levelsButton
local facebookButton
local logoutTextBtn
local overallProgress = composer.getVariable( "overall" )
local overallAttempts = composer.getVariable( "attempts" )
local picLink
local dinoName
local textField = nil
local messagetoPost
local rectangle
local FBstatusText
local workingText
local predeterminedBtn
local predeterminedTxt

-- State variables for Facebook commands we're executing
local requestedFBCommand
local commandProcessedByFB

-- Facebook commands
local LOGIN = 0
local POST_LINK = 1
local LOGOUT = 2

--set the img link and dino name depending on the character
if character == "1" then
	dinoName = "T-Rex"
	picLink = "https://imgur.com/lYR7z1Q.png"
elseif character == "2" then
	dinoName = "Velociraptor"
	picLink = "https://imgur.com/LxjHb0C.png"
elseif character == "3" then
	dinoName = "Allosaurus"
	picLink = "https://imgur.com/vjI9wzD.png"
elseif character == "4" then
	dinoName = "Spinosaurus"
	picLink = "https://imgur.com/qIn7mgY.png"
elseif character == "5" then
	dinoName = "Compsognathus"
	picLink = "https://imgur.com/yeIJcrS.png"
end

-- return to scenes menu
local function changeScene()
	levelsButton:removeEventListener("tap", changeScene)
	--local name = event.target.name
	--textField:removeSelf()
	--textField = nil
	print("textField isVisible = " .. tostring(textField.isVisible))
	--local function change()
		if textField.isVisible then
			print("textField isVisible TRUE")
			textField:removeSelf()
			textField = nil

			local function change()
				composer.gotoScene( "scenes.menu" )
			end

			timer.performWithDelay(30, change)
			--composer.gotoScene( "scenes.menu" )
		else 
			print("textField isVisible FALSE")
			changeScene()
			--return 
		end
	--end
	--timer.performWithDelay(50, change)
end

-- Check for an item inside the provided table
local function valueInTable( t, item )
	for k,v in pairs( t ) do
		if v == item then
			return true
		end
	end
	return false
end

-- Runs the desired Facebook command
local function processFBCommand()

	if requestedFBCommand == POST_LINK then

		local attachment = {
			name = "Run Dino Egg",
			link = "https://play.google.com/store/apps/details?id=com.yahoo.pablo_cabrera.ing.easylazyugly.notdinochrome",
			caption = translations["FBCaption"][language],
			description = translations["FBCaption"][language],
			picture = picLink,
			message = messagetoPost,
		}
		response = facebook.request( "me/feed", "POST", attachment )
		--print("mensaje: " .. message)
	end
end

local function needPublishActionsPermission()
	return requestedFBCommand ~= LOGIN
		and requestedFBCommand ~= LOGOUT
end

local function enforceFacebookLoginAndPermissions()
	if facebook.isActive then
		local accessToken = facebook.getCurrentAccessToken()
		if accessToken == nil then
			print( "Need to log in!" )
			facebook.login()
		-- Get publish_actions permission only if we're not getting user info or issuing a game request
		elseif needPublishActionsPermission() and not valueInTable( accessToken.grantedPermissions, "publish_actions" ) then
			print( "Logged in, but need 'publish_actions' permission" )
			facebook.login( { "publish_actions" } )
		else
			print( "Already logged in with necessary permissions" )
			processFBCommand()
		end
	else
		print( "Please wait for facebook to finish initializing before checking the current access token" );
	end
end

local function checkFBStatus()
	if facebook.isActive then
		local accessToken = facebook.getCurrentAccessToken()
		if accessToken == nil then
			FBstatusText.text = translations["Login"][language]
			--checkFBStatus()
		-- Get publish_actions permission only if we're not getting user info or issuing a game request
		elseif needPublishActionsPermission() and not valueInTable( accessToken.grantedPermissions, "publish_actions" ) then
			FBstatusText.text = translations["Login"][language]
			--checkFBStatus()
		else
			FBstatusText.text = translations["Share"][language]
			--checkFBStatus()
		end
	else
		print( "Please wait for facebook to finish initializing before checking the current access token" );
		FBstatusText.text = translations["Connecting"][language]
		--checkFBStatus()
		timer.performWithDelay( 10, checkFBStatus )
	end
end



local function buttonOnRelease( event )

	local id = event.target.name

	if id == "fbShare" then
		print("looking for post on FB")
		requestedFBCommand = POST_LINK
		enforceFacebookLoginAndPermissions()
	elseif id == "logout" then
		print("looking for logout")
		requestedFBCommand = LOGOUT
		facebook.logout()
		commandProcessedByFB = requestedFBCommand
	end
	return true
end

local function reAddListener()
	print("entro en reAddListener")
	--facebookButton:addEventListener("tap", checkInternetConnection)
	--logoutTextBtn:addEventListener("tap", checkInternetConnection)
	--rectangle.isVisible = false
	print("line before remove")

	checkFBStatus()

	if rectangle then
		print("si hay rectangle")
		rectangle:removeSelf()
		rectangle=nil
		workingText.isVisible = false
	end

	print("rectangle removed")
	composer.gotoScene( "scenes.refreshInfo" )

end

local function helpFunc()
	return true
end



-- check the internet connection to show or not the share scene
local function checkInternetConnection(event)
	local event = event -- get the event info
	--facebookButton:removeEventListener("tap", checkInternetConnection)
	--logoutTextBtn:removeEventListener("tap", checkInternetConnection)
	--rectangle.isVisible = true
	local sceneGroup = scene.view
	rectangle = display.newRect( sceneGroup, facebookButton.x, facebookButton.y + 25, 200, 130 )
	workingText.isVisible = true
	workingText:toFront()
	if color == "black" then
    	rectangle:setFillColor(0, 0, 0)
    elseif color == "white" then
    	rectangle:setFillColor(1, 1, 1)
    end
    rectangle:addEventListener("tap", helpFunc)

	print("presionado: " .. event.target.name)

	local test = socket.tcp()
	test:settimeout(0.5)-- Set timeout to 1/2 second
	local testResult = test:connect("www.google.com", 80)-- Note that the test does not work if we put http:// in front 
	local status
	-- internet is vailable
	if not(testResult == nil) then
	    status = true
	else -- internet is not available
	    status = false
	end            
	test:close()
	test = nil
	--depending on network status call logoutAccounts() or shareInfo() or show a message
	if status then
		print("si hay internet")
		buttonOnRelease(event)
	else
		native.showAlert( translations["Network"][language], translations["noInternet"][language], { "OK" })
		reAddListener()
	end

end



-- checks the text input
local function textListener( event )
    if ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        messagetoPost = event.target.text
        print( messagetoPost )
 	end
end



-- New Facebook Connection listener
local function fbListener( event )
	
	-- Process the response to the Facebook command
	-- Note that if the app is already logged in, we will still get a "login" phase
    if ( "session" == event.type ) then

    	if event.phase == "logout" then
			native.showAlert( translations["Accounts"][language], translations["LogOutAccounts"][language], { "OK" })
			--facebookButton:addEventListener("tap", checkInternetConnection)
			--logoutTextBtn:addEventListener("tap", checkInternetConnection)
			reAddListener()

		elseif event.phase == "login" then
			reAddListener()
			
		elseif ( event.phase ~= "login" ) then
			-- Exit if login error
			reAddListener()
			--return
		else
			-- Run the desired command
			processFBCommand()
		end

    elseif ( "request" == event.type ) then

        local response = event.response  -- This is a JSON object from the Facebook server

		if ( not event.isError ) then
			-- Advance the Facebook command state as this command has been processed by Facebook
			commandProcessedByFB = requestedFBCommand
			native.showAlert( "Facebook:", translations["FBSuccesPost"][language], { "OK" })
			--facebookButton:addEventListener("tap", checkInternetConnection)
			--logoutTextBtn:addEventListener("tap", checkInternetConnection)
			reAddListener()
		end

	elseif ( "dialog" == event.type ) then
		-- Advance the Facebook command state as this command has been processed by Facebook
		commandProcessedByFB = requestedFBCommand
    end
end

local function fillTextField()
	textField.text = predeterminedTxt
	messagetoPost = predeterminedTxt
	print(messagetoPost)
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
	--text fiel to edit the message to be shared
    textField = native.newTextField( display.contentCenterX, yL*4, 720, 30 )
    sceneGroup:insert( textField )
    textField.font = native.newFont( "font/madness.ttf", 30 )
	textField:resizeHeightToFitFont()
	textField.align = "center"
    textField.placeholder = translations["EditMessage"][language]
	-- scene button and text
	levelsButton = display.newImageRect( sceneGroup, "images/img_".. color .."/menu.png" , 50, 50 )
	levelsButton.x = display.contentWidth - levelsButton.contentWidth
	levelsButton.y = yL * 0.5
	levelsButton.name = "levelsButton"
	local infotext = display.newText( sceneGroup, translations["Share"][language], 10, yL*0.5, "font/madness.ttf", 70 )
    infotext.anchorX = 0
    infotext:setFillColor( 0.4, 0.4, 0.4, 1 )
    -- informative objects in the scene
    local overallProgressText = display.newText( sceneGroup, translations["Overall"][language], display.contentCenterX, yL*1.3, "font/madness.ttf", 38 )
    overallProgressText:setFillColor( 0.4, 0.4, 0.4, 1 )
    local progressText = display.newText( sceneGroup, overallProgress.."%  "..translations["In"][language].."  "..overallAttempts.."  "..translations["Attempts"][language], display.contentCenterX, yL*1.7, "font/madness.ttf", 38 )
    progressText:setFillColor( 0.4, 0.4, 0.4, 1 )
    local dino = display.newImageRect( sceneGroup, "images/maps/".. color .."/dino" .. character .. ".png" , 180, 154 ) 
	dino.x = display.contentCenterX
	dino.y = yL * 2.8
    -- share and logout buttons



    facebookButton = display.newImageRect( sceneGroup, "images/img_".. color .."/facebookLabel.png" , 170, 60 )
	facebookButton.x = display.contentCenterX
	facebookButton.y = yL * 5.2
	facebookButton.name = "fbShare"

	facebookLogo = display.newImageRect( sceneGroup, "images/img_".. color .."/facebook.png" , 60, 60 )
	facebookLogo.x = display.contentCenterX + 55
	facebookLogo.y = facebookButton.y

	logoutTextBtn = display.newText( sceneGroup, translations["LogOut"][language], facebookButton.x, facebookButton.contentBounds.yMax + 17, "font/madness.ttf", 24 )
    logoutTextBtn:setFillColor( 0.7, 0.7, 0.7, 1 )
    logoutTextBtn.name = "logout"

    statusX = (facebookLogo.contentBounds.xMin - facebookButton.contentBounds.xMin)/2 + facebookButton.contentBounds.xMin + 3
    print(statusX)
    FBstatusText = display.newText( sceneGroup, translations["Login"][language], statusX, facebookButton.y, "font/madness.ttf", 30 )
    FBstatusText:setFillColor( 0.4, 0.4, 0.4, 1 )

    workingText = display.newText( sceneGroup, translations["Wait"][language], facebookButton.x, facebookButton.y, "font/madness.ttf", 30 )
    workingText:setFillColor( 0.4, 0.4, 0.4, 1 )
    workingText.isVisible = false

    predeterminedBtn = display.newText( sceneGroup, translations["Predetermined"][language], textField.x, textField.y + 25, "font/madness.ttf", 24 )
    predeterminedBtn:setFillColor( 0.4, 0.4, 0.4, 1 )
    predeterminedTxt = translations["FBmsgPart1"][language] .. overallProgress .. translations["FBmsgPart2"][language]..overallAttempts..translations["FBmsgPart3"][language]..dinoName

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
		facebook.init(fbListener)
		-- add listener to return to menu
		levelsButton:addEventListener("tap", changeScene)
		-- listener del texto, al terminar de editar agrega listener a SHARE
		textField:addEventListener( "userInput", textListener )
		-- LOGIN comienza con listener
		facebookButton:addEventListener("tap", checkInternetConnection)
		-- logOut comienza con listener
		logoutTextBtn:addEventListener("tap", checkInternetConnection)


		predeterminedBtn:addEventListener("tap", fillTextField)

		
		checkFBStatus()
		
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
		composer.removeScene( "scenes.info" )
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
