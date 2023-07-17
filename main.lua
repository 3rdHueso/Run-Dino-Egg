-----------------------------------------------------------------------------------------
-- 
-- main.lua
--
-----------------------------------------------------------------------------------------
-- uncoment to erase all the files related to the project
--[[
local lfs = require "lfs"
local doc_dir = system.DocumentsDirectory
local doc_path = system.pathForFile("", doc_dir)
local resultOK, errorMsg
for file in lfs.dir(doc_path) do
	local theFile = system.pathForFile(file, doc_dir)
	if (lfs.attributes(theFile, "mode") ~= "directory") then
	  resultOK, errorMsg = os.remove(theFile)
	  if (resultOK) then
	     print(file.." removed")
	  else
	     print("Error removing file: "..file..":"..errorMsg)
	  end
	end
end
--]]

-- Include the Composer and appodeal libraries
local composer = require( "composer" )
local appodeal = require( "plugin.appodeal" )

-- Removes status bar on iOS
display.setStatusBar( display.HiddenStatusBar ) 

-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
	native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

-- uncomment to Show FPS
--local visualMonitor = require( "modules.visualMonitor" )
--local visMon = visualMonitor:new()

-- Show my own splash after corona's default
local presentation = display.newImageRect("images/presentacion.png", 800, 480)
presentation.x = display.contentCenterX
presentation.y = display.contentCenterY

-- eliminate the presentation image after the animation then change to menu screen
local function deletePresentation() 
	presentation:removeSelf()
	presentation = nil
	tr1 = nil
	composer.gotoScene( "scenes.menu", { time=800, effect="crossFade" } )
end

-- animates the presentation 
local tr1
local function animate()
	tr1 = transition.to(presentation, { time=1000, xScale=0.1, yScale=0.1, onComplete=deletePresentation })
	tm1 = nil
end
local tm1 = timer.performWithDelay( 1200, animate )


