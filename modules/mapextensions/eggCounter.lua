
-- Heart bar module

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( options )

	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local color = composer.getVariable( "settedColor" )

	-- Default options for instance
	options = options or {}
	local image = options.image
	local ini = options.ini or 0
	local spacing = options.spacing or 15
	local w, h = options.width or 25, options.height or 30

	-- Create display group to hold visuals
	local group = display.newGroup()
	local hearts = {}
	group.count = ini

	-- add or remove an amount to hearts
	function group:damage( amount )
		group.count = math.max( 0, group.count - ( amount or 1 ) ) 
			if group.count > ini then
				hearts[ini+1] = display.newImageRect( "images/img_".. color .."/egg.png", w, h )
				hearts[ini+1].x = (ini) * ( (w/2) + spacing )-10
				hearts[ini+1].y = 15
				group:insert( hearts[ini+1] )
				ini = ini + 1
			elseif group.count < ini then
				hearts[#hearts]:removeSelf()
				hearts[#hearts] = nil
				ini = ini - 1
			end
		return group.count
	end

	-- remove amount to hearts
	function group:heal( amount )
		self:damage( -( amount or 1 ) )
	end

	function group:quantity()
		return group.count
	end

	function group:finalize()
		-- On remove, cleanup instance 
	end
	group:addEventListener( "finalize" )

	-- Return instance
	return group
end

return M
